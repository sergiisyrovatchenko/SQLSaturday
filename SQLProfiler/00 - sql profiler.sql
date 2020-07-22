/*
    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE
    GO

    EXEC sys.sp_configure 'xp_cmdshell', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO
*/

DECLARE @id INT

EXEC sys.sp_trace_create @id OUTPUT, 2, N'X:\MyTrace'

-- RPC:Completed
EXEC sys.sp_trace_setevent @id, 10, 1, 1
EXEC sys.sp_trace_setevent @id, 10, 10, 1
EXEC sys.sp_trace_setevent @id, 10, 6, 1
EXEC sys.sp_trace_setevent @id, 10, 11, 1
EXEC sys.sp_trace_setevent @id, 10, 12, 1
EXEC sys.sp_trace_setevent @id, 10, 13, 1
EXEC sys.sp_trace_setevent @id, 10, 14, 1
EXEC sys.sp_trace_setevent @id, 10, 15, 1
EXEC sys.sp_trace_setevent @id, 10, 16, 1
EXEC sys.sp_trace_setevent @id, 10, 17, 1
EXEC sys.sp_trace_setevent @id, 10, 18, 1
EXEC sys.sp_trace_setevent @id, 10, 48, 1

-- SQL:BatchCompleted
EXEC sys.sp_trace_setevent @id, 12, 1, 1
EXEC sys.sp_trace_setevent @id, 12, 11, 1
EXEC sys.sp_trace_setevent @id, 12, 6, 1
EXEC sys.sp_trace_setevent @id, 12, 10, 1
EXEC sys.sp_trace_setevent @id, 12, 12, 1
EXEC sys.sp_trace_setevent @id, 12, 13, 1
EXEC sys.sp_trace_setevent @id, 12, 14, 1
EXEC sys.sp_trace_setevent @id, 12, 15, 1
EXEC sys.sp_trace_setevent @id, 12, 16, 1
EXEC sys.sp_trace_setevent @id, 12, 17, 1
EXEC sys.sp_trace_setevent @id, 12, 18, 1
EXEC sys.sp_trace_setevent @id, 12, 48, 1

/*
    SELECT * FROM sys.trace_columns
*/

DECLARE @spid INT = @@spid
EXEC sys.sp_trace_setfilter @id, 12, 1, 1, @spid -- SPID <> ...
--EXEC sys.sp_trace_setfilter @id, 10, 1, 7, N'Microsoft SQL Server Management Studio%' -- ApplicationName NOT LIKE ...

DECLARE @duration BIGINT = 1000
EXEC sys.sp_trace_setfilter @id, 13, 0, 4, @duration -- Duration > 1ms

EXEC sys.sp_trace_setstatus @id, 1 -- start
GO

------------------------------------------------------

SELECT SPID
     , TextData
     , ApplicationName
     , CPU
     , Duration = Duration / 1000.
     , Reads
     , Writes
     , EndTime
FROM (
    SELECT TOP(1) [path]
    FROM sys.traces
    WHERE [path] LIKE N'X:\MyTrace%'
) t
CROSS APPLY sys.fn_trace_gettable(t.[path], DEFAULT)

------------------------------------------------------

DECLARE @id INT = (
    SELECT TOP(1) id
    FROM sys.traces
    WHERE [path] LIKE N'X:\MyTrace%'
)
 
EXEC sys.sp_trace_setstatus @id, 0 -- pause
EXEC sys.sp_trace_setstatus @id, 2 -- stop and delete

EXEC sys.xp_cmdshell 'del X:\MyTrace.trc'