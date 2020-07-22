/*
    2008 > Enterprise/Developer
    2008R2..2017 > Enterprise/Web/Standard/Developer
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
    TO DISK = N'D:\BACKUP\AdventureWorks2014_1.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD, NO_COMPRESSION
GO

BACKUP DATABASE [AdventureWorks2014]
    TO DISK = N'D:\BACKUP\AdventureWorks2014_2.bak'
    WITH NOFORMAT, INIT, SKIP, NOREWIND, NOUNLOAD --, COMPRESSION
GO

/*
    ... 24266 pages in 1.414 seconds (134.067 MB/sec).
    ... 24266 pages in 0.694 seconds (273.156 MB/sec).
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
