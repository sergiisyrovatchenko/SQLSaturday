SET NOCOUNT ON

DECLARE @x XML = N'<i val="1" /><i val="2" /><i val="3" />'

SELECT t.c.value('@val', 'INT')
FROM @x.nodes('i') t(c)
WHERE t.c.value('@val', 'INT') > 1

SELECT val
FROM (
    SELECT val = t.c.value('@val', 'INT')
    FROM @x.nodes('i') t(c)
) t
WHERE val > 1

------------------------------------------------------

DECLARE @j NVARCHAR(MAX)
SELECT @j = BulkColumn
FROM OPENROWSET(BULK 'X:\sample1.txt', SINGLE_NCLOB) x

SET STATISTICS TIME, IO ON

SELECT JSON_VALUE(c.value, '$.ProductID')
FROM OPENJSON(@j) c
WHERE CAST(JSON_VALUE(c.value, '$.ProductID') AS INT) < 800

/*
    [Expr1000] = Scalar Operator(json_value(OPENJSON_DEFAULT.[value],N'$.ProductID'));
    [Expr1002] = Scalar Operator(CONVERT(int,json_value(OPENJSON_DEFAULT.[value],N'$.ProductID'),0))

    CPU time = 2203 ms, elapsed time = 2231 ms
*/

SELECT *
FROM (
    SELECT ProductID = CAST(JSON_VALUE(c.value, '$.ProductID') AS INT)
    FROM OPENJSON(@j) c
) t
WHERE ProductID < 800

/*
    [Expr1000] = Scalar Operator(CONVERT(int,json_value(OPENJSON_DEFAULT.[value],N'$.ProductID'),0))

    CPU time = 2203 ms, elapsed time = 2217 ms
*/

SET STATISTICS TIME, IO OFF