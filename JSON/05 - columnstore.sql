SET NOCOUNT ON

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS #CCI
DROP TABLE IF EXISTS #InitialTable
GO

CREATE TABLE #CCI (ID INT, Val NVARCHAR(MAX), INDEX ix CLUSTERED COLUMNSTORE)
GO

SELECT h.SalesOrderID
     , JSON_Data = --CAST(
           (
                SELECT p.[Name]
                FROM Sales.SalesOrderDetail d
                JOIN Production.Product p ON d.ProductID = p.ProductID
                WHERE d.SalesOrderID = h.SalesOrderID
                FOR JSON AUTO -- < 8000 bytes for SQL Server 2016 (and below)
           )  -- using [N]VARCHAR(MAX)/VARBINARY(MAX) in clustered columnstore supported in SQL Server 2017
       --AS NVARCHAR(4000))
INTO #InitialTable
FROM Sales.SalesOrderHeader h

SET STATISTICS TIME ON

INSERT INTO #CCI
SELECT *
FROM #InitialTable

SET STATISTICS TIME OFF

/*
    #CCI: CPU time = 140 ms, elapsed time = 136 ms
*/

------------------------------------------------------

USE tempdb
GO

SELECT o.[name]
     , s.used_page_count / 128.
FROM sys.indexes i
JOIN sys.dm_db_partition_stats s ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
JOIN sys.objects o ON i.[object_id] = o.[object_id]
WHERE i.[object_id] = OBJECT_ID('#CCI')

SELECT *
FROM sys.dm_db_column_store_row_group_physical_stats
WHERE [object_id] = OBJECT_ID('#CCI')

------------------------------------------------------

ALTER INDEX ix ON #CCI REBUILD