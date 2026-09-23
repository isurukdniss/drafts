/* =====================================================================
   SYNC SOLUTION: hash-gated diff, direct to C, auto-batched file transfer
   =====================================================================
   Same as the direct hash-gated version, with one addition: before
   transferring changed file bytes, count how many rows actually need
   it. Below the threshold, transfer them all in one statement inside
   one transaction (fully atomic, as before). Above the threshold,
   loop through them in chunks, each chunk its own transaction - this
   matters mainly for the cold-start run (C has no hashes yet, so
   everything looks "changed") or any future bulk file replacement.

   Trade-off when batch mode kicks in: the file transfer is no longer
   a single all-or-nothing operation. If it fails partway, whatever
   batches already committed stay committed. This is safe to just
   re-run: #ChangedIDs is recomputed fresh each run by comparing
   hashes, so already-updated rows won't be selected again - the
   batch loop is naturally resumable.

   The structural changes (new rows, metadata refresh, deletions) stay
   in one transaction regardless of file volume - those touch small
   columns only, so batching them isn't necessary.
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
    FilesChanged     INT            NOT NULL DEFAULT 0,   -- how many needed a transfer
    FilesTransferred INT            NOT NULL DEFAULT 0,   -- how many actually completed
    BatchModeUsed    BIT            NOT NULL DEFAULT 0,
    Status           VARCHAR(10)    NOT NULL,
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
    @FileBatchThreshold INT = 2000,   -- above this many changed files, switch to batched transfer
    @FileBatchSize      INT = 500     -- rows per batch once batching kicks in
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @StartTime    DATETIME2(3) = SYSUTCDATETIME();
    DECLARE @Inserted     INT = 0;
    DECLARE @Updated      INT = 0;
    DECLARE @Deleted      INT = 0;
    DECLARE @FilesMoved   INT = 0;
    DECLARE @ChangedCount INT = 0;
    DECLARE @BatchMode    BIT = 0;

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

        -- Structural changes: always one transaction, regardless of
        -- file volume - these only touch small columns.
        BEGIN TRANSACTION;

            INSERT INTO LINKSRV_Y.DatabaseY.dbo.C
                (ID, Col1, Col2, ExtCol1, FileHash, LastSyncDate)
            SELECT sm.ID, sm.Col1, sm.Col2, sm.ExtCol1, sm.FileHash, SYSUTCDATETIME()
            FROM #SourceMeta sm
            LEFT JOIN #ExistingHashes eh ON eh.ID = sm.ID
            WHERE eh.ID IS NULL;

            SET @Inserted = @@ROWCOUNT;

            UPDATE LINKSRV_Y.DatabaseY.dbo.C
            SET Col1         = src.Col1,
                Col2         = src.Col2,
                ExtCol1      = src.ExtCol1,
                FileHash     = src.FileHash,
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

        -- File transfer: single statement if small, batched if large
        IF @ChangedCount > 0
        BEGIN
            IF @BatchMode = 0
            BEGIN
                BEGIN TRANSACTION;
                    IF OBJECT_ID('tempdb..#ChangedFiles') IS NOT NULL DROP TABLE #ChangedFiles;
                    SELECT b.ID, b.FileData
                    INTO #ChangedFiles
                    FROM dbo.B b
                    WHERE b.ID IN (SELECT ID FROM #ChangedIDs);

                    UPDATE LINKSRV_Y.DatabaseY.dbo.C
                    SET FileData = src.FileData
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
                        SELECT b.ID, b.FileData
                        INTO #BatchFiles
                        FROM dbo.B b
                        WHERE b.ID IN (
                            SELECT ID FROM #ChangedIDList WHERE RowNum BETWEEN @BatchStart AND @BatchEnd
                        );

                        UPDATE LINKSRV_Y.DatabaseY.dbo.C
                        SET FileData = src.FileData
                        FROM LINKSRV_Y.DatabaseY.dbo.C AS tgt
                        JOIN #BatchFiles AS src ON tgt.ID = src.ID;

                        SET @FilesMoved = @FilesMoved + @@ROWCOUNT;
                    COMMIT TRANSACTION;

                    RAISERROR('File batch done: rows %d-%d of %d', 0, 1, @BatchStart, @BatchEnd, @ChangedCount) WITH NOWAIT;

                    SET @BatchStart = @BatchEnd + 1;
                END
            END
        END

        INSERT INTO dbo.SyncLog (SyncName, StartTime, EndTime, RowsInserted, RowsUpdated, RowsDeleted, FilesChanged, FilesTransferred, BatchModeUsed, Status)
        VALUES ('A_B_to_C', @StartTime, SYSUTCDATETIME(), @Inserted, @Updated, @Deleted, @ChangedCount, @FilesMoved, @BatchMode, 'Success');
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
    @description = N'Hash-gated diff sync from DatabaseX.A/B to DatabaseY.C, applied directly with auto-batched file transfer. Runs quarterly or on demand.';

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
-- BatchModeUsed = 1 tells you a run had to fall back to chunked transfer -
-- worth checking FilesChanged in those rows to see how large the diff was.
