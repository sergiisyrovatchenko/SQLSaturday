SET NOCOUNT ON

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS ##Filter
GO

DECLARE @x XML = (
    SELECT
          Customers = (
            SELECT TOP(2000) [*] = CustomerID
            FROM Sales.Customer
            WHERE TerritoryID = 9
            FOR XML PATH('i'), TYPE
        )
        --, Territories = (
        --    SELECT [*] = TerritoryID
        --    FROM Sales.SalesTerritory
        --    WHERE TerritoryID = 9
        --    FOR XML PATH('i'), TYPE
        --)
    FOR XML PATH(''))

SELECT x = @x
INTO ##Filter
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetData
GO

CREATE PROCEDURE dbo.GetData (@Filter XML)
AS BEGIN

    SELECT DISTINCT d.ProductID
    FROM Sales.SalesOrderDetail d
    WHERE d.SalesOrderID IN (
            SELECT h.SalesOrderID
            FROM Sales.SalesOrderHeader h
            WHERE h.CustomerID IN (
                            SELECT t.c.value('(./text())[1]', 'INT')
                            FROM @Filter.nodes('Customers/*') t(c)
                        )
                --AND h.TerritoryID IN (
                --            SELECT t.c.value('(./text())[1]', 'INT')
                --            FROM @Filter.nodes('Territories/*') t(c)
                --        )
        )

END
GO

/*
    Table 'SalesOrderDetail'. Scan count 4355, logical reads 13190, ...
    Table 'SalesOrderHeader'. Scan count 2000, logical reads 17074, ...

    SQL Server Execution Times:
        CPU time = 2937 ms, elapsed time = 1571 ms

*/

------------------------------------------------------

DBCC DROPCLEANBUFFERS
DECLARE @Filter XML = (SELECT * FROM ##Filter)

SET STATISTICS IO, TIME ON

    EXEC dbo.GetData @Filter

SET STATISTICS IO, TIME OFF
GO

------------------------------------------------------

ALTER PROCEDURE dbo.GetData (@Filter XML)
AS BEGIN

    DECLARE @c TABLE (ID INT PRIMARY KEY)
    DECLARE @t TABLE (ID INT PRIMARY KEY)

    INSERT INTO @c
    SELECT t.c.value('(./text())[1]', 'INT')
    FROM @Filter.nodes('Customers/*') t(c)

    INSERT INTO @t
    SELECT t.c.value('(./text())[1]', 'INT')
    FROM @Filter.nodes('Territories/*') t(c)

    --DBCC TRACEON(2453)

    SELECT DISTINCT d.ProductID
    FROM Sales.SalesOrderDetail d
    WHERE d.SalesOrderID IN (
            SELECT h.SalesOrderID
            FROM Sales.SalesOrderHeader h
            WHERE h.CustomerID IN (SELECT * FROM @c)
                AND h.TerritoryID IN (SELECT * FROM @t)
        )

    --DBCC TRACEOFF(2453)

END
GO

/*
    Table 'SalesOrderDetail'. Scan count 4355, logical reads 30256, ...
    Table 'SalesOrderHeader'. Scan count 1, logical reads 689, ...
    Table '#BB8D9BD7'. Scan count 1, logical reads 6, ...
    Table '#BD75E449'. Scan count 1, logical reads 2, ...

    SQL Server Execution Times:
        CPU time = 31 ms, elapsed time = 126 ms

*/

------------------------------------------------------

ALTER PROCEDURE dbo.GetData (@Filter XML)
AS BEGIN

    DECLARE @sql NVARCHAR(MAX) = N'
    SELECT DISTINCT d.ProductID
    FROM Sales.SalesOrderDetail d
    WHERE d.SalesOrderID IN (
            SELECT h.SalesOrderID
            FROM Sales.SalesOrderHeader h
            WHERE h.CustomerID IN (' + REPLACE(REPLACE(REPLACE(CAST(@Filter.query('Customers') AS NVARCHAR(MAX)), '<Customers><i>', ''), '</i></Customers>', ''), '</i><i>', ',') + ')
                AND h.TerritoryID IN (' + REPLACE(REPLACE(REPLACE(CAST(@Filter.query('Territories') AS NVARCHAR(MAX)), '<Territories><i>', ''), '</i></Territories>', ''), '</i><i>', ',') + ')
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