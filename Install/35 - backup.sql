USE [master]
GO

SET NOCOUNT ON

DECLARE @db SYSNAME
      , @sql NVARCHAR(MAX)
      , @can_compress BIT
      , @path NVARCHAR(4000)
      , @name SYSNAME
      , @include_time BIT

--SET @path = '\\pub\backup'
IF @path IS NULL
    EXEC [master].dbo.xp_instance_regread
            N'HKEY_LOCAL_MACHINE',
            N'Software\Microsoft\MSSQLServer\MSSQLServer',
            N'BackupDirectory', @path OUTPUT, 'no_output'

SET @can_compress = ISNULL(CAST((
    SELECT [value]
    FROM sys.configurations
    WHERE [name] = 'backup compression default') AS BIT), 0)

DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
    SELECT [name]
    FROM sys.databases
    WHERE [state] = 0
        AND [name] NOT IN ('tempdb')

OPEN cur

FETCH NEXT FROM cur INTO @db

WHILE @@FETCH_STATUS = 0 BEGIN

    SET @name = @path + '\T' + CONVERT(CHAR(8), GETDATE(), 112) + '_' + @db + '.bak'
    SET @sql = '
        BACKUP DATABASE ' + QUOTENAME(@db) + '
        TO DISK = ''' + @name + ''' WITH NOFORMAT, INIT' + 
        CASE WHEN @can_compress = 1 THEN ', COMPRESSION' ELSE '' END

    --PRINT @sql
    EXEC sys.sp_executesql @sql

    FETCH NEXT FROM cur INTO @db
END

CLOSE cur
DEALLOCATE cur

/*
    BACKUP LOG ?
    RESTORE AFTER BACKUP ?
    CHECKSUM ?
*/