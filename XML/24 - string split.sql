SET NOCOUNT ON

USE tempdb
GO

SET STATISTICS TIME OFF

DECLARE @x VARCHAR(MAX) = '1' + REPLICATE(CAST(',1' AS VARCHAR(MAX)), 1000)

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

SELECT *
FROM dbo.StringSplit_CLR(@x, N',')

SET STATISTICS TIME OFF

/*
    500000 rows

    CTE:          CPU = 27844 ms, Time = 28187 ms
    XML:          CPU = 5781 ms,  Time = 6637 ms
    STRING_SPLIT: CPU = 4422 ms,  Time = 4555 ms
    OPENJSON:     CPU = 1844 ms,  Time = 2553 ms
    CLR:          CPU = 360 ms,   Time = 2507 ms

    100000 rows

    CTE:          CPU = 2265 ms,  Time = 2361 ms
    XML:          CPU = 953 ms,   Time = 1108 ms
    STRING_SPLIT: CPU = 125 ms,   Time = 498 ms
    OPENJSON:     CPU = 110 ms,   Time = 572 ms
    CLR:          CPU = 62 ms,    Time = 478 ms

    50000 rows

    CTE:          CPU = 1172 ms,  Time = 1192 ms
    XML:          CPU = 453 ms,   Time = 619 ms
    STRING_SPLIT: CPU = 125 ms,   Time = 275 ms
    OPENJSON:     CPU = 31 ms,    Time = 301 ms
    CLR:          CPU = 32 ms,    Time = 254 ms

    1000 rows

    CTE:          CPU = 32 ms,    Time = 54 ms
    XML:          CPU = 250 ms,   Time = 254 ms
    STRING_SPLIT: CPU = 8 ms,     Time = 33 ms
    OPENJSON:     CPU = 12 ms,    Time = 17 ms
    CLR:          CPU = 10 ms,    Time = 28 ms

    10 rows * 1000 executions

    CTE:          Time = 4629 ms
    XML:          Time = 4297 ms
    STRING_SPLIT: Time = 4031 ms
    OPENJSON:     Time = 4047 ms
    CLR:          Time = 4114 ms
*/