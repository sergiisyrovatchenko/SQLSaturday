USE tempdb
GO

IF OBJECT_ID('t1') IS NOT NULL
	DROP TABLE t1
GO
CREATE TABLE t1 (
	A INT,
	B DATETIME,
	C CHAR(10),
	D FLOAT,
	E BIT,
	F INT
)
 
CREATE CLUSTERED INDEX pk ON t1 (A)
 
CREATE NONCLUSTERED INDEX ix1 ON t1 (B, E)
 
CREATE NONCLUSTERED INDEX ix2 ON t1 (E)

CREATE NONCLUSTERED INDEX ix3 ON t1 (C) INCLUDE (F)

CREATE NONCLUSTERED INDEX ix4 ON t1 (D) INCLUDE (F)

SELECT
	  OBJECT_SCHEMA_NAME(o.[object_id]) + N'.' + o.name
	, index_name = i.name
	, dub_index_name = d.name
	, COL_NAME(ic.[object_id], ic.column_id)
FROM sys.objects o
JOIN sys.indexes i ON o.[object_id] = i.[object_id]
JOIN sys.index_columns ic ON ic.[object_id] = i.[object_id]
	AND ic.index_id = i.index_id   
CROSS APPLY (
	SELECT i2.index_id, i2.name
	FROM sys.indexes i2
	JOIN sys.index_columns ic2 on ic2.[object_id] = i2.[object_id]
		AND ic2.index_id = i2.index_id
	WHERE i2.[object_id] = i.[object_id]
		AND i2.index_id > i.index_id
		AND ic2.column_id = ic.column_id
	) d   
WHERE o.[type] IN ('U', 'V')
	AND o.is_ms_shipped = 0

-------------------------------------------------------------------

SELECT
	  index_name = i.name
	, [index_columns] = STUFF((
		SELECT ', ' + COL_NAME(ic.[object_id], ic.column_id) + IIF(ic.is_descending_key = 1, ' (DESC)', '')
		FROM sys.index_columns ic
		WHERE ic.[object_id] = i.[object_id]
			AND ic.index_id = i.index_id
			AND ic.is_included_column = 0
		FOR XML PATH('')), 1, 2, '')
	, included_columns = STUFF((
		SELECT ', ' + COL_NAME(ic.[object_id], ic.column_id)
		FROM sys.index_columns ic
		WHERE ic.[object_id] = i.[object_id]
			AND ic.index_id = i.index_id
			AND ic.is_included_column = 1
		FOR XML PATH('')), 1, 2, '') 
	, i.type_desc
	, i.is_unique
	, i.is_primary_key
	, i.fill_factor
	, i.is_hypothetical
	, i.is_disabled
	, i.has_filter
	, us.user_seeks
	, us.user_scans
	, us.user_lookups
	, us.user_updates
	, us.last_action
FROM sys.indexes i
JOIN sys.objects o ON i.[object_id] = o.[object_id]
LEFT JOIN (
	SELECT *, last_action = (
				SELECT MAX(last_action)
				FROM (VALUES (last_user_seek), (last_user_scan), (last_user_lookup), (last_user_update)) t(last_action)
			)
	FROM sys.dm_db_index_usage_stats
	WHERE database_id = DB_ID()
) us ON us.index_id = i.index_id AND i.[object_id] = us.[object_id]
WHERE o.[type] IN ('U', 'V')
	AND o.is_ms_shipped = 0
	AND i.[object_id] = OBJECT_ID('t1')


