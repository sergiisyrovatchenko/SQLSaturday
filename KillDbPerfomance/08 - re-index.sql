USE KillDB
GO

/*
    SELECT COUNT(1)
    FROM dbo.WorkTable
    WHERE RecordID != 4
*/

SELECT obj = CONCAT(s.[name], '.', o.[name])
     , inx = i.[name]
     , size = a.total_pages * 8. / 1024
     , p.[rows]
     , u.user_seeks
     , u.user_scans
     , u.user_lookups
     , u.user_updates
     , statistic = STATS_DATE(i.[object_id], i.index_id)
FROM sys.indexes i
JOIN sys.objects o ON i.[object_id] = o.[object_id]
JOIN sys.schemas s ON o.[schema_id] = s.[schema_id]
JOIN sys.partitions p ON i.[object_id] = p.[object_id]
                     AND i.index_id = p.index_id
LEFT JOIN (
    SELECT container_id, total_pages = SUM(total_pages)
    FROM sys.allocation_units
    GROUP BY container_id
) a ON p.[partition_id] = a.container_id
LEFT JOIN sys.dm_db_index_usage_stats u ON u.[object_id] = i.[object_id]
                                  AND u.index_id = i.index_id
                                  AND u.database_id = DB_ID()
WHERE o.is_ms_shipped = 0
ORDER BY a.total_pages DESC

/*
    DBCC SHOW_STATISTICS ('dbo.WorkTable', pk)
*/

/*
    ALTER INDEX pk ON dbo.WorkTable REBUILD
*/