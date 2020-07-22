SET NOCOUNT ON

USE tempdb
GO

SET STATISTICS TIME OFF

DECLARE @x VARCHAR(MAX) = '1' + REPLICATE(CAST(',1' AS VARCHAR(MAX)), 50000)

SET STATISTICS TIME ON

;WITH cte AS
(
    SELECT s = 1
         , e = COALESCE(NULLIF(CHARINDEX(',', @x, 1), 0), LEN(@x) + 1)
         , v = SUBSTRING(@x, 1, COALESCE(NULLIF(CHARINDEX(',', @x, 1), 0), LEN(@x) + 1) - 1)
    UNION ALL
    SELECT s = CONVERT(INT, e) + 1
         , e = COALESCE(NULLIF(CHARINDEX(',', @x, e + 1), 0), LEN(@x) + 1)
         , v = SUBSTRING(@x, e + 1, COALESCE(NULLIF(CHARINDEX(',',  @x, e + 1), 0), LEN(@x) + 1)- e - 1)
    FROM cte
    WHERE e < LEN(@x) + 1
)
SELECT v
FROM cte
WHERE LEN(v) > 0
OPTION (MAXRECURSION 0)

SELECT t.c.value('(./text())[1]', 'INT')
FROM ( 
    SELECT x = CONVERT(XML, '<i>' + REPLACE(@x, ',', '</i><i>') + '</i>').query('.')
) a
CROSS APPLY x.nodes('i') t(c)

SELECT *
FROM STRING_SPLIT(@x, N',') -- NCHAR(1)/CHAR(1)

SELECT [value]
FROM OPENJSON(N'[' + @x + N']') -- [1,2,3,4]

SET STATISTICS TIME OFF

/*
    500000 rows

    CTE:          29407 ms
    XML:          6520 ms
    STRING_SPLIT: 4665 ms
    OPENJSON:     2606 ms

    100000 rows

    CTE:          2406 ms
    XML:          1084 ms
    STRING_SPLIT: 528 ms
    OPENJSON:     527 ms

    50000 rows

    CTE:          1266 ms
    XML:          553 ms
    STRING_SPLIT: 267 ms
    OPENJSON:     362 ms

    1000 rows

    CTE:          58 ms
    XML:          259 ms
    STRING_SPLIT: 27 ms
    OPENJSON:     19 ms

    10 rows * 1000 executions

    CTE:          4629 ms
    XML:          4297 ms
    STRING_SPLIT: 4031 ms
    OPENJSON:     4047 ms
*/