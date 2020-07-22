USE [master]
GO

BACKUP DATABASE KillDB TO DISK = 'KillDB.bak' WITH INIT, COMPRESSION

/*
    BACKUP LOG KillDB TO DISK = 'KillDB.trn' WITH INIT, COMPRESSION
*/

------------------------------------------------------

DECLARE @t TABLE (parent_obj VARCHAR(1000), obj VARCHAR(1000), field VARCHAR(1000), val VARCHAR(1000))
INSERT INTO @t
EXEC sys.sp_executesql N'DBCC DBINFO(@db) WITH TABLERESULTS'
                     , N'@db SYSNAME'
                     , @db = 'KillDB'

SELECT field, val
FROM @t

/*
    dbi_LastLogBackupTime -> BACKUP DATABASE/LOG
    dbi_dbccLastKnownGood -> CHECKDB
*/