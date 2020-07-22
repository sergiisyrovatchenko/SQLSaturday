USE CCI
GO

SELECT o.[object_id]
     , obj_name = s.[name] + '.' + o.[name]
     , i.total_rows
     , all_units = i.[type_desc]
     , total_space = CAST(i.total_pages * 8. / 1024 AS DECIMAL(18, 2))
     , data_space = CAST(data_pages * 8. / 1024 AS DECIMAL(18, 2))
     , index_space = CAST(i.index_pages * 8. / 1024 AS DECIMAL(18, 2))
FROM sys.objects o WITH(NOLOCK)
JOIN sys.schemas s WITH(NOLOCK) ON o.[schema_id] = s.[schema_id]
JOIN (
    SELECT i.[object_id]
         , a.[type_desc]
         , total_pages = SUM(a.total_pages)
         , index_pages = SUM(a.used_pages - CASE WHEN a.[type] != 1 THEN a.used_pages WHEN p.index_id IN (0, 1) THEN a.data_pages ELSE 0 END) 
         , data_pages = SUM(CASE WHEN a.[type] != 1 THEN a.used_pages WHEN p.index_id IN (0, 1) THEN a.data_pages END)
         , total_rows = SUM(CASE WHEN i.index_id IN (0, 1) THEN p.[rows] END)
    FROM sys.indexes i WITH(NOLOCK)
    JOIN sys.partitions p WITH(NOLOCK) ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
    JOIN sys.allocation_units a WITH(NOLOCK) ON p.[partition_id] = a.container_id
    WHERE a.total_pages > 0
    GROUP BY i.[object_id]
           , a.[type_desc]
) i ON o.[object_id] = i.[object_id]
WHERE o.[type] IN ('V', 'U')
ORDER BY i.total_pages DESC

SELECT i.[object_id]
     , row_group_id
     , delta_store_hobt_id
     , state_description
     , total_rows
     , deleted_rows
     , size_in_bytes / (1024.0 * 1024.0)
     , SUM(size_in_bytes) OVER (PARTITION BY i.[object_id]) / 8192 * 8. / 1024
FROM sys.indexes i WITH(NOLOCK)
CROSS APPLY sys.fn_column_store_row_groups(i.[object_id]) s
WHERE i.[type] IN (5, 6)
ORDER BY i.[object_id]
       , s.row_group_id

---------------------------------------------------------------------------------------------------------

ALTER INDEX CCI ON dbo.tCCI REBUILD
ALTER INDEX CCI ON dbo.tCCIArch REBUILD

---------------------------------------------------------------------------------------------------------

SELECT COL_NAME(p.[object_id], s.column_id)
     , s.column_id
     , s.dictionary_id
     , s.entry_count
     , s.on_disk_size / (1024.0 * 1024.0)
     , SUM(s.on_disk_size) OVER () / (1024.0 * 1024.0)
FROM sys.column_store_dictionaries s
JOIN sys.partitions p ON p.hobt_id = s.hobt_id
WHERE p.[object_id] = OBJECT_ID('dbo.tCCI')
ORDER BY s.column_id

SELECT COL_NAME(p.[object_id], s.column_id)
     , s.column_id
     , s.segment_id
     , s.encoding_type
     , s.row_count
     , s.primary_dictionary_id
     , s.min_data_id
     , s.max_data_id
     , s.on_disk_size / (1024.0 * 1024.0)
     , SUM(s.on_disk_size / (1024.0 * 1024.0)) OVER ()
FROM sys.column_store_segments s
JOIN sys.partitions p ON p.hobt_id = s.hobt_id
WHERE p.[object_id] = OBJECT_ID('dbo.tCCI')
ORDER BY s.column_id
       , s.segment_id