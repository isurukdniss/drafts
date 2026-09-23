/* =====================================================================
   TRIGGER-BASED SYNC - POC (single database, no linked server, no job)
   =====================================================================
   A, B, and C all live in the SAME database. This removes two things
   that added complexity in the cross-database design:
     - No linked server / OPENQUERY workaround needed - MERGE can
       target a local table directly.
     - No MSDTC / distributed transaction concerns - a plain local
       BEGIN TRAN/COMMIT is sufficient.
   No SQL Agent job is created for this POC - run the sync manually:
       EXEC dbo.usp_Sync_A_B_to_C;

   ASSUMPTIONS (adjust to your real schema before running):
     - A.ID and B.ID are the same shared key (B extends A 1:1).
     - C holds the combined columns from A and B, plus LastSyncDate.
   ===================================================================== */

USE [DatabaseX];   -- same database for A, B, and C in this POC
GO

/* ---------------------------------------------------------------------
   1. DESTINATION TABLE C
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.C') IS NOT NULL DROP TABLE dbo.C;
GO
CREATE TABLE dbo.C
(
    ID           INT           NOT NULL PRIMARY KEY,
    Col1         NVARCHAR(200) NULL,      -- TODO: real A columns
    Col2         NVARCHAR(200) NULL,
    ExtCol1      NVARCHAR(200) NULL,      -- TODO: real B columns
    ExtCol2      NVARCHAR(200) NULL,
    LastSyncDate DATETIME2(3)  NOT NULL
);
GO

/* ---------------------------------------------------------------------
   2. AUDIT TABLE - captures every insert/update/delete on A and B
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.SyncAudit') IS NOT NULL DROP TABLE dbo.SyncAudit;
GO
CREATE TABLE dbo.SyncAudit
(
    AuditID     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceTable VARCHAR(10)  NOT NULL,          -- 'A' or 'B'
    KeyValue    INT          NOT NULL,          -- shared key value (A.ID / B.ID)
    Operation   CHAR(1)      NOT NULL,          -- 'I','U','D'
    ChangeDate  DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE NONCLUSTERED INDEX IX_SyncAudit_KeyValue ON dbo.SyncAudit(KeyValue);
GO

/* ---------------------------------------------------------------------
   3. CONTROL TABLE - watermark of the last audit row processed
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.SyncControl') IS NOT NULL DROP TABLE dbo.SyncControl;
GO
CREATE TABLE dbo.SyncControl
(
    SyncName        VARCHAR(50)  NOT NULL PRIMARY KEY,
    LastAuditID     BIGINT       NOT NULL DEFAULT 0,
    LastRunDateTime DATETIME2(3) NULL
);
GO
INSERT INTO dbo.SyncControl (SyncName, LastAuditID) VALUES ('A_B_to_C', 0);
GO

/* ---------------------------------------------------------------------
   4. LOG TABLE - one row per SP execution, for status/monitoring
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.SyncLog') IS NOT NULL DROP TABLE dbo.SyncLog;
GO
CREATE TABLE dbo.SyncLog
(
    LogID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    SyncName     VARCHAR(50)    NOT NULL,
    StartTime    DATETIME2(3)   NOT NULL,
    EndTime      DATETIME2(3)   NULL,
    FromAuditID  BIGINT         NOT NULL,
    ToAuditID    BIGINT         NULL,
    RowsUpserted INT            NOT NULL DEFAULT 0,
    RowsDeleted  INT            NOT NULL DEFAULT 0,
    Status       VARCHAR(10)    NOT NULL,          -- 'Success','Failed','NoData'
    ErrorMessage NVARCHAR(4000) NULL
);
GO

/* ---------------------------------------------------------------------
   5. TRIGGERS on A and B (set-based, handles multi-row batches)
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.trg_A_Sync') IS NOT NULL DROP TRIGGER dbo.trg_A_Sync;
GO
CREATE TRIGGER dbo.trg_A_Sync ON dbo.A
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.SyncAudit (SourceTable, KeyValue, Operation)
    SELECT 'A', i.ID,
           CASE WHEN EXISTS (SELECT 1 FROM deleted d WHERE d.ID = i.ID) THEN 'U' ELSE 'I' END
    FROM inserted i;

    INSERT INTO dbo.SyncAudit (SourceTable, KeyValue, Operation)
    SELECT 'A', d.ID, 'D'
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.ID = d.ID);
END;
GO

IF OBJECT_ID('dbo.trg_B_Sync') IS NOT NULL DROP TRIGGER dbo.trg_B_Sync;
GO
CREATE TRIGGER dbo.trg_B_Sync ON dbo.B
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Deleting the extension row does NOT delete the row in C (A still
    -- exists); it means C should be re-synced with NULLs for those columns.
    INSERT INTO dbo.SyncAudit (SourceTable, KeyValue, Operation)
    SELECT 'B', i.ID,
           CASE WHEN EXISTS (SELECT 1 FROM deleted d WHERE d.ID = i.ID) THEN 'U' ELSE 'I' END
    FROM inserted i;

    INSERT INTO dbo.SyncAudit (SourceTable, KeyValue, Operation)
    SELECT 'B', d.ID, 'U'   -- re-sync as update, not delete: A row is still live
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.ID = d.ID);
END;
GO

/* ---------------------------------------------------------------------
   6. SYNC STORED PROCEDURE
      No linked server, no OPENQUERY - MERGE targets dbo.C directly
      since everything is in one database. Run manually as needed:
        EXEC dbo.usp_Sync_A_B_to_C;
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.usp_Sync_A_B_to_C') IS NOT NULL DROP PROCEDURE dbo.usp_Sync_A_B_to_C;
GO
CREATE PROCEDURE dbo.usp_Sync_A_B_to_C
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StartTime   DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @FromID      BIGINT;
    DECLARE @ToID        BIGINT;
    DECLARE @UpsertCount INT = 0;
    DECLARE @DeleteCount INT = 0;

    SELECT @FromID = LastAuditID FROM dbo.SyncControl WHERE SyncName = 'A_B_to_C';
    SELECT @ToID   = MAX(AuditID) FROM dbo.SyncAudit WHERE AuditID > @FromID;

    IF @ToID IS NULL
    BEGIN
        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, FromAuditID, ToAuditID, Status)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @FromID, @FromID, 'NoData');
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        IF OBJECT_ID('tempdb..#Changed') IS NOT NULL DROP TABLE #Changed;
        SELECT DISTINCT KeyValue
        INTO #Changed
        FROM dbo.SyncAudit
        WHERE AuditID > @FromID AND AuditID <= @ToID;

        -- Current state (A left join B) for every changed key still in A
        IF OBJECT_ID('tempdb..#Upsert') IS NOT NULL DROP TABLE #Upsert;
        SELECT
            a.ID,
            a.Col1,            -- TODO: replace with real A columns
            a.Col2,
            b.ExtCol1,         -- TODO: replace with real B columns
            b.ExtCol2
        INTO #Upsert
        FROM dbo.A a
        LEFT JOIN dbo.B b ON b.ID = a.ID
        WHERE a.ID IN (SELECT KeyValue FROM #Changed);

        -- Keys that no longer exist in A -> delete from C
        IF OBJECT_ID('tempdb..#Deleted') IS NOT NULL DROP TABLE #Deleted;
        SELECT c.KeyValue
        INTO #Deleted
        FROM #Changed c
        WHERE NOT EXISTS (SELECT 1 FROM dbo.A a WHERE a.ID = c.KeyValue);

        -- Local MERGE - no OPENQUERY needed, target is in the same database
        MERGE dbo.C AS tgt
        USING #Upsert AS src
        ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET
                Col1         = src.Col1,
                Col2         = src.Col2,
                ExtCol1      = src.ExtCol1,
                ExtCol2      = src.ExtCol2,
                LastSyncDate = SYSUTCDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Col1, Col2, ExtCol1, ExtCol2, LastSyncDate)
            VALUES (src.ID, src.Col1, src.Col2, src.ExtCol1, src.ExtCol2, SYSUTCDATETIME());

        SET @UpsertCount = @@ROWCOUNT;

        IF EXISTS (SELECT 1 FROM #Deleted)
        BEGIN
            DELETE c
            FROM dbo.C c
            JOIN #Deleted d ON d.KeyValue = c.ID;

            SET @DeleteCount = @@ROWCOUNT;
        END

        UPDATE dbo.SyncControl
        SET LastAuditID = @ToID, LastRunDateTime = SYSUTCDATETIME()
        WHERE SyncName = 'A_B_to_C';

        COMMIT TRANSACTION;

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, FromAuditID, ToAuditID, RowsUpserted, RowsDeleted, Status)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @FromID, @ToID, @UpsertCount, @DeleteCount, 'Success');
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, FromAuditID, ToAuditID, RowsUpserted, RowsDeleted, Status, ErrorMessage)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @FromID, @ToID, 0, 0, 'Failed', ERROR_MESSAGE());

        THROW;
    END CATCH
END;
GO

/* ---------------------------------------------------------------------
   7. MANUAL EXECUTION (no Agent job for this POC)
   --------------------------------------------------------------------- */
-- EXEC dbo.usp_Sync_A_B_to_C;

/* ---------------------------------------------------------------------
   8. STATUS / MONITORING QUERIES
   --------------------------------------------------------------------- */
-- SELECT TOP 20 * FROM dbo.SyncLog ORDER BY LogID DESC;
-- SELECT * FROM dbo.SyncControl;
-- SELECT COUNT(*) AS PendingChanges
-- FROM dbo.SyncAudit sa
-- CROSS JOIN (SELECT LastAuditID FROM dbo.SyncControl WHERE SyncName='A_B_to_C') c
-- WHERE sa.AuditID > c.LastAuditID;

/* ---------------------------------------------------------------------
   9. QUICK TEST
   --------------------------------------------------------------------- */
-- INSERT INTO dbo.A (ID, Col1, Col2) VALUES (1, 'test1', 'test2');
-- INSERT INTO dbo.B (ID, ExtCol1, ExtCol2) VALUES (1, 'ext1', 'ext2');
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;               -- should show the new row
-- UPDATE dbo.A SET Col1 = 'changed' WHERE ID = 1;
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;               -- Col1 should now say 'changed'
-- DELETE FROM dbo.A WHERE ID = 1;
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;               -- row should be gone
