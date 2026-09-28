USE 

SELECT p.[size_mb]
     , [index] = i.[name]
     , [columns] = STUFF((
           SELECT ', ' + COL_NAME(ic.[object_id], ic.[column_id]) + IIF(ic.[is_descending_key] = 1, ' (D)', '')
           FROM sys.index_columns ic WITH(NOLOCK)
           WHERE ic.[object_id] = i.[object_id]
               AND ic.[index_id] = i.[index_id]
               AND ic.[is_included_column] = 0
           FOR XML PATH ('')
       ), 1, 2, '')
     , [included] = STUFF((
           SELECT ', ' + COL_NAME(ic.[object_id], ic.[column_id])
           FROM sys.index_columns ic WITH(NOLOCK)
           WHERE ic.[object_id] = i.[object_id]
               AND ic.[index_id] = i.[index_id]
               AND ic.[is_included_column] = 1
           FOR XML PATH ('')
       ), 1, 2, '')
     , i.[type_desc]
     , [pk]          = i.[is_primary_key]
     , [unique]      = i.[is_unique]
     , [disabled]    = i.[is_disabled]
     , [seeks]       = us.[user_seeks]
     , [scans]       = us.[user_scans]
     , [lookups]     = us.[user_lookups]
     , [updates]     = us.[user_updates]
     , [last_read]   = us.[last_read]
     , [last_write]  = us.[last_user_update]
     , [filter]      = i.[filter_definition]
FROM sys.indexes i WITH(NOLOCK)
JOIN sys.objects o WITH(NOLOCK) ON i.[object_id] = o.[object_id]
LEFT JOIN (
    SELECT p.[object_id]
         , p.[index_id]
         , [size_mb] = CAST(SUM(a.[total_pages]) * 8. / 1024 AS DECIMAL(18, 2))
    FROM sys.partitions p WITH(NOLOCK) 
    JOIN sys.allocation_units a WITH(NOLOCK) ON p.[partition_id] = a.[container_id]
    GROUP BY p.[object_id]
           , p.[index_id]
) p ON p.[object_id] = i.[object_id] AND p.[index_id] = i.[index_id]
LEFT JOIN (
    SELECT *, [last_read] = (
               SELECT MAX([last_action])
               FROM (VALUES ([last_user_seek]), ([last_user_scan]), ([last_user_lookup])) t ([last_action])
           )
    FROM sys.dm_db_index_usage_stats WITH(NOLOCK)
    WHERE [database_id] = DB_ID()
) us ON us.[index_id] = i.[index_id]
    AND i.[object_id] = us.[object_id]
WHERE o.[type] IN ('U', 'V')
    AND i.[object_id] = OBJECT_ID('t1')

