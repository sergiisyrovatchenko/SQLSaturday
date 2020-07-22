SET NOCOUNT ON
SET STATISTICS TIME ON

DECLARE @json NVARCHAR(MAX)
SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x

------------------------------------------------------

SELECT COUNT_BIG(*)
FROM OPENJSON(@json)
WITH (
      ProductID INT
    , ProductNumber NVARCHAR(25)
    , OrderQty SMALLINT
    , UnitPrice MONEY
    , ListPrice MONEY
    , Color NVARCHAR(15)
)
WHERE Color = 'Black'

SELECT COUNT_BIG(*)
FROM OPENJSON(@json) WITH (Color NVARCHAR(15))
WHERE Color = 'Black'

SELECT COUNT_BIG(*)
FROM OPENJSON(@json)
WHERE JSON_VALUE(value, '$.Color') = 'Black'

/*
    2016 SP1:

    CPU time = 1140 ms, elapsed time = 1144 ms
    CPU time = 781 ms, elapsed time = 789 ms
    CPU time = 2157 ms, elapsed time = 2144 ms

    2017 RTM:

    CPU time = 1016 ms, elapsed time = 1034 ms
    CPU time = 718 ms, elapsed time = 736 ms
    CPU time = 1282 ms, elapsed time = 1286 ms
*/