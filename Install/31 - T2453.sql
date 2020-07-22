/*
    DBCC FREEPROCCACHE
*/

USE AdventureWorks2014
GO

IF OBJECT_ID('tempdb.dbo.#SalesOrderDetail') IS NOT NULL
    DROP TABLE #SalesOrderDetail

CREATE TABLE #SalesOrderDetail (ProductID INT PRIMARY KEY)

INSERT INTO #SalesOrderDetail (ProductID)
SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail

SET STATISTICS IO ON

SELECT *
FROM Production.Product p
WHERE p.ProductID IN (
                SELECT s.ProductID
                FROM #SalesOrderDetail s
            )

SET STATISTICS IO OFF

------------------------------------------------------

DECLARE @SalesOrderDetail TABLE (ProductID INT PRIMARY KEY)

INSERT INTO @SalesOrderDetail (ProductID)
SELECT DISTINCT ProductID
FROM Sales.SalesOrderDetail

--DBCC TRACEON(2453)
SET STATISTICS IO ON

SELECT *
FROM Production.Product p
WHERE p.ProductID IN (
                SELECT s.ProductID
                FROM @SalesOrderDetail s
            )
--OPTION(RECOMPILE)

SET STATISTICS IO OFF
--DBCC TRACEOFF(2453)

------------------------------------------------------

/*
    DBCC FREEPROCCACHE
*/

SELECT s.plan_generation_num
     , s.execution_count
     , DB_NAME(t.[dbid])
     , t.[text]
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
WHERE t.[text] LIKE '%ProductID%'

/*
    RESOURCE_SEMAPHORE_QUERY_COMPILE
*/