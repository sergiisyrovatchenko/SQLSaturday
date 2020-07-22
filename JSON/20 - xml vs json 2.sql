SET NOCOUNT ON
SET STATISTICS TIME ON

DECLARE @xml XML
SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'X:\sample2.xml', SINGLE_BLOB) x

DECLARE @jsonu NVARCHAR(MAX)
SELECT @jsonu = BulkColumn
FROM OPENROWSET(BULK 'X:\sample2.txt', SINGLE_NCLOB) x

DECLARE @json VARCHAR(MAX)
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'X:\sample2.txt', SINGLE_NCLOB) x

/*
    XML:      CPU = 828 ms, Time = 851 ms
    NVARCHAR: CPU = 110 ms, Time = 117 ms
    VARCHAR:  CPU = 125 ms, Time = 139 ms
*/

------------------------------------------------------

SELECT SalesOrderID =  t.c.value('(SalesOrderID/text())[1]', 'INT')
     , AccountNumber = t.c.value('(AccountNumber/text())[1]', 'NVARCHAR(15)')
     , OrderDate =     t.c.value('(OrderDate/text())[1]', 'SMALLDATETIME')
     , ShipDate =      t.c.value('(ShipDate/text())[1]', 'SMALLDATETIME')
     , SubTotal =      t.c.value('(SubTotal/text())[1]', 'MONEY')
     , TaxAmt =        t.c.value('(TaxAmt/text())[1]', 'MONEY')
     , ProductID =     t2.c2.value('(ProductID/text())[1]', 'INT')
     , [Name] =        t2.c2.value('(Name/text())[1]', 'NVARCHAR(50)')
     , ProductNumber = t2.c2.value('(ProductNumber/text())[1]', 'NVARCHAR(25)')
     , OrderQty =      t2.c2.value('(OrderQty/text())[1]', 'SMALLINT')
     , UnitPrice =     t2.c2.value('(UnitPrice/text())[1]', 'MONEY')
FROM @xml.nodes('Orders/Order') t(c)
CROSS APPLY t.c.nodes('Products/Product') t2(c2)

/*
    CPU time = 7907 ms, elapsed time = 8030 ms
*/

------------------------------------------------------

DECLARE @doc INT
EXEC sys.sp_xml_preparedocument @doc OUTPUT, @xml

SELECT *
FROM OPENXML(@doc, '/Orders/Order/Products/Product', 2)
    WITH (
          SalesOrderID INT '../../SalesOrderID'
        , AccountNumber NVARCHAR(15) '../../AccountNumber'
        , OrderDate SMALLDATETIME '../../OrderDate'
        , ShipDate SMALLDATETIME '../../ShipDate'
        , SubTotal MONEY '../../SubTotal'
        , TaxAmt MONEY '../../TaxAmt'
        , ProductID INT
        , [Name] NVARCHAR(50)
        , ProductNumber NVARCHAR(25)
        , OrderQty SMALLINT
        , UnitPrice MONEY
    )

EXEC sys.sp_xml_removedocument @doc

/*
    CPU time = 2281 ms, elapsed time = 2305 ms
    CPU time = 4922 ms, elapsed time = 5123 ms
    CPU time = 0 ms, elapsed time = 3 ms
*/

------------------------------------------------------

SELECT SalesOrderID
     , AccountNumber
     , OrderDate
     , ShipDate
     , SubTotal
     , TaxAmt
     , ProductID
     , [Name]
     , ProductNumber
     , OrderQty
     , UnitPrice
FROM OPENJSON(@jsonu) -- Unicode
WITH (
      SalesOrderID INT
    , AccountNumber NVARCHAR(15)
    , OrderDate SMALLDATETIME
    , ShipDate SMALLDATETIME
    , SubTotal MONEY
    , TaxAmt MONEY
    , Products NVARCHAR(MAX) AS JSON
) c
CROSS APPLY OPENJSON(Products)
WITH (
      ProductID INT
    , [Name] NVARCHAR(50)
    , ProductNumber NVARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
) p

/*
    CPU time = 2313 ms, elapsed time = 2416 ms
*/

------------------------------------------------------

SET STATISTICS IO ON

SELECT SalesOrderID
     , AccountNumber
     , OrderDate
     , ShipDate
     , SubTotal
     , TaxAmt
     , ProductID
     , [Name]
     , ProductNumber
     , OrderQty
     , UnitPrice
FROM OPENJSON(@json) -- ANSI
WITH (
      SalesOrderID INT
    , AccountNumber VARCHAR(15)
    , OrderDate SMALLDATETIME
    , ShipDate SMALLDATETIME
    , SubTotal MONEY
    , TaxAmt MONEY
    , Products NVARCHAR(MAX) AS JSON
) c
CROSS APPLY OPENJSON(Products)
WITH (
      ProductID INT
    , [Name] VARCHAR(50)
    , ProductNumber VARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
) p

/*
    Table 'Worktable'. Scan count 0, logical reads 62939, ..., lob logical reads 238737, ...
        CPU time = 2282 ms, elapsed time = 2461 ms
*/

SET STATISTICS TIME, IO OFF