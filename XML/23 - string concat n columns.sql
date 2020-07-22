DROP TABLE IF EXISTS #data
CREATE TABLE #data (userid INT, a VARCHAR(50), b VARCHAR(50), c VARCHAR(50))
GO

INSERT INTO #data
VALUES (1, 'a1', 'b1', 'c1')
     , (1, 'a2', 'b2', 'c2')
     , (2, 'a1', 'b1', 'c1')
     , (2, 'a2', NULL, 'c2')
     , (2, 'a3', 'b3', NULL)
     , (3, 'a1', 'b1', NULL)

------------------------------------------------------

SELECT t.userid
     , STUFF((
         SELECT ', ' + a
         FROM #data t2
         WHERE t2.userid = t.userid
             AND a IS NOT NULL
         FOR XML PATH('')), 1, 2, '')
     , STUFF((
         SELECT ', ' + b
         FROM #data t2
         WHERE t2.userid = t.userid
             AND b IS NOT NULL
         FOR XML PATH('')), 1, 2, '')
FROM (
    SELECT DISTINCT userid
    FROM #data
) t

------------------------------------------------------

SELECT t.userid
     , STUFF(CAST(x.query('a/text()') AS NVARCHAR(MAX)), 1, 2, '')
     , STUFF(CAST(x.query('b/text()') AS NVARCHAR(MAX)), 1, 2, '')
FROM (
    SELECT DISTINCT userid
    FROM #data
) t
OUTER APPLY (
    SELECT a = ISNULL(', ' + a, '')
         , b = ISNULL(', ' + b, '')
    FROM #data t2
    WHERE t2.userid = t.userid
    FOR XML PATH(''), TYPE
) t2 (x)

------------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#data_temp') IS NOT NULL
    DROP TABLE #data_temp

DECLARE @a VARCHAR(MAX)
      , @b VARCHAR(MAX)

SELECT *
     , RowNum = ROW_NUMBER() OVER (PARTITION BY userid ORDER BY 1/0)
     , a_ = CAST(NULL AS VARCHAR(MAX))
     , b_ = CAST(NULL AS VARCHAR(MAX))
INTO #data_temp
FROM #data

UPDATE #data_temp
SET 
      @a = a_ =
        CASE WHEN RowNum = 1 
            THEN a
            ELSE @a + ISNULL(', ' + a, '')
        END
    , @b = b_ =
        CASE WHEN RowNum = 1 
            THEN b
            ELSE @b + ISNULL(', ' + b, '')
        END

SELECT userid, MAX(a_), MAX(b_)
FROM #data_temp
GROUP BY userid