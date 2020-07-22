USE [master]
GO

SELECT id
     , is_default
     , IIF([status] = 0, 'STOPPED', 'RUNNING')
     , start_time
     , event_count
FROM sys.traces

/*
    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO

    EXEC sys.sp_configure 'default trace enabled', 0
    GO
    RECONFIGURE WITH OVERRIDE
    GO
*/

------------------------------------------------------------------

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