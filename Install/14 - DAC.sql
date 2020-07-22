USE [master]
GO

EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO

EXEC sys.sp_configure 'remote admin connections', 1 
GO
RECONFIGURE WITH OVERRIDE
GO

-- admin:HOMEPC\SQL_2016,1434