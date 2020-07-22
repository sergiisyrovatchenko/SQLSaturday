SET NOCOUNT ON

USE tempdb
GO

DECLARE @xml XML
SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'X:\sample2.xml', SINGLE_BLOB) x

PRINT 'XQuery'

TRUNCATE TABLE dbo.OrderDetails
DELETE FROM dbo.Orders

SET IDENTITY_INSERT dbo.Orders ON
SET STATISTICS TIME ON

INSERT INTO dbo.Orders (SalesOrderID, AccountNumber, OrderDate, ShipDate, SubTotal, TaxAmt)
SELECT t.c.value('@ID', 'INT')
     , t.c.value('@AccountNumber', 'NVARCHAR(15)')
     , t.c.value('(OrderDate/text())[1]', 'SMALLDATETIME')
     , t.c.value('(ShipDate/text())[1]', 'SMALLDATETIME')
     , t.c.value('@SubTotal', 'MONEY')
     , t.c.value('@TaxAmt', 'MONEY')
FROM @xml.nodes('Orders/Order') t(c)

SET STATISTICS TIME OFF
SET IDENTITY_INSERT dbo.Orders OFF

SET STATISTICS TIME ON

INSERT INTO dbo.OrderDetails (SalesOrderID, ProductID, [Name], ProductNumber, OrderQty, UnitPrice)
SELECT t.c.value('@ID', 'INT')
     , t2.c2.value('(ProductID/text())[1]', 'INT')
     , t2.c2.value('(Name/text())[1]', 'NVARCHAR(50)')
     , t2.c2.value('(ProductNumber/text())[1]', 'NVARCHAR(25)')
     , t2.c2.value('(OrderQty/text())[1]', 'SMALLINT')
     , t2.c2.value('(UnitPrice/text())[1]', 'MONEY')
FROM @xml.nodes('Orders/Order') t(c)
CROSS APPLY t.c.nodes('Products/Product') t2(c2)

SET STATISTICS TIME OFF

/*
    Orders:
        CPU time = 3594 ms,  elapsed time = 3585 ms.

    OrderDetails:
        CPU time = 12047 ms,  elapsed time = 12110 ms.
*/

PRINT 'OpenXML'

TRUNCATE TABLE dbo.OrderDetails
DELETE FROM dbo.Orders

SET IDENTITY_INSERT dbo.Orders ON
SET STATISTICS TIME ON

DECLARE @doc INT
EXEC sys.sp_xml_preparedocument @doc OUTPUT, @xml

INSERT INTO dbo.Orders (SalesOrderID, AccountNumber, OrderDate, ShipDate, SubTotal, TaxAmt)
SELECT *
FROM OPENXML(@doc, '/Orders/Order', 2)
    WITH (
          SalesOrderID INT '@ID'
        , AccountNumber NVARCHAR(15) '@AccountNumber'
        , OrderDate SMALLDATETIME
        , ShipDate SMALLDATETIME
        , SubTotal MONEY '@SubTotal'
        , TaxAmt MONEY '@TaxAmt'
    )

INSERT INTO dbo.OrderDetails (SalesOrderID, ProductID, [Name], ProductNumber, OrderQty, UnitPrice)
SELECT *
FROM OPENXML(@doc, '/Orders/Order/Products/Product', 2)
    WITH (
          SalesOrderID INT '../../@ID'
        , ProductID INT
        , [Name] NVARCHAR(50)
        , ProductNumber NVARCHAR(25)
        , OrderQty SMALLINT
        , UnitPrice MONEY
    )

EXEC sys.sp_xml_removedocument @doc

SET STATISTICS TIME OFF
SET IDENTITY_INSERT dbo.Orders OFF

/*
    Prepare:
        CPU time = 2266 ms,  elapsed time = 2311 ms.

    Orders:
        CPU time = 1188 ms,  elapsed time = 1196 ms.

    OrderDetails:
        CPU time = 3578 ms,  elapsed time = 3637 ms.
*/

