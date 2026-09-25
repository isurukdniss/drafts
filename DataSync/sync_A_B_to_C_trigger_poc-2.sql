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
     - A.BinaryId references B.Id (B's own primary key). This is NOT a
       shared key - A.ID and B.Id are independent integer sequences
       and can coincidentally collide in value. Every query and
       trigger below joins A to B via A.BinaryId = B.Id, never by
       assuming the two ID columns line up.
     - C is keyed by A.ID (C reflects one row per A row).
     - Triggers are deliberately independent of each other: trg_A_Sync
       logs A's own key, trg_B_Sync logs B's own key. Neither looks up
       the other table. All resolution of "which A.ID is affected by
       a B.Id change" happens inside usp_Sync_A_B_to_C, via a live
       join on A.BinaryId = B.Id at sync time. This keeps B's trigger
       free of any assumption about which other tables reference it.
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
    ID           INT            NOT NULL PRIMARY KEY,
    Col1         NVARCHAR(200)  NULL,      -- TODO: real A metadata columns (e.g. FileName)
    Col2         NVARCHAR(200)  NULL,
    BinaryVal    VARBINARY(MAX) NULL,      -- from B.BinaryVal - the attachment itself
    LastSyncDate DATETIME2(3)   NOT NULL
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
    KeyValue    INT          NOT NULL,          -- A.ID if SourceTable='A', B.Id if SourceTable='B' (NOT interchangeable)
    Operation   CHAR(1)      NOT NULL,          -- 'I','U','D'
    ChangeDate  DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE NONCLUSTERED INDEX IX_SyncAudit_KeyValue ON dbo.SyncAudit(KeyValue);
GO

/* ---------------------------------------------------------------------
   3. LOG TABLE - one row per SP execution, for status/monitoring
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.SyncLog') IS NOT NULL DROP TABLE dbo.SyncLog;
GO
CREATE TABLE dbo.SyncLog
(
    LogID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    SyncName     VARCHAR(50)    NOT NULL,
    StartTime    DATETIME2(3)   NOT NULL,
    EndTime      DATETIME2(3)   NULL,
    ToAuditID    BIGINT         NULL,             -- highest AuditID processed (and cleared) this run
    RowsUpserted INT            NOT NULL DEFAULT 0,
    RowsDeleted  INT            NOT NULL DEFAULT 0,
    Status       VARCHAR(10)    NOT NULL,          -- 'Success','Failed','NoData'
    ErrorMessage NVARCHAR(4000) NULL
);
GO

/* ---------------------------------------------------------------------
   4. TRIGGERS on A and B (set-based, handles multi-row batches)
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

    -- Deliberately simple: logs B's own key only, with no lookup into
    -- A. B is an independent table - it shouldn't need to know about
    -- every table that might reference it. Resolving which A row(s)
    -- are affected by a B.Id change happens in usp_Sync_A_B_to_C,
    -- not here.
    INSERT INTO dbo.SyncAudit (SourceTable, KeyValue, Operation)
    SELECT 'B', i.Id,
           CASE WHEN EXISTS (SELECT 1 FROM deleted d WHERE d.Id = i.Id) THEN 'U' ELSE 'I' END
    FROM inserted i;

    INSERT INTO dbo.SyncAudit (SourceTable, KeyValue, Operation)
    SELECT 'B', d.Id, 'D'
    FROM deleted d
    WHERE NOT EXISTS (SELECT 1 FROM inserted i WHERE i.Id = d.Id);
END;
GO

/* ---------------------------------------------------------------------
   5. SYNC STORED PROCEDURE
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
    DECLARE @ToID        BIGINT;
    DECLARE @UpsertCount INT = 0;
    DECLARE @DeleteCount INT = 0;

    -- Capture the current max AuditID up front. Anything inserted by a
    -- concurrent trigger AFTER this point (AuditID > @ToID) is left
    -- alone - it'll be picked up whole by the next run. This is what
    -- makes it safe to clear SyncAudit below without a race condition.
    SELECT @ToID = MAX(AuditID) FROM dbo.SyncAudit;

    IF @ToID IS NULL
    BEGIN
        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, ToAuditID, Status)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), NULL, 'NoData');
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- SyncAudit.KeyValue means different things depending on
        -- SourceTable, since the triggers deliberately don't cross-
        -- reference each other:
        --   SourceTable = 'A' -> KeyValue IS A.ID directly
        --   SourceTable = 'B' -> KeyValue is B.Id; resolve to the
        --                        current A.ID(s) where A.BinaryId
        --                        matches it (fans out correctly if
        --                        more than one A row references the
        --                        same B row)
        -- No lower bound on AuditID is needed: everything still sitting
        -- in SyncAudit is by definition unprocessed, since processed
        -- rows are deleted at the end of every successful run.
        IF OBJECT_ID('tempdb..#ChangedAIDs') IS NOT NULL DROP TABLE #ChangedAIDs;
        SELECT DISTINCT AID
        INTO #ChangedAIDs
        FROM (
            SELECT KeyValue AS AID
            FROM dbo.SyncAudit
            WHERE AuditID <= @ToID
              AND SourceTable = 'A'

            UNION

            SELECT a.ID AS AID
            FROM dbo.SyncAudit sa
            JOIN dbo.A a ON a.BinaryId = sa.KeyValue
            WHERE sa.AuditID <= @ToID
              AND sa.SourceTable = 'B'
        ) x;

        -- Current state (A left join B via BinaryId) for every affected A.ID still in A
        IF OBJECT_ID('tempdb..#Upsert') IS NOT NULL DROP TABLE #Upsert;
        SELECT
            a.ID,
            a.Col1,            -- TODO: real A metadata columns (e.g. FileName)
            a.Col2,
            b.BinaryVal        -- the attachment itself
        INTO #Upsert
        FROM dbo.A a
        LEFT JOIN dbo.B b ON b.Id = a.BinaryId
        WHERE a.ID IN (SELECT AID FROM #ChangedAIDs);

        -- Affected A.IDs that no longer exist in A -> delete from C
        IF OBJECT_ID('tempdb..#Deleted') IS NOT NULL DROP TABLE #Deleted;
        SELECT c.AID AS KeyValue
        INTO #Deleted
        FROM #ChangedAIDs c
        WHERE NOT EXISTS (SELECT 1 FROM dbo.A a WHERE a.ID = c.AID);

        -- Local MERGE - no OPENQUERY needed, target is in the same database
        MERGE dbo.C AS tgt
        USING #Upsert AS src
        ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET
                Col1         = src.Col1,
                Col2         = src.Col2,
                BinaryVal    = src.BinaryVal,
                LastSyncDate = SYSUTCDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Col1, Col2, BinaryVal, LastSyncDate)
            VALUES (src.ID, src.Col1, src.Col2, src.BinaryVal, SYSUTCDATETIME());

        SET @UpsertCount = @@ROWCOUNT;

        IF EXISTS (SELECT 1 FROM #Deleted)
        BEGIN
            DELETE c
            FROM dbo.C c
            JOIN #Deleted d ON d.KeyValue = c.ID;

            SET @DeleteCount = @@ROWCOUNT;
        END

        -- Clear only what we just processed. NOT a TRUNCATE and NOT an
        -- unscoped DELETE - both would risk wiping out rows inserted by
        -- a concurrent trigger while this run was executing. Scoping to
        -- AuditID <= @ToID, inside this same transaction, means a
        -- failure below rolls this back too - so a failed run leaves
        -- SyncAudit exactly as it was, ready to be fully reprocessed.
        DELETE FROM dbo.SyncAudit WHERE AuditID <= @ToID;

        COMMIT TRANSACTION;

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, ToAuditID, RowsUpserted, RowsDeleted, Status)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @ToID, @UpsertCount, @DeleteCount, 'Success');
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, ToAuditID, RowsUpserted, RowsDeleted, Status, ErrorMessage)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @ToID, 0, 0, 'Failed', ERROR_MESSAGE());

        THROW;
    END CATCH
END;
GO

/* ---------------------------------------------------------------------
   6. MANUAL EXECUTION (no Agent job for this POC)
   --------------------------------------------------------------------- */
-- EXEC dbo.usp_Sync_A_B_to_C;

/* ---------------------------------------------------------------------
   7. STATUS / MONITORING QUERIES
   --------------------------------------------------------------------- */
-- SELECT TOP 20 * FROM dbo.SyncLog ORDER BY LogID DESC;
-- SELECT COUNT(*) AS PendingChanges FROM dbo.SyncAudit;   -- everything here is unprocessed by definition

/* ---------------------------------------------------------------------
   8. QUICK TEST - covers the ID collision AND the "B.BinaryVal changes
      with no write to A at all" scenario.
   --------------------------------------------------------------------- */
-- -- Unrelated B row that happens to share the value 1 with an A.ID we'll use below
-- INSERT INTO dbo.B (Id, BinaryVal) VALUES (1, 0x6465636F79);            -- 'decoy'
-- -- The B row that A will actually reference
-- INSERT INTO dbo.B (Id, BinaryVal) VALUES (100, 0x7265616C31);          -- 'real1'
--
-- -- A.ID coincidentally equals the decoy B.Id (1), but A.BinaryId points to 100
-- INSERT INTO dbo.A (ID, BinaryId, Col1, Col2) VALUES (1, 100, 'invoice.pdf', 'meta2');
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;
-- -- Expect BinaryVal = 0x7265616C31 ('real1'), NOT the decoy's 0x6465636F79
--
-- -- Update B.BinaryVal directly (Id=100) - NO write to A at all
-- UPDATE dbo.B SET BinaryVal = 0x7265616C32 WHERE Id = 100;              -- 'real2'
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;               -- BinaryVal should now be 0x7265616C32 ('real2')
-- -- This proves trg_B_Sync -> #ChangedAIDs resolution picks up the change
-- -- even though A.ID=1's own row was never touched.
--
-- -- Update the DECOY B row (Id=1) and confirm it does NOT affect C at all
-- UPDATE dbo.B SET BinaryVal = 0x6261640000 WHERE Id = 1;
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;               -- BinaryVal should still be 0x7265616C32 ('real2')
--
-- DELETE FROM dbo.A WHERE ID = 1;
-- EXEC dbo.usp_Sync_A_B_to_C;
-- SELECT * FROM dbo.C;               -- row should be gone
