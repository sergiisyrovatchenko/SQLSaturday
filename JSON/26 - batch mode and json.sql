SET NOCOUNT ON

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS #CCI
DROP TABLE IF EXISTS #Heap
GO

CREATE TABLE #CCI (JSON_Data NVARCHAR(4000))
GO

SELECT JSON_Data =
    (
        SELECT h.SalesOrderID
             , h.OrderDate
             , Product = p.[Name]
             , d.OrderQty
             , p.ListPrice
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
INTO #Heap
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p ON d.ProductID = p.ProductID

INSERT INTO #CCI
SELECT * FROM #Heap

CREATE CLUSTERED COLUMNSTORE INDEX CCI ON #CCI
GO

------------------------------------------------------

USE tempdb
GO

SELECT o.[name]
     , s.used_page_count / 128.
FROM sys.indexes i
JOIN sys.dm_db_partition_stats s ON i.[object_id] = s.[object_id] AND i.index_id = s.index_id
JOIN sys.objects o ON i.[object_id] = o.[object_id]
WHERE i.[object_id] IN (OBJECT_ID('#CCI'), OBJECT_ID('#Heap'))

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT JSON_VALUE(JSON_Data, '$.OrderDate')
     , AVG(CAST(JSON_VALUE(JSON_Data, '$.ListPrice') AS MONEY))
FROM #CCI
--WHERE JSON_VALUE(JSON_Data, '$.Product') = 'Road-150 Red, 52'
GROUP BY JSON_VALUE(JSON_Data, '$.OrderDate')
OPTION(MAXDOP 1)
--OPTION(RECOMPILE, QUERYTRACEON 8649)

SELECT JSON_VALUE(JSON_Data, '$.OrderDate')
     , AVG(CAST(JSON_VALUE(JSON_Data, '$.ListPrice') AS MONEY))
FROM #Heap
--WHERE JSON_VALUE(JSON_Data, '$.Product') = 'Road-150 Red, 52'
GROUP BY JSON_VALUE(JSON_Data, '$.OrderDate')
OPTION(MAXDOP 1)
--OPTION(RECOMPILE, QUERYTRACEON 8649)

SET STATISTICS IO, TIME ON

------------------------------------------------------

SET STATISTICS IO, TIME ON

SELECT OrderDate
     , AVG(ListPrice)
FROM #CCI
CROSS APPLY OPENJSON(JSON_Data)
    WITH (
          OrderDate DATE
        , ListPrice MONEY
        --, Product NVARCHAR(50)
    )
--WHERE Product = 'Road-150 Red, 52'
GROUP BY OrderDate
OPTION(MAXDOP 1)
--OPTION(RECOMPILE, QUERYTRACEON 8649)

SELECT OrderDate
     , AVG(ListPrice)
FROM #Heap
CROSS APPLY OPENJSON(JSON_Data)
    WITH (
          OrderDate DATE
        , ListPrice MONEY
        --, Product NVARCHAR(50)
    )
--WHERE Product = 'Road-150 Red, 52'
GROUP BY OrderDate
OPTION(MAXDOP 1)
--OPTION(RECOMPILE, QUERYTRACEON 8649)

SET STATISTICS IO, TIME OFF