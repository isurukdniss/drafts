/* =====================================================================
   SYNC SOLUTION: hash-gated diff, direct to C, auto-batched transfer,
                  with FileHash/FileData atomicity fix + post-run validation
   =====================================================================
   Two additions over the previous version:

   1. BUG FIX: FileHash is now only ever updated in the SAME statement
      as FileData. Previously FileHash was refreshed during the
      structural step, before the file bytes were confirmed moved -
      if the process failed in between, C would end up with a hash
      claiming "this file is current" while the actual bytes were
      stale or missing, and the next run's diff check would see the
      hash match and skip it forever (a silent, permanent gap). New
      rows are inserted with FileHash = NULL until their file bytes
      actually land; existing rows keep their old (still-correct)
      hash until a change is actually applied.

   2. POST-RUN VALIDATION: after all changes commit, re-pull C's
      current hashes and compare them against the #SourceMeta
      snapshot taken at the START of this run (not a fresh live query
      of A/B - that would produce false "mismatches" from ordinary
      concurrent writes that simply haven't been picked up yet).
      Row count and mismatch count are logged; a mismatch means the
      sync did not actually converge C to match what this run
      intended, even though no T-SQL error was thrown.
   ===================================================================== */

/* =====================================================================
   PART 1 - RUN IN DATABASE Y (one-time setup)
   ===================================================================== */
USE [DatabaseY];
GO

IF OBJECT_ID('dbo.C') IS NULL
BEGIN
    CREATE TABLE dbo.C
    (
        ID           INT            NOT NULL PRIMARY KEY,
        Col1         NVARCHAR(200)  NULL,      -- TODO: real A columns
        Col2         NVARCHAR(200)  NULL,
        ExtCol1      NVARCHAR(200)  NULL,      -- TODO: real B columns
        FileData     VARBINARY(MAX) NULL,      -- TODO: confirm source column
        FileHash     BINARY(32)     NULL,
        LastSyncDate DATETIME2(3)   NOT NULL
    );
END
GO

-- Optional but recommended: lets the BI tool read without ever
-- blocking on the sync's row locks.
-- ALTER DATABASE DatabaseY SET READ_COMMITTED_SNAPSHOT ON;

/* =====================================================================
   PART 2 - RUN IN DATABASE X
   ===================================================================== */
USE [DatabaseX];
GO

IF OBJECT_ID('dbo.SyncLog') IS NOT NULL DROP TABLE dbo.SyncLog;
GO
CREATE TABLE dbo.SyncLog
(
    LogID            BIGINT IDENTITY(1,1) PRIMARY KEY,
    SyncName         VARCHAR(50)    NOT NULL,
    StartTime        DATETIME2(3)   NOT NULL,
    EndTime          DATETIME2(3)   NULL,
    RowsInserted     INT            NOT NULL DEFAULT 0,
    RowsUpdated      INT            NOT NULL DEFAULT 0,
    RowsDeleted      INT            NOT NULL DEFAULT 0,
    FilesChanged     INT            NOT NULL DEFAULT 0,
    FilesTransferred INT            NOT NULL DEFAULT 0,
    BatchModeUsed    BIT            NOT NULL DEFAULT 0,
    SourceRowCount   INT            NULL,        -- NULL if run failed before validation ran
    TargetRowCount   INT            NULL,
    MismatchCount    INT            NULL,
    ValidationStatus VARCHAR(20)    NULL,         -- 'Passed' or 'Mismatch'
    Status           VARCHAR(10)    NOT NULL,     -- 'Success' or 'Failed' (did the SP error)
    ErrorMessage     NVARCHAR(4000) NULL
);
GO

-- Linked server setup (unchanged)
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

EXEC sp_serveroption N'LINKSRV_Y', 'data access', 'true';
*/

IF OBJECT_ID('dbo.usp_Sync_A_B_to_C') IS NOT NULL DROP PROCEDURE dbo.usp_Sync_A_B_to_C;
GO
CREATE PROCEDURE dbo.usp_Sync_A_B_to_C
    @FileBatchThreshold INT = 2000,
    @FileBatchSize      INT = 500
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StartTime        DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @Inserted         INT = 0;
    DECLARE @Updated          INT = 0;
    DECLARE @Deleted          INT = 0;
    DECLARE @FilesMoved       INT = 0;
    DECLARE @ChangedCount     INT = 0;
    DECLARE @BatchMode        BIT = 0;
    DECLARE @SourceRowCount   INT = NULL;
    DECLARE @TargetRowCount   INT = NULL;
    DECLARE @MismatchCount    INT = NULL;
    DECLARE @ValidationStatus VARCHAR(20) = NULL;

    BEGIN TRY
        -- Step 1: source manifest - no blob data, just metadata + hash
        IF OBJECT_ID('tempdb..#SourceMeta') IS NOT NULL DROP TABLE #SourceMeta;
        SELECT
            a.ID,
            a.Col1,                                          -- TODO: real A columns
            a.Col2,
            b.ExtCol1,                                        -- TODO: real B columns
            HASHBYTES('SHA2_256', b.FileData) AS FileHash     -- TODO: confirm column/table
        INTO #SourceMeta
        FROM dbo.A a
        LEFT JOIN dbo.B b ON b.ID = a.ID;

        -- Step 2: existing hashes currently in C
        IF OBJECT_ID('tempdb..#ExistingHashes') IS NOT NULL DROP TABLE #ExistingHashes;
        SELECT ID, FileHash
        INTO #ExistingHashes
        FROM OPENQUERY(LINKSRV_Y, 'SELECT ID, FileHash FROM DatabaseY.dbo.C');

        -- Step 3: which IDs need actual file bytes transferred
        IF OBJECT_ID('tempdb..#ChangedIDs') IS NOT NULL DROP TABLE #ChangedIDs;
        SELECT sm.ID
        INTO #ChangedIDs
        FROM #SourceMeta sm
        LEFT JOIN #ExistingHashes eh ON eh.ID = sm.ID
        WHERE eh.ID IS NULL
           OR (eh.FileHash IS NULL AND sm.FileHash IS NOT NULL)
           OR eh.FileHash <> sm.FileHash;

        SELECT @ChangedCount = COUNT(*) FROM #ChangedIDs;
        SET @BatchMode = CASE WHEN @ChangedCount > @FileBatchThreshold THEN 1 ELSE 0 END;

        -- Structural changes: new rows, metadata refresh, deletions.
        -- FileHash is deliberately NOT touched here (see bug-fix note
        -- above) - new rows get FileHash = NULL until their file
        -- actually lands.
        BEGIN TRANSACTION;

            INSERT INTO LINKSRV_Y.DatabaseY.dbo.C
                (ID, Col1, Col2, ExtCol1, FileHash, LastSyncDate)
            SELECT sm.ID, sm.Col1, sm.Col2, sm.ExtCol1, NULL, SYSUTCDATETIME()
            FROM #SourceMeta sm
            LEFT JOIN #ExistingHashes eh ON eh.ID = sm.ID
            WHERE eh.ID IS NULL;

            SET @Inserted = @@ROWCOUNT;

            UPDATE LINKSRV_Y.DatabaseY.dbo.C
            SET Col1         = src.Col1,
                Col2         = src.Col2,
                ExtCol1      = src.ExtCol1,
                LastSyncDate = SYSUTCDATETIME()
            FROM LINKSRV_Y.DatabaseY.dbo.C AS tgt
            JOIN #SourceMeta AS src ON tgt.ID = src.ID
            JOIN #ExistingHashes AS eh ON eh.ID = src.ID;

            SET @Updated = @@ROWCOUNT;

            DELETE tgt
            FROM LINKSRV_Y.DatabaseY.dbo.C AS tgt
            WHERE NOT EXISTS (SELECT 1 FROM #SourceMeta sm WHERE sm.ID = tgt.ID);

            SET @Deleted = @@ROWCOUNT;

        COMMIT TRANSACTION;

        -- File transfer: FileData and FileHash always updated together.
        IF @ChangedCount > 0
        BEGIN
            IF @BatchMode = 0
            BEGIN
                BEGIN TRANSACTION;
                    IF OBJECT_ID('tempdb..#ChangedFiles') IS NOT NULL DROP TABLE #ChangedFiles;
                    SELECT b.ID, b.FileData, sm.FileHash
                    INTO #ChangedFiles
                    FROM dbo.B b
                    JOIN #SourceMeta sm ON sm.ID = b.ID
                    WHERE b.ID IN (SELECT ID FROM #ChangedIDs);

                    UPDATE LINKSRV_Y.DatabaseY.dbo.C
                    SET FileData = src.FileData,
                        FileHash = src.FileHash
                    FROM LINKSRV_Y.DatabaseY.dbo.C AS tgt
                    JOIN #ChangedFiles AS src ON tgt.ID = src.ID;

                    SET @FilesMoved = @@ROWCOUNT;
                COMMIT TRANSACTION;
            END
            ELSE
            BEGIN
                IF OBJECT_ID('tempdb..#ChangedIDList') IS NOT NULL DROP TABLE #ChangedIDList;
                SELECT ID, ROW_NUMBER() OVER (ORDER BY ID) AS RowNum
                INTO #ChangedIDList
                FROM #ChangedIDs;

                DECLARE @BatchStart INT = 1;
                DECLARE @BatchEnd   INT;

                WHILE @BatchStart <= @ChangedCount
                BEGIN
                    SET @BatchEnd = @BatchStart + @FileBatchSize - 1;

                    BEGIN TRANSACTION;
                        IF OBJECT_ID('tempdb..#BatchFiles') IS NOT NULL DROP TABLE #BatchFiles;
                        SELECT b.ID, b.FileData, sm.FileHash
                        INTO #BatchFiles
                        FROM dbo.B b
                        JOIN #SourceMeta sm ON sm.ID = b.ID
                        WHERE b.ID IN (
                            SELECT ID FROM #ChangedIDList WHERE RowNum BETWEEN @BatchStart AND @BatchEnd
                        );

                        UPDATE LINKSRV_Y.DatabaseY.dbo.C
                        SET FileData = src.FileData,
                            FileHash = src.FileHash
                        FROM LINKSRV_Y.DatabaseY.dbo.C AS tgt
                        JOIN #BatchFiles AS src ON tgt.ID = src.ID;

                        SET @FilesMoved = @FilesMoved + @@ROWCOUNT;
                    COMMIT TRANSACTION;

                    RAISERROR('File batch done: rows %d-%d of %d', 0, 1, @BatchStart, @BatchEnd, @ChangedCount) WITH NOWAIT;

                    SET @BatchStart = @BatchEnd + 1;
                END
            END
        END

        -- Post-run validation: compare C's now-current state against
        -- the #SourceMeta snapshot taken at the start of this run.
        SET @SourceRowCount = (SELECT COUNT(*) FROM #SourceMeta);

        IF OBJECT_ID('tempdb..#PostSyncHashes') IS NOT NULL DROP TABLE #PostSyncHashes;
        SELECT ID, FileHash
        INTO #PostSyncHashes
        FROM OPENQUERY(LINKSRV_Y, 'SELECT ID, FileHash FROM DatabaseY.dbo.C');

        SET @TargetRowCount = (SELECT COUNT(*) FROM #PostSyncHashes);

        SELECT @MismatchCount = COUNT(*)
        FROM #SourceMeta sm
        LEFT JOIN #PostSyncHashes ph ON ph.ID = sm.ID
        WHERE ph.ID IS NULL
           OR (ph.FileHash IS NULL AND sm.FileHash IS NOT NULL)
           OR ph.FileHash <> sm.FileHash;

        SET @ValidationStatus = CASE
            WHEN @SourceRowCount = @TargetRowCount AND @MismatchCount = 0 THEN 'Passed'
            ELSE 'Mismatch'
        END;

        IF @ValidationStatus = 'Mismatch'
            RAISERROR('Post-sync validation found mismatches: SourceRows=%d TargetRows=%d MismatchedHashes=%d', 10, 1, @SourceRowCount, @TargetRowCount, @MismatchCount) WITH NOWAIT;

        INSERT INTO dbo.SyncLog (
            SyncName, StartTime, EndTime, RowsInserted, RowsUpdated, RowsDeleted,
            FilesChanged, FilesTransferred, BatchModeUsed,
            SourceRowCount, TargetRowCount, MismatchCount, ValidationStatus, Status
        )
        VALUES (
            'A_B_to_C', @StartTime, SYSUTCDATETIME(), @Inserted, @Updated, @Deleted,
            @ChangedCount, @FilesMoved, @BatchMode,
            @SourceRowCount, @TargetRowCount, @MismatchCount, @ValidationStatus, 'Success'
        );
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, FilesChanged, FilesTransferred, BatchModeUsed, Status, ErrorMessage)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @ChangedCount, @FilesMoved, @BatchMode, 'Failed', ERROR_MESSAGE());

        THROW;
    END CATCH
END;
GO

-- SQL Agent job - quarterly or on demand (unchanged pattern)
USE msdb;
GO
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'Sync_A_B_to_C')
    EXEC sp_delete_job @job_name = N'Sync_A_B_to_C';
GO
EXEC sp_add_job
    @job_name = N'Sync_A_B_to_C',
    @enabled = 1,
    @description = N'Hash-gated diff sync from DatabaseX.A/B to DatabaseY.C, with atomicity fix and post-run validation. Runs quarterly or on demand.';

EXEC sp_add_jobstep
    @job_name = N'Sync_A_B_to_C',
    @step_name = N'Run Sync SP',
    @subsystem = N'TSQL',
    @database_name = N'DatabaseX',
    @command = N'EXEC dbo.usp_Sync_A_B_to_C @FileBatchThreshold = 2000, @FileBatchSize = 500;',
    @retry_attempts = 2,
    @retry_interval = 5;

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
   STATUS / MONITORING
   --------------------------------------------------------------------- */
-- SELECT TOP 20 * FROM DatabaseX.dbo.SyncLog ORDER BY LogID DESC;

-- Runs that completed without error but didn't actually converge:
-- SELECT * FROM DatabaseX.dbo.SyncLog WHERE Status = 'Success' AND ValidationStatus = 'Mismatch' ORDER BY LogID DESC;

-- Runs that never got far enough to validate:
-- SELECT * FROM DatabaseX.dbo.SyncLog WHERE Status = 'Failed' ORDER BY LogID DESC;
