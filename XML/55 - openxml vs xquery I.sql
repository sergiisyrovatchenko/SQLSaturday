SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS dbo.Products
GO

DECLARE @xml XML
SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.xml', SINGLE_BLOB) x

SET STATISTICS TIME ON

SELECT ProductID =         t.c.value('(ProductID/text())[1]', 'INT')
     , [Name] =            t.c.value('(Name/text())[1]', 'NVARCHAR(50)')
     , ProductNumber =     t.c.value('(ProductNumber/text())[1]', 'NVARCHAR(25)')
     , OrderQty =          t.c.value('(OrderQty/text())[1]', 'SMALLINT')
     , UnitPrice =         t.c.value('(UnitPrice/text())[1]', 'MONEY')
     , ListPrice =         t.c.value('(ListPrice/text())[1]', 'MONEY')
     , Color =             t.c.value('(Color/text())[1]', 'NVARCHAR(15)')
     , MakeFlag =          t.c.value('(MakeFlag/text())[1]', 'BIT')
     , FinishedGoodsFlag = t.c.value('(FinishedGoodsFlag/text())[1]', 'BIT')
     , StandardCost =      t.c.value('(StandardCost/text())[1]', 'MONEY')
INTO dbo.Products
FROM @xml.nodes('Products/Product') t(c)

SET STATISTICS TIME OFF

DROP TABLE IF EXISTS dbo.Products

SET STATISTICS TIME ON

DECLARE @doc INT
EXEC sys.sp_xml_preparedocument @doc OUTPUT, @xml

SELECT *
INTO dbo.Products
FROM OPENXML(@doc, '/Products/Product', 2)
    WITH (
          ProductID INT
        , [Name] NVARCHAR(50)
        , ProductNumber NVARCHAR(25)
        , OrderQty SMALLINT
        , UnitPrice MONEY
        , ListPrice MONEY
        , Color NVARCHAR(15)
        , MakeFlag BIT
        , FinishedGoodsFlag BIT
        , StandardCost MONEY
    )

EXEC sys.sp_xml_removedocument @doc

SET STATISTICS TIME OFF

DROP TABLE IF EXISTS dbo.Products

/*
    Columns  XQuery  OpenXML     OpenXML Prepare OpenXML Parse
    -------- ------- --------    --------------- -------------
    1        1344    5023        3055            1968
    2        2273    5477        3066            2411
    3        3152    5805        3063            2742
    4        3963    6221        3124            3097
    5        4876    6506        3065            3441
    6        5726    6927        3063            3864
    7        6578    7203        3161            4042
    8        7516    7640        3106            4534
    9        8463    7997        3120            4877
    10       9304    8102        3050            5052
*/