/* =====================================================================
   SYNC SOLUTION: staging table + rename swap
   =====================================================================
   Context: C lives in database Y and is read-only from everyone else's
   perspective - only a BI/reporting tool queries it. Sync runs
   quarterly or on demand. No triggers, no audit table, no MERGE.

   Each run:
     1. On X: build the full current snapshot of A+B.
     2. Push it into a staging table (C_staging) in Y via the linked
        server - plain INSERT, no OPENQUERY workaround needed (that
        limitation is specific to MERGE, not INSERT/DELETE).
     3. Call a stored procedure ON Y that swaps C_staging and C via
        sp_rename - a near-instant metadata operation. The BI tool
        never sees an empty or half-loaded table; it either sees the
        complete old snapshot or the complete new one.
     4. Log the run to SyncLog.

   Design choice: steps 2 and 3 are NOT wrapped in one big distributed
   transaction. If the load into staging fails, C is simply left
   untouched with last quarter's good data still fully queryable -
   which is the right failure mode for a reporting table. The swap
   itself (on Y) is its own local transaction, so it's atomic.

   PREREQUISITE: MSDTC running with Network DTC Access + Allow
   Inbound/Outbound on both servers (still required for the linked
   server INSERT and the remote procedure call).
   ===================================================================== */

/* =====================================================================
   PART 1 - RUN IN DATABASE Y (one-time setup)
   ===================================================================== */
USE [DatabaseY];
GO

-- Production table read by the BI tool. Create only if it doesn't
-- already exist - adjust columns to match your real schema.
IF OBJECT_ID('dbo.C') IS NULL
BEGIN
    CREATE TABLE dbo.C
    (
        ID           INT           NOT NULL PRIMARY KEY,
        Col1         NVARCHAR(200) NULL,      -- TODO: real A columns
        Col2         NVARCHAR(200) NULL,
        ExtCol1      NVARCHAR(200) NULL,      -- TODO: real B columns
        ExtCol2      NVARCHAR(200) NULL,
        LastSyncDate DATETIME2(3)  NOT NULL
    );
END
GO

-- Staging table, identical shape, always empty between runs.
IF OBJECT_ID('dbo.C_staging') IS NOT NULL DROP TABLE dbo.C_staging;
GO
CREATE TABLE dbo.C_staging
(
    ID           INT           NOT NULL PRIMARY KEY,
    Col1         NVARCHAR(200) NULL,
    Col2         NVARCHAR(200) NULL,
    ExtCol1      NVARCHAR(200) NULL,
    ExtCol2      NVARCHAR(200) NULL,
    LastSyncDate DATETIME2(3)  NOT NULL
);
GO

-- Atomic swap: C_staging (new data) <-> C (old data), then clear the
-- old data out of C_staging so it's ready empty for the next run.
IF OBJECT_ID('dbo.usp_SwapCTables') IS NOT NULL DROP PROCEDURE dbo.usp_SwapCTables;
GO
CREATE PROCEDURE dbo.usp_SwapCTables
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;
        EXEC sp_rename 'dbo.C', 'C_old';
        EXEC sp_rename 'dbo.C_staging', 'C';
        EXEC sp_rename 'dbo.C_old', 'C_staging';
    COMMIT TRANSACTION;

    TRUNCATE TABLE dbo.C_staging;
END;
GO

/* =====================================================================
   PART 2 - RUN IN DATABASE X
   ===================================================================== */
USE [DatabaseX];
GO

-- Log table for status/monitoring
IF OBJECT_ID('dbo.SyncLog') IS NOT NULL DROP TABLE dbo.SyncLog;
GO
CREATE TABLE dbo.SyncLog
(
    LogID        BIGINT IDENTITY(1,1) PRIMARY KEY,
    SyncName     VARCHAR(50)    NOT NULL,
    StartTime    DATETIME2(3)   NOT NULL,
    EndTime      DATETIME2(3)   NULL,
    RowsSynced   INT            NOT NULL DEFAULT 0,
    Status       VARCHAR(10)    NOT NULL,          -- 'Success','Failed'
    ErrorMessage NVARCHAR(4000) NULL
);
GO

-- Linked server (run once, on the instance hosting X).
-- rpc / rpc out must be enabled - the swap step calls a remote proc.
/*
EXEC sp_addlinkedserver
    @server      = N'LINKSRV_Y',
    @srvproduct  = N'',
    @provider    = N'MSOLEDBSQL',
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
-- EXEC LINKSRV_Y.DatabaseY.dbo.usp_SwapCTables;
*/

IF OBJECT_ID('dbo.usp_Sync_A_B_to_C') IS NOT NULL DROP PROCEDURE dbo.usp_Sync_A_B_to_C;
GO
CREATE PROCEDURE dbo.usp_Sync_A_B_to_C
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StartTime  DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @RowsSynced INT = 0;

    BEGIN TRY
        -- Full current state of A+B, joined on the shared key
        IF OBJECT_ID('tempdb..#Source') IS NOT NULL DROP TABLE #Source;
        SELECT
            a.ID,
            a.Col1,            -- TODO: replace with real A columns
            a.Col2,
            b.ExtCol1,         -- TODO: replace with real B columns
            b.ExtCol2,
            SYSUTCDATETIME() AS LastSyncDate
        INTO #Source
        FROM dbo.A a
        LEFT JOIN dbo.B b ON b.ID = a.ID;

        SET @RowsSynced = @@ROWCOUNT;

        -- Defensive clear: staging should already be empty (the swap
        -- proc truncates it), but this guards against a prior run
        -- that failed after loading but before/during the swap.
        DELETE FROM LINKSRV_Y.DatabaseY.dbo.C_staging;

        -- Bulk load into staging - plain INSERT works fine over a
        -- linked server (unlike MERGE, no OPENQUERY workaround needed)
        INSERT INTO LINKSRV_Y.DatabaseY.dbo.C_staging
            (ID, Col1, Col2, ExtCol1, ExtCol2, LastSyncDate)
        SELECT ID, Col1, Col2, ExtCol1, ExtCol2, LastSyncDate
        FROM #Source;

        -- Atomic swap, executed on Y
        EXEC LINKSRV_Y.DatabaseY.dbo.usp_SwapCTables;

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, RowsSynced, Status)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @RowsSynced, 'Success');
    END TRY
    BEGIN CATCH
        -- No explicit transaction to roll back here by design: if this
        -- fails, C_staging may be left in a partially-loaded state for
        -- next run's DELETE to clean up, but C itself is untouched and
        -- keeps serving the last good snapshot to the BI tool.
        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, RowsSynced, Status, ErrorMessage)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), 0, 'Failed', ERROR_MESSAGE());

        THROW;
    END CATCH
END;
GO

-- SQL Agent job - quarterly, or start on demand any time
-- (right-click "Start Job at Step..." in SSMS, or just EXEC the SP)
USE msdb;
GO

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Sync_A_B_to_C')
    EXEC sp_delete_job @job_name = N'Sync_A_B_to_C';
GO

EXEC sp_add_job
    @job_name = N'Sync_A_B_to_C',
    @enabled = 1,
    @description = N'Full snapshot sync from DatabaseX.A/B to DatabaseY.C via staging table + rename swap. Runs quarterly or on demand.';

EXEC sp_add_jobstep
    @job_name = N'Sync_A_B_to_C',
    @step_name = N'Run Sync SP',
    @subsystem = N'TSQL',
    @database_name = N'DatabaseX',
    @command = N'EXEC dbo.usp_Sync_A_B_to_C;',
    @retry_attempts = 2,
    @retry_interval = 5;

-- Quarterly schedule: monthly, every 3 months, on day 1 at 02:00
EXEC sp_add_schedule
    @schedule_name = N'Quarterly',
    @freq_type = 16,
    @freq_interval = 1,
    @freq_recurrence_factor = 3,
    @active_start_time = 020000;

EXEC sp_attach_schedule
    @job_name = N'Sync_A_B_to_C',
    @schedule_name = N'Quarterly';

EXEC sp_add_jobserver
    @job_name = N'Sync_A_B_to_C',
    @server_name = N'(local)';
GO

/* ---------------------------------------------------------------------
   STATUS / MONITORING QUERIES
   --------------------------------------------------------------------- */
-- Recent run history
-- SELECT TOP 20 * FROM DatabaseX.dbo.SyncLog ORDER BY LogID DESC;

-- Last successful run
-- SELECT TOP 1 * FROM DatabaseX.dbo.SyncLog WHERE Status = 'Success' ORDER BY LogID DESC;
