/*
    SELECT [name], [description]
    FROM sys.dm_xe_objects
    WHERE [name] LIKE N'wait_info%'

    SELECT map_key, map_value 
    FROM sys.dm_xe_map_values
    WHERE [name] = N'wait_types'
          AND (
               (map_key > 0 AND map_key < 22) -- LCK_*
            OR (map_key > 31 AND map_key < 38) -- LATCH_*
            OR (map_key > 47 AND map_key < 54) -- PAGELATCH_*
            OR (map_key > 63 AND map_key < 70) -- PAGEIOLATCH_*
            OR (map_key > 96 AND map_key < 100) -- IO
            OR map_key = 107 -- RESOURCE_SEMAPHORE
            OR map_key = 113 -- SOS_WORKER
            OR map_key = 120 -- SOS_SCHEDULER_YIELD
            OR map_key = 178 -- WRITELOG
            OR map_key = 186 -- CMEMTHREAD
            OR map_key = 187 -- CXPACKET
            OR map_key = 207 -- TRACEWRITE
            OR map_key IN (269, 283, 284) -- RESOURCE_SEMAPHORE_*
        )
*/

SET NOCOUNT ON

DECLARE @SQL NVARCHAR(MAX)
      , @Filter NVARCHAR(MAX)

SET @Filter = STUFF((
    SELECT ' AND wait_type != ' + CAST(map_key AS NVARCHAR(10))
    FROM sys.dm_xe_map_values
    WHERE [name] = N'wait_types'
        AND map_value IN (
            N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR',
            N'BROKER_TASK_STOP', N'BROKER_TO_FLUSH',
            N'BROKER_TRANSMITTER', N'CHECKPOINT_QUEUE',
            N'CHKPT', N'CLR_AUTO_EVENT',
            N'CLR_MANUAL_EVENT', N'CLR_SEMAPHORE',
            N'DBMIRROR_DBM_EVENT', N'DBMIRROR_EVENTS_QUEUE',
            N'DBMIRROR_WORKER_QUEUE', N'DBMIRRORING_CMD',
            N'DIRTY_PAGE_POLL', N'DISPATCHER_QUEUE_SEMAPHORE',
            N'EXECSYNC', N'FSAGENT',
            N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'FT_IFTSHC_MUTEX',
            N'HADR_CLUSAPI_CALL', N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
            N'HADR_LOGCAPTURE_WAIT', N'HADR_NOTIFICATION_DEQUEUE',
            N'HADR_TIMER_TASK', N'HADR_WORK_QUEUE',
            N'KSOURCE_WAKEUP', N'LAZYWRITER_SLEEP',
            N'LOGMGR_QUEUE', N'ONDEMAND_TASK_QUEUE',
            N'PWAIT_ALL_COMPONENTS_INITIALIZED',
            N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
            N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
            N'REQUEST_FOR_DEADLOCK_SEARCH', N'RESOURCE_QUEUE',
            N'SERVER_IDLE_CHECK', N'SLEEP_BPOOL_FLUSH',
            N'SLEEP_DBSTARTUP', N'SLEEP_DCOMSTARTUP',
            N'SLEEP_MASTERDBREADY', N'SLEEP_MASTERMDREADY',
            N'SLEEP_MASTERUPGRADED', N'SLEEP_MSDBSTARTUP',
            N'SLEEP_SYSTEMTASK', N'SLEEP_TASK',
            N'SLEEP_TEMPDBSTARTUP', N'SNI_HTTP_ACCEPT',
            N'SP_SERVER_DIAGNOSTICS_SLEEP', N'SQLTRACE_BUFFER_FLUSH',
            N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
            N'SQLTRACE_WAIT_ENTRIES', N'WAIT_FOR_RESULTS',
            N'WAITFOR', N'WAITFOR_TASKSHUTDOWN',
            N'WAIT_XTP_HOST_WAIT', N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG',
            N'WAIT_XTP_CKPT_CLOSE', N'XE_DISPATCHER_JOIN',
            N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT',
            N'HADRFS_IOMGR_IOCOMPLETION', N'LZW_SLEEP',
            N'FT_SCHEDULER_IDLE_WAIT', N'SSB_TASK_STOP',
            N'NETWORK_IO'
        )
    FOR XML PATH('')), 1, 5, '')

SELECT @SQL = '
IF EXISTS(
    SELECT *
    FROM sys.server_event_sessions
    WHERE [name] = N''WaitStats''
) DROP EVENT SESSION [WaitStats] ON SERVER

CREATE EVENT SESSION WaitStats ON SERVER 
    ADD EVENT sqlos.wait_info (
        ACTION (sqlserver.database_id, sqlserver.session_id, sqlserver.sql_text, sqlserver.plan_handle)
        WHERE opcode = 1
            AND (' + @Filter + ')
            AND sqlserver.session_id > 50
            AND duration > 0
            --AND sqlserver.session_id = ...
    )
ADD TARGET package0.ring_buffer
WITH (
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 1 SECONDS
)
ALTER EVENT SESSION WaitStats ON SERVER STATE = START
'

PRINT @SQL
EXEC sys.sp_executesql @SQL

----------------------------------------------------

SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp

DECLARE @xml XML = (
        SELECT CAST(t.target_data AS XML).query('RingBufferTarget/event')
        FROM sys.dm_xe_session_targets t
        JOIN sys.dm_xe_sessions s ON s.[address] = t.event_session_address
        WHERE s.[name] = N'WaitStats'
            AND t.target_name = N'ring_buffer'
    )

SELECT db = DB_NAME(ISNULL(
                x.value('(data[@name="database_id"]/value/text())[1]', 'SMALLINT'),
                x.value('(action[@name="database_id"]/value/text())[1]', 'SMALLINT')))
     , time_event     = DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), x.value('(event/@timestamp)[1]', 'DATETIME'))
     , session_id     = x.value('(action[@name="session_id"]/value/text())[1]', 'SMALLINT')
     , wait_type      = x.value('(data[@name="wait_type"]/text/text())[1]', 'NVARCHAR(4000)')
     , wait_time_ms   = x.value('(data[@name="duration"]/value/text())[1]', 'BIGINT')
     , wait_signal_ms = x.value('(data[@name="signal_duration"]/value/text())[1]', 'BIGINT')
     , sql_text       = x.value('(action[@name="sql_text"]/value/text())[1]', 'NVARCHAR(4000)')
     , plan_handle    = CONVERT(VARBINARY(64), '0x' + x.value('(action[@name="plan_handle"]/value/text())[1]', 'VARCHAR(4000)'), 1)
INTO #temp
FROM @xml.nodes('event') t(x)
OPTION(MAXDOP 1, OPTIMIZE FOR(@xml = NULL))

SELECT q.query_plan, t.*
FROM #temp t
OUTER APPLY sys.dm_exec_query_plan(t.plan_handle) q

SELECT session_id
     , wait_type
     , wait_time = CAST(SUM(wait_time_ms) / 1000. AS DECIMAL(18,4))
     , wait_resource = CAST(SUM(wait_time_ms - wait_signal_ms) / 1000. AS DECIMAL(18,4))
     , wait_signal = CAST(SUM(wait_signal_ms) / 1000. AS DECIMAL(18,4))
     , waiting_tasks_count = COUNT_BIG(*)
FROM #temp
GROUP BY session_id
       , wait_type
ORDER BY session_id
       , wait_time DESC

----------------------------------------------------

SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#temp') IS NOT NULL
    DROP TABLE #temp
GO

CREATE TABLE #temp (
      db SYSNAME
    , time_event DATETIME
    , session_id SMALLINT
    , wait_type NVARCHAR(4000)
    , wait_time_ms BIGINT
    , wait_signal_ms BIGINT
    , sql_text NVARCHAR(4000)
)

DECLARE @event NVARCHAR(4000) = 'XEvent_WS'
DECLARE @xem_path NVARCHAR(4000) = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\Log\' + @event + '.xel'
DECLARE @spid VARCHAR(10) = 63

DECLARE @SQL NVARCHAR(MAX) = '
IF EXISTS(
    SELECT *
    FROM sys.server_event_sessions
    WHERE [name] = N''' + @event + '''
) DROP EVENT SESSION [' + @event + '] ON SERVER

CREATE EVENT SESSION [' + @event + '] ON SERVER
ADD EVENT sqlos.wait_info (
    ACTION (sqlserver.database_id, sqlserver.session_id, sqlserver.sql_text, sqlserver.plan_handle)
    WHERE duration > 0
        AND opcode = 1
        AND sqlserver.session_id = ' + @spid + '
)
ADD TARGET package0.event_file (
    SET
        filename = N''' + @xem_path + ''',
        max_file_size = 2,
        max_rollover_files = 0
)
WITH (
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 1 SECONDS
)
ALTER EVENT SESSION [' + @event + '] ON SERVER STATE = START
'

--PRINT @SQL
EXEC sys.sp_executesql @SQL

DECLARE @address VARBINARY(8) = (
        SELECT [address]
        FROM sys.dm_xe_sessions
        WHERE name = @event
    )

DECLARE @path SYSNAME = (
        SELECT CAST(target_data AS XML).value('(EventFileTarget/File/@name)[1]', 'SYSNAME')
        FROM sys.dm_xe_session_targets
        WHERE event_session_address = @address
            AND target_name = N'event_file'
    )

DECLARE @event_data XML
      , @file_offset BIGINT
      , @file_name NVARCHAR(260)
      , @file_offset_prev BIGINT

WHILE 1=1 BEGIN

    SET @file_offset_prev = ISNULL(@file_offset, 0)

    SELECT @event_data = event_data
         , @file_name = [file_name]
         , @file_offset = file_offset
    FROM sys.fn_xe_file_target_read_file(@path, @xem_path, @file_name, @file_offset)

    IF @file_offset != @file_offset_prev BEGIN

        INSERT INTO #temp
        OUTPUT INSERTED.*
        SELECT db = DB_NAME(ISNULL(
                        x.value('(data[@name="database_id"]/value/text())[1]', 'SMALLINT'),
                        x.value('(action[@name="database_id"]/value/text())[1]', 'SMALLINT')))
             , time_event     = DATEADD(hh, DATEDIFF(hh, GETUTCDATE(), CURRENT_TIMESTAMP), x.value('@timestamp', 'DATETIME'))
             , session_id     = x.value('(action[@name="session_id"]/value/text())[1]', 'SMALLINT')
             , wait_type      = x.value('(data[@name="wait_type"]/text/text())[1]', 'NVARCHAR(4000)')
             , wait_time_ms   = x.value('(data[@name="duration"]/value/text())[1]', 'BIGINT')
             , wait_signal_ms = x.value('(data[@name="signal_duration"]/value/text())[1]', 'BIGINT')
             , sql_text       = x.value('(action[@name="sql_text"]/value/text())[1]', 'NVARCHAR(4000)')
        FROM @event_data.nodes('event') t(x)
        OPTION(MAXDOP 1, OPTIMIZE FOR(@event_data = NULL))

        RAISERROR ('', 10, 1) WITH NOWAIT

    END

    WAITFOR DELAY '00:00:01'

END

SELECT *
FROM #temp

/*
    IF EXISTS(
        SELECT *
        FROM sys.server_event_sessions
        WHERE [name] = N'XEvent_WS'
    ) DROP EVENT SESSION [XEvent_WS] ON SERVER
*/