EXEC sys.sp_configure N'max server memory (MB)', N'512'
GO
RECONFIGURE WITH OVERRIDE
GO

------------------------------------------------------

USE AdventureWorks2014
GO

DECLARE @tempdb_writes INT = (
        SELECT SUM(num_of_bytes_written)
        FROM sys.dm_io_virtual_file_stats(DB_ID('tempdb'), NULL)
    )

DECLARE @x XML -- max LOB = 2Gb
SELECT @x = (
    SELECT TOP(100000) r.ProductID
                     , r.[Name]
                     , r.ProductNumber
                     , d.OrderQty
                     , d.UnitPrice
                     , r.ListPrice
                     , r.Color
                     , r.MakeFlag
                     , r.FinishedGoodsFlag
                     , r.StandardCost
                     , h.RevisionNumber
                     , h.OrderDate
                     , h.DueDate
                     , h.ShipDate
                     , h.OnlineOrderFlag
                     , h.SalesOrderNumber
                     , h.PurchaseOrderNumber
                     , h.AccountNumber
    FROM Sales.SalesOrderDetail d
    JOIN Production.Product r ON d.ProductID = r.ProductID
    JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
    FOR XML PATH ('Product'), ROOT ('Products')
)

SELECT writed_to_tempdb_mb = (SUM(num_of_bytes_written) - @tempdb_writes) / 1024 / 1024.
     , size_mb = DATALENGTH(@x) / 1024 / 1024.
FROM sys.dm_io_virtual_file_stats(DB_ID('tempdb'), NULL)
GO

------------------------------------------------------

EXEC sys.sp_configure N'max server memory (MB)', N'2147483647'
GO
RECONFIGURE WITH OVERRIDE
GO