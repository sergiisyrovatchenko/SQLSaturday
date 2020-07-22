SET NOCOUNT OFF

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS #InitialTable
DROP TABLE IF EXISTS #None
DROP TABLE IF EXISTS #Row
DROP TABLE IF EXISTS #Page
GO

CREATE TABLE #None (ID INT, Val NVARCHAR(MAX), INDEX ix CLUSTERED (ID) WITH (DATA_COMPRESSION = NONE))
CREATE TABLE #Row  (ID INT, Val NVARCHAR(MAX), INDEX ix CLUSTERED (ID) WITH (DATA_COMPRESSION = ROW))
CREATE TABLE #Page (ID INT, Val NVARCHAR(MAX), INDEX ix CLUSTERED (ID) WITH (DATA_COMPRESSION = PAGE))
GO

SELECT h.SalesOrderID
     , JSON_Data = 
           (
                SELECT p.[Name]
                FROM Sales.SalesOrderDetail d
                JOIN Production.Product p ON d.ProductID = p.ProductID
                WHERE d.SalesOrderID = h.SalesOrderID
                FOR JSON AUTO
           )
INTO #InitialTable
FROM Sales.SalesOrderHeader h

SET STATISTICS IO, TIME ON

INSERT INTO #None
SELECT *
FROM #InitialTable
OPTION(MAXDOP 1)

INSERT INTO #Row
SELECT *
FROM #InitialTable
OPTION(MAXDOP 1)

INSERT INTO #Page
SELECT *
FROM #InitialTable
OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    #None: CPU time = 62 ms,  elapsed time = 68 ms
    #Row:  CPU time = 94 ms,  elapsed time = 89 ms
    #Page: CPU time = 125 ms, elapsed time = 126 ms
*/

------------------------------------------------------

USE tempdb
GO

SELECT obj_name = OBJECT_NAME(p.[object_id])
     , a.[type_desc]
     , a.total_pages
     , total_mb = a.total_pages * 8 / 1024.
FROM sys.partitions p
JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
WHERE p.[object_id] IN (OBJECT_ID('#None'), OBJECT_ID('#Page'), OBJECT_ID('#Row'))