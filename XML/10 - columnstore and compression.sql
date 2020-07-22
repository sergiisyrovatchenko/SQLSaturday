SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #CCI
DROP TABLE IF EXISTS #Heap
GO

SELECT h.SalesOrderID
     , Detail = CAST((
            SELECT TOP(10) d.OrderQty
                         , ProductName = p.[Name]
                         , d.UnitPrice
            FROM AdventureWorks2014.Sales.SalesOrderDetail d
            JOIN AdventureWorks2014.Production.Product p ON d.ProductID = p.ProductID
            WHERE d.SalesOrderID = h.SalesOrderID
            FOR XML PATH, TYPE -- <= 8k
        ) AS NVARCHAR(4000)) -- using XML in columnstore not supported in SQL Server 2017 (only [N]VARCHAR(MAX)/VARBINARY(MAX))
INTO #Heap
FROM AdventureWorks2014.Sales.SalesOrderHeader h

SELECT SalesOrderID, Detail
INTO #CCI
FROM #Heap
GO

CREATE CLUSTERED COLUMNSTORE INDEX cci ON #CCI
GO

SELECT OBJECT_NAME(i.[object_id])
     , s.used_page_count / 128.
FROM sys.indexes i
JOIN sys.dm_db_partition_stats s ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
WHERE i.[object_id] IN (OBJECT_ID('#CCI'), OBJECT_ID('#Heap'))

/*
    -------- -----------
    #Heap    20.101562
    #CCI     3.343750
*/

ALTER TABLE #Heap REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = ROW) -- 9.882812
GO

ALTER TABLE #Heap REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE) -- 8.484375
GO