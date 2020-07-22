SELECT database_id
     , DB_NAME(database_id)
     , [type_desc]
     , [name]
     , physical_name
FROM sys.master_files
WHERE database_id BETWEEN 1 AND 4

------------------------------------------------------------------

USE [master]
GO

ALTER DATABASE model MODIFY FILE (NAME = modeldev, FILENAME = 'D:\DATABASE\SQL_2016\DATA\model.mdf')
ALTER DATABASE model MODIFY FILE (NAME = modellog, FILENAME = 'D:\DATABASE\SQL_2016\LOG\modellog.ldf')
GO

ALTER DATABASE msdb MODIFY FILE (NAME = MSDBData, FILENAME = 'D:\DATABASE\SQL_2016\DATA\MSDBData.mdf')
ALTER DATABASE msdb MODIFY FILE (NAME = MSDBLog,  FILENAME = 'D:\DATABASE\SQL_2016\LOG\MSDBLog.ldf')
GO

/*
    C:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\DATA\model.mdf
    C:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\DATA\modellog.ldf
    C:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\DATA\MSDBData.mdf
    C:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\DATA\MSDBLog.ldf

    move to:

    D:\DATABASE\SQL_2016\DATA\
    D:\DATABASE\SQL_2016\LOG\
*/

------------------------------------------------------------------

/*
    -dC:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\DATA\master.mdf
    -lC:\Program Files\Microsoft SQL Server\MSSQL13.SQL_2016\MSSQL\DATA\mastlog.ldf

    rename to:

    -dD:\DATABASE\SQL_2016\DATA\master.mdf
    -lD:\DATABASE\SQL_2016\LOG\mastlog.ldf
*/
