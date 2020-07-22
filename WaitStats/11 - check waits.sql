SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#dm_os_wait_stats') IS NOT NULL
    DROP TABLE #dm_os_wait_stats

SELECT wait_type
     , waiting_tasks_count
     , wait_time_ms
INTO #dm_os_wait_stats
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
    AND wait_time_ms > 0

----------------------------------------------------

USE Refactoring
GO

IF OBJECT_ID('dbo.temp') IS NOT NULL
    DROP TABLE temp
GO

SELECT WorkOutID
INTO dbo.temp
FROM Labour.WorkOutFactor
GROUP BY WorkOutID
HAVING COUNT_BIG(*) = 1

CREATE UNIQUE INDEX ix ON dbo.temp (WorkOutID)

DECLARE @WorkOutID INT

DECLARE cur CURSOR FOR
    SELECT TOP(10000) WorkOutID
    FROM dbo.temp

OPEN cur

FETCH NEXT FROM cur INTO @WorkOutID

WHILE @@FETCH_STATUS = 0 BEGIN

    DELETE FROM dbo.temp
    WHERE WorkOutID = @WorkOutID

    FETCH NEXT FROM cur INTO @WorkOutID

END

CLOSE cur
DEALLOCATE cur
GO

IF OBJECT_ID('dbo.temp') IS NOT NULL
    DROP TABLE temp
GO

----------------------------------------------------

SELECT s.wait_type
     , wait_time = CAST((s.wait_time_ms - ISNULL(t.wait_time_ms, 0)) / 1000. AS DECIMAL(18,4))
     , waiting_tasks = s.waiting_tasks_count - ISNULL(t.waiting_tasks_count, 0)
FROM sys.dm_os_wait_stats s
LEFT JOIN #dm_os_wait_stats t ON s.wait_type = t.wait_type
WHERE s.wait_time_ms - ISNULL(t.wait_time_ms, 0) > 0
    AND s.wait_type NOT IN (
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
        N'XE_DISPATCHER_WAIT', N'XE_TIMER_EVENT'
    )
ORDER BY wait_time DESC