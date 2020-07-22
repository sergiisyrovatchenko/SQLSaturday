DECLARE @x NVARCHAR(100) = N'1,2,3,4,5'

SELECT [value]
FROM OPENJSON(N'[' + @x + N']')

------------------------------------------------------

SET NOCOUNT ON

USE AdventureWorks2014
GO

/*
    ALTER DATABASE AdventureWorks2014 SET COMPATIBILITY_LEVEL = 130
*/

DROP TABLE IF EXISTS ##Filter
GO

SELECT Customers = STUFF((
            SELECT TOP(2000) ',' + CAST(CustomerID AS VARCHAR(10))
            FROM Sales.Customer
            WHERE TerritoryID = 9
            FOR XML PATH('')
        ), 1, 1, '')
    , Territories = STUFF((
            SELECT ',' + CAST(TerritoryID AS VARCHAR(10))
            FROM Sales.SalesTerritory
            WHERE TerritoryID = 9
            FOR XML PATH('')
        ), 1, 1, '')
INTO ##Filter
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS #GetData
GO

CREATE PROCEDURE #GetData
(
      @Customers NVARCHAR(MAX)
    , @Territories NVARCHAR(MAX)
)
AS BEGIN

    SELECT DISTINCT d.ProductID
    FROM Sales.SalesOrderDetail d
    WHERE d.SalesOrderID IN (
            SELECT h.SalesOrderID
            FROM Sales.SalesOrderHeader h
            WHERE h.CustomerID IN (
                            SELECT [value]
                            FROM OPENJSON(N'[' + @Customers + N']')
                        )
                AND h.TerritoryID IN (
                            SELECT [value]
                            FROM OPENJSON(N'[' + @Territories + N']')
                        )
        )

END
GO

/*
    Table 'SalesOrderDetail'. Scan count 4355, logical reads 13190, ...
    Table 'SalesOrderHeader'. Scan count 2000, logical reads 17074, ...

    SQL Server Execution Times:
        CPU time = 94 ms, elapsed time = 210 ms
*/

------------------------------------------------------

DBCC DROPCLEANBUFFERS
DECLARE @Customers NVARCHAR(MAX)
      , @Territories NVARCHAR(MAX)

SELECT TOP(1) @Customers = Customers
            , @Territories = Territories
FROM ##Filter

SET STATISTICS IO, TIME ON

    EXEC #GetData @Customers, @Territories

SET STATISTICS IO, TIME OFF
GO

------------------------------------------------------

ALTER PROCEDURE #GetData
(
      @Customers NVARCHAR(MAX)
    , @Territories NVARCHAR(MAX)
)
AS BEGIN

    DECLARE @c TABLE (ID INT PRIMARY KEY)
    DECLARE @t TABLE (ID INT PRIMARY KEY)

    INSERT INTO @c
    SELECT * FROM STRING_SPLIT(@Customers, N',')
    --SELECT [value] FROM OPENJSON(N'[' + @Customers + N']')

    INSERT INTO @t
    SELECT * FROM STRING_SPLIT(@Territories, N',')
    --SELECT [value] FROM OPENJSON(N'[' + @Territories + N']')

    DBCC TRACEON(2453)

    SELECT DISTINCT d.ProductID
    FROM Sales.SalesOrderDetail d
    WHERE d.SalesOrderID IN (
            SELECT h.SalesOrderID
            FROM Sales.SalesOrderHeader h
            WHERE h.CustomerID IN (SELECT * FROM @c)
                AND h.TerritoryID IN (SELECT * FROM @t)
        )
    OPTION(RECOMPILE)

    DBCC TRACEOFF(2453)

END
GO

/*
    Table 'SalesOrderDetail'. Scan count 4355, logical reads 23610, ...
    Table 'SalesOrderHeader'. Scan count 1, logical reads 689, ...
    Table '#B197620B'. Scan count 1, logical reads 6, ...
    Table '#B37FAA7D'. Scan count 1, logical reads 2, ...

    SQL Server Execution Times:
        CPU time = 47 ms, elapsed time = 94 ms
*/

------------------------------------------------------

ALTER PROCEDURE #GetData
(
      @Customers NVARCHAR(MAX)
    , @Territories NVARCHAR(MAX)
)
AS BEGIN

    DECLARE @sql NVARCHAR(MAX) = N'
    SELECT DISTINCT d.ProductID
    FROM Sales.SalesOrderDetail d
    WHERE d.SalesOrderID IN (
            SELECT h.SalesOrderID
            FROM Sales.SalesOrderHeader h
            WHERE h.CustomerID IN (' + @Customers + ')
                AND h.TerritoryID IN (' + @Territories + ')
        )
    --OPTION(RECOMPILE) -- no cache
    '

    PRINT @sql
    EXEC sys.sp_executesql @sql

END
GO

/*
    Error: 8623, Severity: 16, State: 1.
    The query processor ran out of internal resources and could not produce a query plan

    https://blogs.technet.microsoft.com/mdegre/2012/03/13/8623-the-query-processor-ran-out-of-internal-resources-and-could-not-produce-a-query-plan/
*/

/*
    Table 'SalesOrderDetail'. Scan count 1, logical reads 276, ...
    Table 'SalesOrderHeader'. Scan count 1, logical reads 689, ...

    SQL Server Execution Times:
        CPU time = 32 ms, elapsed time = 36 ms
*/

/*
    DBCC FREEPROCCACHE
*/

SELECT c.objtype
     , OBJECT_NAME(t.objectid, t.[dbid])
     , c.usecounts
     , t.[text]
     , q.query_plan
FROM sys.dm_exec_cached_plans c
CROSS APPLY sys.dm_exec_query_plan(c.plan_handle) q
CROSS APPLY sys.dm_exec_sql_text(c.plan_handle) t