SELECT wait_type
     , wait_time_ms
     , signal_wait_time_ms
     , waiting_tasks_count
     , max_wait_time_ms
FROM sys.dm_os_wait_stats /* Azure: sys.dm_db_wait_stats */
WHERE wait_time_ms > 0
ORDER BY wait_type