SELECT session_id
     , wait_type
     , wait_time = CAST(wait_time_ms / 1000. AS DECIMAL(18,4))
     , wait_resource = CAST((wait_time_ms - signal_wait_time_ms) / 1000. AS DECIMAL(18,4))
     , wait_signal = CAST(signal_wait_time_ms / 1000. AS DECIMAL(18,4))
     , wait_time_percent = CAST(100. * wait_time_ms / SUM(wait_time_ms) OVER (PARTITION BY session_id) AS DECIMAL(18,2))
     , waiting_tasks_count
     , max_wait_time = CAST(max_wait_time_ms / 1000. AS DECIMAL(18,4))
FROM sys.dm_exec_session_wait_stats -- 2016+
WHERE session_id != @@spid
    AND wait_time_ms > 0
ORDER BY SUM(wait_time_ms) OVER (PARTITION BY session_id) DESC
       , wait_time_ms DESC