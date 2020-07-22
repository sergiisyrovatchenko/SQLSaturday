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
GO

USE ...

SET STATISTICS TIME ON

SELECT *
FROM dbo.LogEntries l
JOIN dbo.Reviews r ON l.ReviewId = r.Id
JOIN dbo.Comments c ON l.CommentId = c.Id
JOIN dbo.Users u ON l.UserId = u.Id
GO 10

SET STATISTICS TIME OFF

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

------------------------------------------------------------------

USE AdventureWorks2014
GO

DBCC DROPCLEANBUFFERS

SET STATISTICS IO, TIME ON
GO

DECLARE @handler INT
      , @rowCount INT

EXEC sp_executesql N'
exec sp_cursoropen @handler OUT, N''SELECT * FROM Person.Person ORDER BY BusinessEntityID'', 1, 1, @rowCount OUT'
                 , N'@handler INT OUTPUT, @rowCount INT OUTPUT'
                 , @handler = @handler OUTPUT
                 , @rowCount = @rowCount OUTPUT

EXEC sp_executesql N'exec sp_cursorfetch @handler, 16, @rowid, @rowcount;'
                 , N'@handler INT, @rowid INT, @rowcount INT'
                 , @handler = @handler
                 , @rowid = 101
                 , @rowCount = 100

--EXEC sp_executesql N'exec sp_cursorclose @handle'
--                 , N'@handle INT'
--                 , @handle = @handler
GO

SELECT *
FROM (
    SELECT *, RowNum = ROW_NUMBER() OVER (ORDER BY BusinessEntityID)
    FROM Person.Person
) t
WHERE t.RowNum BETWEEN 101 AND 200
GO

SELECT *
FROM Person.Person
ORDER BY BusinessEntityID
Offset 100 ROW
FETCH FIRST 100 ROWS ONLY
GO

SET STATISTICS IO, TIME OFF

