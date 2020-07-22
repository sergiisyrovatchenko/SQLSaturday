USE AdventureWorks2014
GO

SELECT COUNT_BIG(*)
FROM Production.Product

SELECT COUNT_BIG(*)
FROM Production.Product
WHERE Color = 'Grey'

SELECT COUNT_BIG(*)
FROM Production.Product
WHERE Color <> 'Grey'

SELECT Color, COUNT_BIG(*)
FROM Production.Product
GROUP BY Color

SELECT COUNT_BIG(*)
FROM Production.Product
WHERE Color IS NULL

SELECT COUNT_BIG(*)
FROM Production.Product
WHERE Color IS NOT NULL

SELECT COUNT_BIG(*)
FROM Production.Product
WHERE Color = NULL -- !!!

------------------------------------------------------------------

DECLARE @t1 TABLE (t1 INT, UNIQUE CLUSTERED(t1))
INSERT INTO @t1 VALUES (1), (2)--, (NULL)

DECLARE @t2 TABLE (t2 INT, UNIQUE CLUSTERED(t2))
INSERT INTO @t2 VALUES (1)--, (NULL)

SELECT *
FROM @t1
WHERE t1 NOT IN (SELECT t2 FROM @t2)

SELECT *
FROM @t1
WHERE t1 IN (SELECT t2 FROM @t2)

/*
    a IN (1, NULL)       ==   a=1 OR a=NULL

    a NOT IN (1, NULL)   ==   a<>1 AND a<>NULL
*/

------------------------------------------------------------------

SELECT *
FROM @t1
WHERE t1 NOT IN (
        SELECT t2
        FROM @t2
        WHERE t2 IS NOT NULL
    )
--OPTION(RECOMPILE, QUERYTRACEON 9130)

SELECT * FROM @t1
EXCEPT
SELECT * FROM @t2
--OPTION(RECOMPILE, QUERYTRACEON 9130)

SELECT *
FROM @t1
WHERE NOT EXISTS(
        SELECT 1
        FROM @t2
        WHERE t1 = t2
    )
--OPTION(RECOMPILE, QUERYTRACEON 9130)

------------------------------------------------------------------

DROP TABLE IF EXISTS #temp
GO

CREATE TABLE #temp (
      Color VARCHAR(15) --NULL
    , CONSTRAINT CK CHECK (Color IN ('Black', 'White')) -- NOT FALSE
)

INSERT INTO #temp VALUES ('Black')

INSERT INTO #temp VALUES ('Red')

INSERT INTO #temp VALUES (NULL)

SELECT *
FROM #temp