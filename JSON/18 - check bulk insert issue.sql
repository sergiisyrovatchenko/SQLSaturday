SET NOCOUNT ON
SET STATISTICS TIME, IO ON

;WITH cte AS
(
    SELECT x = CAST(BulkColumn AS XML).query('.')
    FROM OPENROWSET(BULK 'X:\sample1.xml', SINGLE_BLOB) x
)
SELECT t.c.value('(ProductID/text())[1]', 'INT')
FROM cte
CROSS APPLY x.nodes('Products/Product') t(c)

/*
    Table 'Worktable'. Scan count 0, logical reads 30, ..., lob logical reads 290868, ...
        CPU time = 4312 ms, elapsed time = 5347 ms
*/

DECLARE @x XML
SELECT @x = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.xml', SINGLE_BLOB) x

SELECT t.c.value('(ProductID/text())[1]', 'INT')
FROM @x.nodes('Products/Product') t(c)

/*
    Table 'Worktable'. Scan count 0, logical reads 12, ..., lob logical reads 147058, ...
        CPU time = 907 ms, elapsed time = 921 ms
        CPU time = 1171 ms, elapsed time = 1302 ms
*/

------------------------------------------------------

;WITH cte AS (
    SELECT j = BulkColumn
    FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x
)
SELECT p.*
FROM cte
CROSS APPLY OPENJSON(j)
WITH (
      ProductID INT
    , [Name] NVARCHAR(50)
    , ProductNumber NVARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
    , ListPrice MONEY
    , Color NVARCHAR(15)
    , MakeFlag BIT
) p

/*
    Table 'Worktable'. Scan count 0, logical reads 242647, ..., lob logical reads 247090, ...
        CPU time = 1578 ms, elapsed time = 1735 ms
*/

DECLARE @j NVARCHAR(MAX)
SELECT @j = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x

SELECT *
FROM OPENJSON(@j)
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
    Table 'Worktable'. Scan count 0, logical reads 7, ..., lob logical reads 19981, ...
        CPU time = 125 ms, elapsed time = 123 ms
        CPU time = 1469 ms, elapsed time = 1592 ms
*/

SET STATISTICS TIME, IO OFF