SET NOCOUNT ON

DROP TABLE IF EXISTS #t1
DROP TABLE IF EXISTS #t2
GO

CREATE TABLE #t1 (a INT, b INT)
CREATE TABLE #t2 (a INT, b INT)
GO

DECLARE @i INT = 0
WHILE @i < 1000 BEGIN

    INSERT #t1 VALUES (@i * 2, @i * 5)
    INSERT #t2 VALUES (@i * 3, @i * 7)

    SET @i += 1

END

------------------------------------------------------------------

SELECT *
FROM #t1 t1
JOIN #t2 t2 ON t1.a = t2.a
OPTION (MERGE JOIN)

/*
    CREATE UNIQUE CLUSTERED INDEX ix ON #t1 (a)
    CREATE UNIQUE CLUSTERED INDEX ix ON #t2 (a)
*/