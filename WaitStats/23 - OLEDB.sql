/*
    USE [master]
    GO

    EXEC sys.sp_configure N'remote access', N'1'
    GO
    RECONFIGURE WITH OVERRIDE
    GO

    EXEC dbo.sp_addlinkedserver @server = N'HOMEPC\SQL_2014', @srvproduct=N'SQL Server'
    GO

    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'collation compatible', @optvalue=N'false'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'data access', @optvalue=N'true'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'dist', @optvalue=N'false'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'pub', @optvalue=N'false'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'rpc', @optvalue=N'true'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'rpc out', @optvalue=N'true'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'sub', @optvalue=N'false'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'connect timeout', @optvalue=N'0'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'collation name', @optvalue=null
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'lazy schema validation', @optvalue=N'false'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'query timeout', @optvalue=N'0'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'use remote collation', @optvalue=N'true'
    EXEC dbo.sp_serveroption @server=N'HOMEPC\SQL_2014', @optname=N'remote proc transaction promotion', @optvalue=N'true'

    EXEC dbo.sp_addlinkedsrvlogin @rmtsrvname=N'HOMEPC\SQL_2014', @useself=N'False', @locallogin=NULL, @rmtuser=N'sa', @rmtpassword=''
    GO
*/

SET STATISTICS TIME ON

SELECT e.BusinessEntityID
     , e.EmailAddress
     , p.PhoneNumber
FROM [HOMEPC\SQL_2014].AdventureWorks2014.Person.EmailAddress e
JOIN [HOMEPC\SQL_2014].AdventureWorks2014.Person.PersonPhone p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN [HOMEPC\SQL_2014].AdventureWorks2014.Person.BusinessEntityAddress r ON e.BusinessEntityID = r.BusinessEntityID

EXEC ('
USE AdventureWorks2014

SELECT e.BusinessEntityID
     , e.EmailAddress
     , p.PhoneNumber
FROM Person.EmailAddress e
JOIN Person.PersonPhone p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress r ON e.BusinessEntityID = r.BusinessEntityID
') AT [HOMEPC\SQL_2014]

DECLARE @EXEC NVARCHAR(100) = N'[HOMEPC\SQL_2014].[AdventureWorks2014].sys.sp_executesql'
      , @SQL NVARCHAR(4000) = N'
SELECT e.BusinessEntityID
     , e.EmailAddress
     , p.PhoneNumber
FROM Person.EmailAddress e
JOIN Person.PersonPhone p ON e.BusinessEntityID = p.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress r ON e.BusinessEntityID = r.BusinessEntityID'

EXEC @EXEC @SQL

SET STATISTICS TIME OFF

------------------------------------------------------------------

SELECT t.TextData
     , t.ApplicationName
     , t.SessionLoginName
     , t.StartTime
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable(i.[path], DEFAULT) t
WHERE i.is_default = 1
    AND t.EventClass = 116 -- Audit DBCC Event
    AND t.ApplicationName IS NOT NULL
    AND t.TextData LIKE '%CHECKDB%'

------------------------------------------------------------------

DECLARE @s DATETIME = GETDATE()
DBCC CHECKDB ([AdventureWorks2014])
SELECT DATEDIFF(MILLISECOND, @s, GETDATE())
GO

/*
    SELECT internal_object_reserved_page_count, *
    FROM tempdb.sys.dm_db_file_space_usage
*/

/*
    INSERT INTO ...
    EXEC ('DBCC CHECKDB([AdventureWorks2014]) WITH TABLERESULTS')
*/

/*
    Causes DBCC CHECKDB to obtain locks instead of using an internal database snapshot.
    This includes a short-term exclusive (X) lock on the database.
    TABLOCK will cause DBCC CHECKDB to run faster on a database under heavy load.
*/

DECLARE @s DATETIME = GETDATE()
DBCC CHECKDB ([AdventureWorks2014]) WITH TABLOCK
SELECT DATEDIFF(MILLISECOND, @s, GETDATE())
GO

/*
    This check is designed to provide a small overhead check of the physical consistency of the database,
    but it can also detect torn pages, checksum failures, and common hardware failures that can compromise a user's data.
*/

DECLARE @s DATETIME = GETDATE()
DBCC CHECKDB ([AdventureWorks2014]) WITH PHYSICAL_ONLY
SELECT DATEDIFF(MILLISECOND, @s, GETDATE())
GO

/*
    Specifies that intensive checks of nonclustered indexes for user tables should not be performed.
*/

DECLARE @s DATETIME = GETDATE()
DBCC CHECKDB ([AdventureWorks2014], NOINDEX)
SELECT DATEDIFF(MILLISECOND, @s, GETDATE())
GO

DECLARE @s DATETIME = GETDATE()
DBCC CHECKDB ([AdventureWorks2014]) WITH MAXDOP = 2
SELECT DATEDIFF(MILLISECOND, @s, GETDATE())
GO

------------------------------------------------------------------

/* SQL Monitor + DMV */