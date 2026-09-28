USE 

SET NOCOUNT ON
SET STATISTICS IO, TIME OFF

IF OBJECT_ID('tempdb.dbo.#objects') IS NOT NULL
    DROP TABLE #objects

CREATE TABLE #objects (
      [object_id] INT PRIMARY KEY
    , [name]      SYSNAME
    , [schema_id] INT
)

INSERT INTO #objects ([object_id], [name], [schema_id])
SELECT [object_id]
     , [name]
     , [schema_id]
FROM sys.objects o WITH(NOLOCK)
WHERE [type] IN ('U', 'V')
    AND [schema_id] NOT IN (ISNULL(SCHEMA_ID('api'), -1))

IF OBJECT_ID('tempdb.dbo.#partitions') IS NOT NULL
    DROP TABLE #partitions

SELECT [object_id]
     , [index_id]
     , [partition_id]
     , [rows]
INTO #partitions
FROM sys.partitions WITH(NOLOCK)
WHERE [object_id] IN (SELECT o.[object_id] FROM #objects o)

IF OBJECT_ID('tempdb.dbo.#sizes') IS NOT NULL
    DROP TABLE #sizes

CREATE TABLE #sizes (
      [object_id]   INT PRIMARY KEY
    , [total_pages] BIGINT
    , [used_pages]  BIGINT
    , [data_pages]  BIGINT
    , [index_pages] BIGINT
    , [rows]        BIGINT
)

INSERT INTO #sizes ([object_id], [total_pages], [used_pages], [data_pages], [index_pages], [rows])
SELECT TOP(150) p.[object_id]
              , SUM(a.[total_pages])
              , SUM(a.[used_pages])
              , SUM(CASE WHEN p.[index_id] IN (0, 1) THEN a.[total_pages] END)
              , SUM(CASE WHEN p.[index_id] > 1 THEN a.[total_pages] END)
              , SUM(CASE WHEN p.[index_id] IN (0, 1) AND a.[type] = 1 THEN p.[rows] END)
FROM #partitions p
JOIN sys.allocation_units a WITH(NOLOCK) ON p.[partition_id] = a.[container_id]
GROUP BY p.[object_id]
ORDER BY SUM(a.[total_pages]) DESC

SELECT o.[object_id]
     , [sch_name] = s.[name]
     , [obj_name] = o.[name]
     , i.[rows]
     , [total_space]  = CAST(i.[total_pages] * 8. / 1024 AS DECIMAL(18, 2))
     , [data_pages]   = CAST(i.[data_pages] * 8. / 1024 AS DECIMAL(18, 2))
     , [index_pages]  = CAST(i.[index_pages] * 8. / 1024 AS DECIMAL(18, 2))
     , [used_space]   = CAST(i.[used_pages] * 8. / 1024 AS DECIMAL(18, 2))
     , [unused_space] = CAST((i.[total_pages] - i.[used_pages]) * 8. / 1024 AS DECIMAL(18, 2))
FROM #objects o
JOIN sys.schemas s WITH(NOLOCK) ON o.[schema_id] = s.[schema_id]
JOIN #sizes i ON o.[object_id] = i.[object_id]
ORDER BY total_space DESC

