DROP TABLE IF EXISTS #t
GO

CREATE TABLE #t (i CHAR(1))
INSERT INTO #t
VALUES ('1'), ('2'), ('3')

------------------------------------------------------------------

DECLARE @txt VARCHAR(50) = ''
SELECT @txt += i
FROM #t
ORDER BY i

SELECT @txt
GO

DECLARE @txt VARCHAR(50) = ''
SELECT @txt += i
FROM #t
ORDER BY LEN(i)

SELECT @txt
GO

------------------------------------------------------------------

SELECT i
FROM #t
FOR XML PATH('')

SELECT [text()] = i
FROM #t
FOR XML PATH('')

SELECT '' + i
FROM #t
FOR XML PATH('')

------------------------------------------------------------------

USE AdventureWorks2014
GO

SELECT [name], cols = STUFF((
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