SET NOCOUNT ON
SET STATISTICS TIME ON

DECLARE @xml XML
SELECT @xml = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.xml', SINGLE_BLOB) x

DECLARE @jsonu NVARCHAR(MAX)
SELECT @jsonu = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x

DECLARE @json VARCHAR(MAX)
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x

/*
    XML:      CPU = 891 ms, Time = 886 ms
    NVARCHAR: CPU = 141 ms, Time = 166 ms
    VARCHAR:  CPU = 156 ms, Time = 174 ms
*/

------------------------------------------------------

SELECT ProductID =     t.c.value('(ProductID/text())[1]', 'INT')
     , [Name] =        t.c.value('(Name/text())[1]', 'NVARCHAR(50)')
     , ProductNumber = t.c.value('(ProductNumber/text())[1]', 'NVARCHAR(25)')
     , OrderQty =      t.c.value('(OrderQty/text())[1]', 'SMALLINT')
     , UnitPrice =     t.c.value('(UnitPrice/text())[1]', 'MONEY')
     , ListPrice =     t.c.value('(ListPrice/text())[1]', 'MONEY')
     , Color =         t.c.value('(Color/text())[1]', 'NVARCHAR(15)')
     , MakeFlag =      t.c.value('(MakeFlag/text())[1]', 'BIT')
FROM @xml.nodes('Products/Product') t(c)

/*
    CPU time = 6203 ms, elapsed time = 6492 ms
*/

------------------------------------------------------

DECLARE @doc INT
EXEC sys.sp_xml_preparedocument @doc OUTPUT, @xml

SELECT *
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
    )

EXEC sys.sp_xml_removedocument @doc

/*
    CPU time = 2656 ms, elapsed time = 3489 ms
    CPU time = 3844 ms, elapsed time = 4482 ms
    CPU time = 0 ms, elapsed time = 4 ms
*/

------------------------------------------------------

SELECT *
FROM OPENJSON(@jsonu) -- Unicode
WITH (
      ProductID INT
    , [Name] NVARCHAR(50)
    , ProductNumber NVARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
    , ListPrice MONEY
    , Color NVARCHAR(15)
    , MakeFlag BIT
)

/*
    CPU time = 1359 ms, elapsed time = 1642 ms
*/

------------------------------------------------------

SET STATISTICS IO ON

SELECT *
FROM OPENJSON(@json) -- ANSI
WITH (
      ProductID INT
    , [Name] VARCHAR(50)
    , ProductNumber VARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
    , ListPrice MONEY
    , Color VARCHAR(15)
    , MakeFlag BIT
)

/*
    Table 'Worktable'. Scan count 0, logical reads 242643, ..., lob logical reads 260500, ...
        CPU time = 1640 ms, elapsed time = 1685 ms
*/

SET STATISTICS TIME, IO OFF