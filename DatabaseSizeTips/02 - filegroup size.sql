SELECT
	  s.[file_id]
	, file_group = d.name
	, s.name
	, d.is_default
	, s.physical_name
	, size = CAST(s.size * 8. / 1024 AS DECIMAL(18,2))
	, space_used = CAST(t.space_used * 8. / 1024 AS DECIMAL(18,2))
	, free_space = CAST((s.size - t.space_used) * 8. / 1024 AS DECIMAL(18,2))
	, used_percent = CAST(t.space_used * 100. / s.size AS DECIMAL(18,2))
	, s.max_size
	, s.growth
	, s.is_percent_growth
FROM sys.database_files s
LEFT JOIN sys.data_spaces d on d.data_space_id = s.data_space_id
CROSS APPLY (
	SELECT space_used = FILEPROPERTY(s.name, 'SpaceUsed')
) t
ORDER BY s.size DESC