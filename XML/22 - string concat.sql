DROP TABLE IF EXISTS #t
GO

CREATE TABLE #t (i CHAR(1))
INSERT INTO #t
VALUES ('1'), ('2'), ('3')

------------------------------------------------------

DECLARE @txt VARCHAR(50) = ''

SELECT @txt += i
FROM #t
ORDER BY i

SELECT @txt

SET @txt = ''

SELECT @txt += i
FROM #t
ORDER BY LEN(i)

SELECT @txt

------------------------------------------------------

SELECT i
FROM #t
FOR XML PATH('')

SELECT [text()] = i
FROM #t
FOR XML PATH('')

SELECT '' + i
FROM #t
FOR XML PATH('')

------------------------------------------------------

SELECT [name], STUFF((
    SELECT ', ' + c.[name]
    FROM sys.columns c
    WHERE c.[object_id] = t.[object_id]
    FOR XML PATH('')), 1, 2, '')
FROM sys.objects t
WHERE t.[type] = 'U'

SELECT [name], STUFF((
    SELECT ', ' + CHAR(13) + c.[name]
    FROM sys.columns c
    WHERE c.[object_id] = t.[object_id]
    FOR XML PATH('')), 1, 2, '')
FROM sys.objects t
WHERE t.[type] = 'U'

SELECT [name], STUFF((
    SELECT ', ' + c.[name]
    FROM sys.columns c
    WHERE c.[object_id] = t.[object_id]
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
FROM sys.objects t
WHERE t.[type] = 'U'

SELECT [name], STUFF((
    SELECT ', ' + c.[name]
    FROM sys.columns c
    WHERE c.[object_id] = t.[object_id]
    FOR XML PATH(''), TYPE).value('(./text())[1]', 'NVARCHAR(MAX)'), 1, 2, '')
FROM sys.objects t
WHERE t.[type] = 'U'

------------------------------------------------------

DROP TABLE IF EXISTS #temp
GO

CREATE TABLE #temp (
      obj_id INT
    , [name] SYSNAME
    , PRIMARY KEY CLUSTERED (obj_id, [name])
)

INSERT INTO #temp (obj_id, [name])
SELECT [object_id], [name]
FROM sys.all_parameters
WHERE parameter_id = 1
    UNION ALL
SELECT TOP(10) PERCENT [object_id], [name]
FROM sys.all_parameters
WHERE parameter_id > 1

SET STATISTICS IO, TIME ON

SELECT obj_id, 
    CASE WHEN cnt = 1
        THEN [name]
        ELSE STUFF((
            SELECT ', ' + [name]
            FROM #temp t2
            WHERE t2.obj_id = t.obj_id
            FOR XML PATH('')), 1, 2, '')
        END
FROM (
    SELECT
          obj_id
        , cnt = COUNT_BIG(*)
        , [name] = MAX([name])
    FROM #temp
    GROUP BY obj_id
) t

SELECT obj_id, STUFF((
        SELECT ', ' + [name]
        FROM #temp t2
        WHERE t2.obj_id = t.obj_id
        FOR XML PATH('')), 1, 2, '')
FROM (
    SELECT DISTINCT obj_id
    FROM #temp
) t

SET STATISTICS IO, TIME OFF

------------------------------------------------------

-- SQL Server 2017: STRING_AGG()

SELECT t.[name]
     , STRING_AGG(c.[name], N',') --  WITHIN GROUP (ORDER BY c.column_id DESC)
FROM sys.objects t
JOIN sys.columns c /* WITH(FORCESCAN) */ ON t.[object_id] = c.[object_id]
GROUP BY t.[name]