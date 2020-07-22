BACKUP DATABASE [model] TO DISK = 'NUL' 
GO

DBCC TRACEON (3226, -1)
GO

BACKUP DATABASE [model] TO DISK = 'NUL' 
GO
BACKUP DATABASE [model] TO DISK = 'Q:\model.bak'
GO

DBCC TRACEOFF (3226, -1)
GO

EXEC sys.xp_readerrorlog 0, 1, N'BACKUP'

/*
    EXEC sys.sp_cycle_errorlog
*/



