USE tempdb
GO

DBCC FREEPROCCACHE

SET NOCOUNT ON

IF OBJECT_ID('v') IS NOT NULL
	DROP VIEW v
GO
IF OBJECT_ID('t') IS NOT NULL
	DROP TABLE t
GO

SELECT TOP(100000) ID = ROW_NUMBER() OVER(ORDER BY 1/0), t1.*
INTO t
FROM [master].dbo.spt_values t1
CROSS JOIN [master].dbo.spt_values t2
GO

CREATE CLUSTERED INDEX pk ON t (ID)
GO

-------------------------------------------------------------------

SELECT [type], COUNT_BIG(*)
FROM t
WHERE low IS NULL
GROUP BY [type]
GO

CREATE NONCLUSTERED INDEX ix ON t (low) INCLUDE ([type]) --WHERE low IS NULL
GO

-------------------------------------------------------------------

SET STATISTICS IO ON

SELECT [type], COUNT(*)
FROM t
WHERE low IS NULL
GROUP BY [type]
GO

SELECT [type], COUNT(*)
FROM t WITH(INDEX(ix))
WHERE low IS NULL
GROUP BY [type]
GO

-------------------------------------------------------------------

CREATE VIEW v
WITH SCHEMABINDING
AS
	SELECT [type], cnt = COUNT_BIG(*)
	FROM dbo.t
	WHERE low IS NULL
	GROUP BY [type]
GO

CREATE UNIQUE CLUSTERED INDEX pk ON v ([type])
GO

SELECT [type], cnt = COUNT_BIG(*)
FROM t
WHERE low IS NULL
GROUP BY [type]
OPTION(EXPAND VIEWS)

SELECT [type], cnt = COUNT_BIG(*)
FROM t
WHERE low IS NULL
GROUP BY [type]

SELECT * FROM v
GO

-------------------------------------------------------------------

SELECT
	  i.[object_id]
	, OBJECT_NAME(i.[object_id])
	, i.name
	, i.type_desc
	, a.total_pages, a.used_pages
	, p.[rows]
FROM sys.indexes i
JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
JOIN (
	SELECT
		  container_id
		, total_pages = SUM(total_pages)
		, used_pages = SUM(used_pages)
	FROM sys.allocation_units
	GROUP BY container_id
) a ON p.[partition_id] = a.container_id
WHERE i.[object_id] IN (OBJECT_ID('v'), OBJECT_ID('t'))
