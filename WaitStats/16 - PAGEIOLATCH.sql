USE Refactoring
GO

SET STATISTICS IO ON

DBCC DROPCLEANBUFFERS

SELECT COUNT_BIG(*)
FROM Labour.WorkOut WITH(INDEX(0))
OPTION(MAXDOP 1)

/*
    Occurs when a task is waiting on a latch for a buffer that is in an I/O request
    Long waits may indicate problems with the disk subsystem
    Index Scan instead of Index Seek

    PLE!
*/