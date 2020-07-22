SELECT sqlserver_start_time = (SELECT sqlserver_start_time FROM sys.dm_os_sys_info)
     , wait_stats_started = DATEADD(ss, -wait_time_ms / 1000, GETDATE())
     , time_since_cleared =
            CASE
                WHEN wait_time_ms < 1000
                    THEN CAST(wait_time_ms AS VARCHAR(15)) + 'ms'
                WHEN wait_time_ms BETWEEN 1000 AND 60000
                    THEN CAST(wait_time_ms / 1000 AS VARCHAR(15)) + ' seconds'
                WHEN wait_time_ms BETWEEN 60001 AND 3600000
                    THEN CAST(wait_time_ms / 60000 AS VARCHAR(15)) + ' minutes'
                WHEN wait_time_ms BETWEEN 3600001 AND 86400000
                    THEN CAST(wait_time_ms / 3600000 AS VARCHAR(15)) + ' hours'
                WHEN wait_time_ms > 86400000
                    THEN CAST(wait_time_ms / 86400000 AS VARCHAR(15)) + ' days'
            END
FROM sys.dm_os_wait_stats
WHERE wait_type = 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'