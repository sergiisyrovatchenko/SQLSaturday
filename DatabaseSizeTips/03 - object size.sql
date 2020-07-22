SELECT 
	  o.[object_id]
	, s.name + '.' + o.name
	, o.[type]
	, i.total_rows
	, total_space = CAST(i.total_pages * 8. / 1024 AS DECIMAL(18,2))
	, used_space = CAST(i.used_pages * 8. / 1024 AS DECIMAL(18,2))
	, unused_space = CAST((i.total_pages - i.used_pages) * 8. / 1024 AS DECIMAL(18,2))
	, index_space = CAST(i.index_pages * 8. / 1024 AS DECIMAL(18,2))
	, data_space = CAST(data_pages * 8. / 1024 AS DECIMAL(18,2))
	, is_heap
	, i.[partitions]
	, i.[indexes]
FROM sys.objects o
JOIN sys.schemas s ON o.[schema_id] = s.[schema_id]
JOIN (
	SELECT
		  i.[object_id]
		, is_heap = MAX(CASE WHEN i.index_id = 0 THEN 1 ELSE 0 END)
		, total_pages = SUM(a.total_pages)
		, used_pages = SUM(a.used_pages)
		, index_pages = SUM(a.used_pages - CASE WHEN a.[type] != 1 THEN a.used_pages WHEN p.index_id IN (0, 1) THEN a.data_pages ELSE 0 END) 
		, data_pages = SUM(CASE WHEN a.[type] != 1 THEN a.used_pages WHEN p.index_id IN (0, 1) THEN a.data_pages END)
		, total_rows = SUM(CASE WHEN i.index_id IN (0, 1) AND a.[type] = 1 THEN p.[rows] END)
		, [partitions] = COUNT(DISTINCT p.partition_number)
		, [indexes] = COUNT(DISTINCT p.index_id)
	FROM sys.indexes i
	JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
	JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
	WHERE i.is_disabled = 0
		AND i.is_hypothetical = 0
	GROUP BY i.[object_id]
) i ON o.[object_id] = i.[object_id]
WHERE o.[type] IN ('V', 'U')
	AND o.is_ms_shipped = 0
ORDER BY i.total_pages DESC