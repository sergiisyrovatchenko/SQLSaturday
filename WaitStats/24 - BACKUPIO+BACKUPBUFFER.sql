/*
    2008:         Enterprise/Developer
    2008R2..2016: Enterprise/Standard/Developer
*/

USE [master]
GO

EXEC sys.sp_configure 'backup compression default', 1
GO
RECONFIGURE WITH OVERRIDE
GO

------------------------------------------------------------------

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014'

------------------------------------------------------------------

BACKUP DATABASE [AdventureWorks2014]
    TO DISK = N'F:\AdventureWorks2014_1.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, NO_COMPRESSION
GO

BACKUP DATABASE [AdventureWorks2014]
    TO DISK = N'F:\AdventureWorks2014_2.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD --, COMPRESSION
GO

/*
    SSD
    ... in 1.414 seconds (134.067 MB/sec)
    ... in 0.542 seconds (350.156 MB/sec)

    USB
    ... in 15.882 seconds (11.971 MB/sec)
    ... in 2.424 seconds (48.437 MB/sec)

*/

------------------------------------------------------------------

SELECT f.physical_device_name
     , backup_size_mb = backup_size / 1048576.0
     , compressed_backup_size_mb = NULLIF(compressed_backup_size, backup_size) / 1048576.0
     , compress_ratio_percent = 100 - NULLIF(compressed_backup_size, backup_size) * 100. / backup_size
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily f ON b.media_set_id = f.media_set_id
WHERE [type] = 'D'
    AND [database_name] = 'AdventureWorks2014'

------------------------------------------------------------------

DBCC TRACEON(3605, 3213)
    BACKUP DATABASE [AdventureWorks2014]
        TO DISK = N'F:\AdventureWorks2014_2.bak'
        WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
DBCC TRACEOFF(3605, 3213)

/*
    BufferCount:                7
    Sets Of Buffers:            3
    MaxTransferSize:            1024 KB
    Min MaxTransferSize:        64 KB
    Total buffer space:         21 MB
    Filesystem i/o alignment:   512
    Media Buffer count:         7
    Media Buffer size:          1024 KB
    Encode Buffer count:        7
*/

------------------------------------------------------------------

DECLARE @t TABLE (log_date SMALLDATETIME, spid VARCHAR(50), msg NVARCHAR(4000))
INSERT INTO @t
EXEC sys.xp_readerrorlog 0, 1
SELECT msg FROM @t
WHERE spid = 'spid' + CAST(@@spid AS VARCHAR(10))
ORDER BY log_date

------------------------------------------------------------------

BACKUP DATABASE [AdventureWorks2014]
    TO DISK = 'E:\AdventureWorks2014_3.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
GO

BACKUP DATABASE [AdventureWorks2014] 
    TO
        DISK = 'E:\AdventureWorks2014_3_1.bak',
        DISK = 'E:\AdventureWorks2014_3_2.bak',
        DISK = 'E:\AdventureWorks2014_3_3.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
GO

/*
    ... in 0.745 seconds (255.212 MB/sec)
    ... in 0.542 seconds (350.799 MB/sec)
*/

------------------------------------------------------------------

DBCC TRACEON(3605, 3213)
    BACKUP DATABASE [AdventureWorks2014]
        TO
            DISK = 'E:\AdventureWorks2014_3_1.bak',
            DISK = 'E:\AdventureWorks2014_3_2.bak',
            DISK = 'E:\AdventureWorks2014_3_3.bak'
        WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
DBCC TRACEOFF(3605, 3213)

/*
    BufferCount:                17
    Sets Of Buffers:            3
    MaxTransferSize:            1024 KB
    Min MaxTransferSize:        64 KB
    Total buffer space:         51 MB
    Filesystem i/o alignment:   512
    Media Buffer count:         17
    Media Buffer size:          1024 KB
    Encode Buffer count:        17
*/

------------------------------------------------------------------

BACKUP DATABASE [AdventureWorks2014]
    TO
        DISK = 'E:\AdventureWorks2014_3_1.bak',
        DISK = 'E:\AdventureWorks2014_3_2.bak',
        DISK = 'E:\AdventureWorks2014_3_3.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
GO

--DBCC TRACEON(3605, 3213)

BACKUP DATABASE [AdventureWorks2014]
    TO
        DISK = 'E:\AdventureWorks2014_4_1.bak',
        DISK = 'E:\AdventureWorks2014_4_2.bak',
        DISK = 'E:\AdventureWorks2014_4_3.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
    , BUFFERCOUNT = 64 -- total number of I/O buffers to be used for the backup operation
    , MAXTRANSFERSIZE = 2097152 -- largest unit of transfer in bytes to be used between SQL Server and the backup media
    --, BLOCKSIZE = 65536 -- physical block size (default is 65536 for tape devices and 512 otherwise)

--DBCC TRACEOFF(3605, 3213)

/*
    ... in 0.542 seconds (350.799 MB/sec)
    ... in 0.504 seconds (390.125 MB/sec)
*/

/*
    BufferCount:                64
    Sets Of Buffers:            3
    MaxTransferSize:            2048 KB
    Min MaxTransferSize:        64 KB
    Total buffer space:         345 MB
    Filesystem i/o alignment:   512 :(
    Media Buffer count:         128
    Media Buffer size:          2048 KB
    Encode Buffer count:        64
*/

/*
    http://dba.stackexchange.com/questions/128437/setting-buffercount-blocksize-and-maxtransfersize-for-backup-command
*/

------------------------------------------------------------------

/*
    -T3042 - disabling pre-allocation of space for compressed backup
*/

BACKUP DATABASE [AdventureWorks2014]
    TO DISK = 'E:\AdventureWorks2014_4.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
GO

DBCC TRACEON (3042)
    BACKUP DATABASE [AdventureWorks2014]
        TO DISK = 'E:\AdventureWorks2014_5.bak'
        WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION
DBCC TRACEOFF (3042)

/*
    ... in 1.091 seconds (174.274 MB/sec)
    ... in 0.699 seconds (272.007 MB/sec)
*/

------------------------------------------------------------------

/*
    -T3226 - suppress all successful backups in SQL Server Error log
*/

BACKUP DATABASE [AdventureWorks2014] TO DISK = 'NUL'

DBCC TRACEON (3226)
    BACKUP DATABASE [AdventureWorks2014] TO DISK = 'NUL'
DBCC TRACEOFF (3226)

EXEC sys.xp_readerrorlog 0, 1, N'BACKUP'

/*
    EXEC sys.sp_cycle_errorlog
*/