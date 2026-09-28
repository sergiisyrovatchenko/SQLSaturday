USE 

SELECT query_sql_text = TRY_CAST('<?query --' + CHAR(13) + t.query_sql_text + CHAR(13) + '--?>' AS XML)
     , [object_id] = OBJECT_NAME(q.[object_id])
     , i.start_time
     , s.execution_type_desc
     , s.count_executions
     , avg_duration = CAST(s.avg_duration / 1000 AS BIGINT)
     , min_duration = s.min_duration / 1000
     , [max_duration] = s.[max_duration] / 1000
     --, query_plan = TRY_CAST(p.query_plan AS XML)
FROM sys.query_store_runtime_stats_interval i WITH(NOLOCK)
JOIN sys.query_store_runtime_stats s WITH(NOLOCK) ON i.runtime_stats_interval_id = s.runtime_stats_interval_id
JOIN sys.query_store_plan p WITH(NOLOCK) ON s.plan_id = p.plan_id
JOIN sys.query_store_query q WITH(NOLOCK) ON p.query_id = q.query_id
JOIN sys.query_store_query_text t WITH(NOLOCK) ON q.query_text_id = t.query_text_id
WHERE i.start_time >= '20210119' --AND i.start_time < '20210120'
    AND s.execution_type IN (3,4)
    --AND t.query_sql_text LIKE '%SalesOrder%'
    --AND s.count_executions > 1
ORDER BY i.start_time