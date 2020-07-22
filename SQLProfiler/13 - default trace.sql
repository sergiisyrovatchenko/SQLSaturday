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

/*
    https://habrahabr.ru/post/277053/
*/

SELECT StartTime
     , Duration = Duration / 1000
     , t.DatabaseName
     , [FileName]
     , Category = c.[name]
     , [Event] = e.[name]
     , t.TextData
     , t.ApplicationName
     , t.LoginName
     , t.ObjectName
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable([path], DEFAULT) t
JOIN sys.trace_events e ON t.EventClass = e.trace_event_id
JOIN sys.trace_categories c ON e.category_id = c.category_id
WHERE i.is_default = 1
    --AND t.EventClass IN (
    --        92, -- Data File Auto Grow
    --        93  -- Log File Auto Grow
    --    )