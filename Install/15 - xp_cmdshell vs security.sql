USE [master]
GO

EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO

EXEC sys.sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE WITH OVERRIDE
GO

------------------------------------------------------------------

USE AdventureWorks2014
GO

IF OBJECT_ID('tempdb.dbo.##temp') IS NOT NULL
    DROP TABLE ##temp
GO

SELECT val = (
    SELECT [@name] = [name]
    FROM sys.objects
    WHERE [type] IN ('U', 'V')
    FOR XML PATH('obj'), ROOT('objects')
)
INTO ##temp

DECLARE @sql NVARCHAR(4000) = 'bcp "SELECT * FROM ##temp" queryout "D:\sample.xml" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql