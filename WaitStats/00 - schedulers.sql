SELECT *
FROM sys.dm_os_schedulers
WHERE [status] LIKE 'VISIBLE%'