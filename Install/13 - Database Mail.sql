USE [master]
GO

EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO

EXEC sys.sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE WITH OVERRIDE
GO

/*
    mail: kh.sql.server@gmail.com
    pass: Test1Test
    smtp: smtp.gmail.com
    port: 587
*/

EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder = 1
                                       , @databasemail_profile = N'---------'
                                       , @use_databasemail = 1

/*
    823 -- may indicate hardware problems or system problems in SQL Server
    824 -- IO error SQL Server cannot read the data
    825 -- SQL Server read the data but not with first attempt after trying couple of attempts
    829 -- page has been marked RestorePending

    833 -- I/O requests taking longer than 15 seconds to complete on file
    https://blogs.msdn.microsoft.com/sqlsakthi/2011/02/09/troubleshooting-sql-server-io-requests-taking-longer-than-15-seconds-io-stalls-disk-latency/
*/