/* =====================================================================
   SYNC SOLUTION: A + B (Database X)  -->  C (Database Y)
   =====================================================================
   ASSUMPTIONS (adjust to your real schema before running):
     - A.ID and B.ID are the same shared key (B is a 1:1 extension of A,
       i.e. B.ID references A.ID). If your key is composite or named
       differently, adjust KeyValue's type and the join conditions below.
     - C has the same key column ID and holds the merged columns from
       both A and B, plus a LastSyncDate column.
     - X and Y may be on different SQL Server instances -> linked server.
     - This script's DDL/triggers/SP run in database X.
       C only needs to exist in database Y with matching columns.

   PREREQUISITES ON THE INSTANCE HOSTING X:
     - MSDTC (Distributed Transaction Coordinator) running, with
       "Network DTC Access" + "Allow Inbound/Outbound" enabled, on BOTH
       the X server and the Y server. This is required because any
       write through a linked server is treated as a distributed
       transaction, even from a single statement.
     - A SQL login on Y with INSERT/UPDATE/DELETE rights on dbo.C.
   ===================================================================== */

USE [DatabaseX];
GO

/* ---------------------------------------------------------------------
   1. AUDIT TABLE - captures every insert/update/delete on A and B
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.SyncAudit') IS NOT NULL DROP TABLE dbo.SyncAudit;
GO
CREATE TABLE dbo.SyncAudit
(
    AuditID     BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceTable VARCHAR(10)   NOT NULL,          -- 'A' or 'B'
    KeyValue    INT           NOT NULL,          -- shared key value (A.ID / B.ID)
    Operation   CHAR(1)       NOT NULL,          -- 'I','U','D'
    ChangeDate  DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME()
);
GO
CREATE NONCLUSTERED INDEX IX_SyncAudit_KeyValue ON dbo.SyncAudit(KeyValue);
CREATE NONCLUSTERED INDEX IX_SyncAudit_AuditID_Covering ON dbo.SyncAudit(AuditID) INCLUDE (KeyValue);
GO

/* ---------------------------------------------------------------------
   2. CONTROL TABLE - watermark of the last audit row processed
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
   3. LOG TABLE - one row per SP execution, for status/monitoring
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.SyncLog') IS NOT NULL DROP TABLE dbo.SyncLog;
GO
CREATE TABLE dbo.SyncLog
(
    LogID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    SyncName     VARCHAR(50)   NOT NULL,
    StartTime    DATETIME2(3)  NOT NULL,
    EndTime      DATETIME2(3)  NULL,
    FromAuditID  BIGINT        NOT NULL,
    ToAuditID    BIGINT        NULL,
    RowsUpserted INT           NOT NULL DEFAULT 0,
    RowsDeleted  INT           NOT NULL DEFAULT 0,
    Status       VARCHAR(10)   NOT NULL,          -- 'Success','Failed','NoData'
    ErrorMessage NVARCHAR(4000) NULL
);
GO

/* ---------------------------------------------------------------------
   4. TRIGGERS on A and B (set-based, handles multi-row inserts/updates)
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

    -- Deleting the extension row does NOT delete the row in C (A still exists);
    -- it just means C should be re-synced with NULLs for the extension columns.
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
   5. LINKED SERVER - X pointing to Y
      Run this on the instance hosting database X.
      Replace server name / auth details for your environment.
   --------------------------------------------------------------------- */
/*
EXEC sp_addlinkedserver
    @server      = N'LINKSRV_Y',
    @srvproduct  = N'',
    @provider    = N'MSOLEDBSQL',        -- or 'SQLNCLI' on older versions
    @datasrc     = N'YServerNameOrIP';

EXEC sp_addlinkedsrvlogin
    @rmtsrvname  = N'LINKSRV_Y',
    @useself     = N'FALSE',
    @locallogin  = NULL,
    @rmtuser     = N'sync_user',
    @rmtpassword = N'StrongPassword!';

EXEC sp_serveroption N'LINKSRV_Y', 'rpc', 'true';
EXEC sp_serveroption N'LINKSRV_Y', 'rpc out', 'true';
EXEC sp_serveroption N'LINKSRV_Y', 'data access', 'true';

-- Test:
-- SELECT * FROM OPENQUERY(LINKSRV_Y, 'SELECT TOP 1 * FROM DatabaseY.dbo.C');
*/

/* ---------------------------------------------------------------------
   6. SYNC STORED PROCEDURE
      Reads unprocessed audit rows, joins A+B for the affected keys,
      MERGEs into C via OPENQUERY (MERGE cannot target a remote table
      directly using a 4-part name), deletes rows removed from A,
      advances the watermark, and logs the run.
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

        -- Current state (A left join B) for every changed key still present in A
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

        -- Upsert into C (remote) via OPENQUERY target
        MERGE OPENQUERY(LINKSRV_Y,
            'SELECT ID, Col1, Col2, ExtCol1, ExtCol2, LastSyncDate FROM DatabaseY.dbo.C'
        ) AS tgt
        USING #Upsert AS src
        ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET
                Col1         = src.Col1,
                Col2         = src.Col2,
                ExtCol1      = src.ExtCol1,
                ExtCol2      = src.ExtCol2,
                LastSyncDate = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (ID, Col1, Col2, ExtCol1, ExtCol2, LastSyncDate)
            VALUES (src.ID, src.Col1, src.Col2, src.ExtCol1, src.ExtCol2, SYSUTCDATETIME());

        SET @UpsertCount = @@ROWCOUNT;

        -- Delete rows in C for keys removed from A
        IF EXISTS (SELECT 1 FROM #Deleted)
        BEGIN
            DELETE FROM OPENQUERY(LINKSRV_Y,
                'SELECT ID FROM DatabaseY.dbo.C'
            )
            WHERE ID IN (SELECT KeyValue FROM #Deleted);

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
   7. OPTIONAL HOUSEKEEPING - purge processed audit rows older than 30 days
   --------------------------------------------------------------------- */
IF OBJECT_ID('dbo.usp_Purge_SyncAudit') IS NOT NULL DROP PROCEDURE dbo.usp_Purge_SyncAudit;
GO
CREATE PROCEDURE dbo.usp_Purge_SyncAudit
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Watermark BIGINT;
    SELECT @Watermark = LastAuditID FROM dbo.SyncControl WHERE SyncName = 'A_B_to_C';

    DELETE FROM dbo.SyncAudit
    WHERE AuditID <= @Watermark
      AND ChangeDate < DATEADD(DAY, -30, SYSUTCDATETIME());
END;
GO

/* ---------------------------------------------------------------------
   8. SQL AGENT JOB - runs the sync SP every 5 minutes
   --------------------------------------------------------------------- */
USE msdb;
GO

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Sync_A_B_to_C')
    EXEC sp_delete_job @job_name = N'Sync_A_B_to_C';
GO

EXEC sp_add_job
    @job_name = N'Sync_A_B_to_C',
    @enabled = 1,
    @description = N'Syncs changes from DatabaseX.A/B to DatabaseY.C';

EXEC sp_add_jobstep
    @job_name = N'Sync_A_B_to_C',
    @step_name = N'Run Sync SP',
    @subsystem = N'TSQL',
    @database_name = N'DatabaseX',
    @command = N'EXEC dbo.usp_Sync_A_B_to_C;',
    @retry_attempts = 3,
    @retry_interval = 1,
    @on_success_action = 1,   -- quit reporting success
    @on_fail_action = 2;      -- quit reporting failure

EXEC sp_add_schedule
    @schedule_name = N'Every5Minutes',
    @freq_type = 4,            -- daily
    @freq_interval = 1,
    @freq_subday_type = 4,     -- minutes
    @freq_subday_interval = 5;

EXEC sp_attach_schedule
    @job_name = N'Sync_A_B_to_C',
    @schedule_name = N'Every5Minutes';

EXEC sp_add_jobserver
    @job_name = N'Sync_A_B_to_C',
    @server_name = N'(local)';
GO

/* ---------------------------------------------------------------------
   9. STATUS / MONITORING QUERIES
   --------------------------------------------------------------------- */
-- Recent run history
-- SELECT TOP 20 * FROM DatabaseX.dbo.SyncLog ORDER BY LogID DESC;

-- Current watermark
-- SELECT * FROM DatabaseX.dbo.SyncControl;

-- How many changes are waiting to be synced right now
-- SELECT COUNT(*) AS PendingChanges
-- FROM DatabaseX.dbo.SyncAudit sa
-- CROSS JOIN (SELECT LastAuditID FROM DatabaseX.dbo.SyncControl WHERE SyncName='A_B_to_C') c
-- WHERE sa.AuditID > c.LastAuditID;
