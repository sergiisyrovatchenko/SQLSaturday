/*
    SQL Server 2008+
    SQLXML 4.0 x64: http://www.microsoft.com/en-gb/download/details.aspx?id=30403
*/

USE tempdb
GO

DROP TABLE IF EXISTS dbo.Products
GO

CREATE TABLE dbo.Products (
      ProductID INT
    , [Name] NVARCHAR(50)
    , ProductNumber NVARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
    , ListPrice MONEY
    , Color NVARCHAR(15) DEFAULT 'Unknown' NOT NULL
    , MakeFlag BIT
    , FinishedGoods BIT
    , StandardCost MONEY
)
GO

------------------------------------------------------

SET STATISTICS TIME ON

EXEC sys.xp_cmdshell 'CScript "D:\PROJECT\XML\SQLXMLBulkLoad\sample1.vbs"'

SET STATISTICS TIME OFF

/*
    SQL Server Execution Times:
        CPU time = 0 ms,  elapsed time = 3639 ms.
*/

------------------------------------------------------

SELECT TOP(100) *
FROM dbo.Products
ORDER BY NEWID()