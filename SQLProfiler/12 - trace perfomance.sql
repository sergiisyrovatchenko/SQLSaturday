/*
    SQL Server Wait Types Library
    https://www.sqlskills.com/help/waits/
*/

/*
    DBCC SQLPERF("sys.dm_os_wait_stats", CLEAR)
*/

SELECT wait_type
     , wait_time = wait_time_ms / 1000.
     , wait_resource = (wait_time_ms - signal_wait_time_ms) / 1000.
     , wait_signal = signal_wait_time_ms / 1000.
     , waiting_tasks_count
FROM sys.dm_os_wait_stats
WHERE [wait_type] IN (
        'TRACEWRITE', 'OLEDB', 'SQLTRACE_LOCK',
        'SQLTRACE_FILE_BUFFER', 'SQLTRACE_FILE_WRITE_IO_COMPLETION'
    )
ORDER BY wait_time_ms DESC

------------------------------------------------------

SELECT id
     , is_default
     , IIF([status] = 0, 'STOPPED', 'RUNNING')
     , start_time
     , event_count
FROM sys.traces

------------------------------------------------------

DECLARE @id INT

DECLARE trace CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
    SELECT id
    FROM sys.traces
    WHERE is_default != 1

OPEN trace

FETCH NEXT FROM trace INTO @id

WHILE @@fetch_status = 0 BEGIN

    EXEC sys.sp_trace_setstatus @traceid = @id, @status = 0
    EXEC sys.sp_trace_setstatus @traceid = @id, @status = 2

    FETCH NEXT FROM trace INTO @id
END

CLOSE trace
DEALLOCATE trace