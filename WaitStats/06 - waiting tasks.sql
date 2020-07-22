SELECT session_id
     , wait_time = CAST(wait_duration_ms / 1000. AS DECIMAL(18,4))
     , wait_type
     , blocking_session_id
     , resource_description
FROM sys.dm_os_waiting_tasks
WHERE session_id > 50
    AND session_id != @@spid
ORDER BY session_id

SELECT s.spid
     , s.blocked
     , wait_time = CAST(s.waittime / 1000. AS DECIMAL(18,4))
     , s.lastwaittype
     , s.waitresource
     , [db_name] = DB_NAME(s.[dbid])
     , [status] = UPPER(s.[status])
     , s.[program_name]
     , t.[text]
FROM sys.sysprocesses s
OUTER APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
WHERE s.spid > 50
    AND s.spid != @@spid