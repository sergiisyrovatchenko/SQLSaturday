SET NOCOUNT ON

USE tempdb
GO

DROP TABLE IF EXISTS #varchar
DROP TABLE IF EXISTS #nvarchar
DROP TABLE IF EXISTS #ntext
GO

CREATE TABLE #varchar  (x VARCHAR(MAX))
CREATE TABLE #nvarchar (x NVARCHAR(MAX)) -- ver >= 2005 && size > 8060 ? LOB_DATA : IN_ROW_DATA
CREATE TABLE #ntext    (x NTEXT) -- NTEXT/TEXT/IMAGE always in LOB_DATA
GO

/*
    IN_ROW_DATA
    ROW_OVERFLOW
    LOB_DATA -> EXEC sys.sp_tableoption '#nvarchar', 'large value types out of row', 1
*/

DECLARE @json NVARCHAR(MAX) = N'[{"Manufacturer":"Lenovo","Model":"ThinkPad E460","Availability":1}]'

SET STATISTICS IO, TIME ON

INSERT INTO #varchar
SELECT TOP(50000) @json
FROM [master].dbo.spt_values s1
CROSS JOIN [master].dbo.spt_values s2
OPTION(MAXDOP 1)

INSERT INTO #nvarchar
SELECT TOP(50000) @json
FROM [master].dbo.spt_values s1
CROSS JOIN [master].dbo.spt_values s2
OPTION(MAXDOP 1)

INSERT INTO #ntext
SELECT TOP(50000) @json
FROM [master].dbo.spt_values s1
CROSS JOIN [master].dbo.spt_values s2
OPTION(MAXDOP 1)

SET STATISTICS IO, TIME OFF

/*
    #varchar:  CPU time = 32 ms,  elapsed time = 28 ms
    #nvarchar: CPU time = 31 ms,  elapsed time = 30 ms
    #ntext:    CPU time = 172 ms, elapsed time = 190 ms
*/

SELECT obj_name = OBJECT_NAME(p.[object_id])
     , a.[type_desc]
     , a.total_pages
     , total_mb = a.total_pages * 8 / 1024.
FROM sys.allocation_units a
JOIN sys.partitions p ON p.[partition_id] = a.container_id
WHERE p.[object_id] IN (OBJECT_ID('#nvarchar'), OBJECT_ID('#ntext'), OBJECT_ID('#varchar'))
GO

------------------------------------------------------

SELECT TOP(1) 1
FROM #ntext
WHERE ISJSON(x) = 1

SELECT TOP(1) *
FROM #ntext
WHERE ISJSON(CAST(x AS NVARCHAR(MAX))) = 1

SELECT TOP(1) *
FROM #nvarchar
WHERE ISJSON(x) = 1