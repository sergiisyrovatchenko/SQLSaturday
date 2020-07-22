USE tempdb
GO

SELECT [object_name], counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page Splits/sec'

SELECT
	  o.name
	, i.name
	, s.*
FROM sys.indexes i
JOIN sys.objects o ON i.[object_id] = o.[object_id]
JOIN (
	SELECT
		  s.[object_id]
		, s.index_id
		, page_split_for_index = SUM(s.leaf_allocation_count)
		, page_allocation_caused_by_pagesplit = SUM(s.nonleaf_allocation_count)
	FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) s
	GROUP BY
		  s.[object_id]
		, s.index_id
) s on s.index_id = i.index_id AND s.[object_id] = i.[object_id]
WHERE o.[type] = 'U'
ORDER BY page_split_for_index DESC



