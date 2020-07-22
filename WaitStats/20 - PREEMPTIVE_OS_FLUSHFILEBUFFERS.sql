DECLARE @t TABLE (log_date SMALLDATETIME, spid VARCHAR(50), msg NVARCHAR(4000))
INSERT INTO @t
EXEC sys.xp_readerrorlog 0, 1, N'Starting up database'

SELECT msg, COUNT_BIG(1)
FROM @t
GROUP BY msg
HAVING COUNT_BIG(1) > 1
ORDER BY 2 DESC

------------------------------------------------------

SELECT [name]
FROM sys.databases
WHERE is_auto_close_on = 1

------------------------------------------------------

USE [master] -- _EXP
GO

SELECT is_auto_close_on
FROM sys.databases
WHERE database_id = DB_ID('model')
GO

IF DB_ID('test') IS NOT NULL
    DROP DATABASE [test]
GO

CREATE DATABASE [test]
GO

SELECT is_auto_close_on
FROM sys.databases
WHERE database_id = DB_ID('test')

------------------------------------------------------

DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = (
    SELECT '
ALTER DATABASE ' + QUOTENAME(name) + ' SET AUTO_CLOSE OFF WITH NO_WAIT;'
FROM sys.databases
WHERE is_auto_close_on = 1
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')

EXEC sys.sp_executesql @SQL