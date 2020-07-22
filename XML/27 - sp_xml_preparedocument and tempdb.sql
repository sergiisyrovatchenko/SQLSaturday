EXEC sys.sp_configure N'max server memory (MB)', N'512'
GO
RECONFIGURE WITH OVERRIDE
GO

------------------------------------------------------

USE AdventureWorks2014
GO

DECLARE @x XML
SELECT @x = (
    SELECT r.ProductID
         , r.[Name]
         , r.ProductNumber
         , d.OrderQty
         , d.UnitPrice
         , r.ListPrice
         , r.Color
         , r.MakeFlag
         , r.StandardCost
    FROM Sales.SalesOrderDetail d
    JOIN Production.Product r ON d.ProductID = r.ProductID
    FOR XML PATH ('Product'), ROOT ('Products')
)

DECLARE @doc INT
      , @tempdb_writes BIGINT = (
                SELECT SUM(num_of_bytes_written)
                FROM sys.dm_io_virtual_file_stats(DB_ID('tempdb'), NULL)
            )

EXEC sys.sp_xml_preparedocument @doc OUTPUT, @x -- created internal table in tempdb

SELECT writed_to_tempdb_mb = (SUM(num_of_bytes_written) - @tempdb_writes) / 1024 / 1024.
     , size_mb = DATALENGTH(@x) / 1024 / 1024.
FROM sys.dm_io_virtual_file_stats(DB_ID('tempdb'), NULL)

EXEC sys.sp_xml_removedocument @doc

------------------------------------------------------

EXEC sys.sp_configure N'max server memory (MB)', N'2147483647'
GO
RECONFIGURE WITH OVERRIDE
GO

