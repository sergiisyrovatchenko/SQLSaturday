/*
    USE [master]
    GO

    ALTER DATABASE [tempdb]
        MODIFY FILE (NAME = N'tempdev', SIZE = 64MB, FILEGROWTH = 64MB)
    GO
    ALTER DATABASE [tempdb]
        MODIFY FILE (NAME = N'templog', SIZE = 64MB, FILEGROWTH = 64MB)
    GO
*/

SET NOCOUNT ON

IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL
    DROP TABLE #t
GO

CREATE TABLE #t (
      c1 INT DEFAULT 1
    , c2 NCHAR(4000) DEFAULT N'дефолтный бред'
)

DECLARE @i INT = 1

WHILE @i <= 10000 BEGIN

    INSERT INTO #t DEFAULT VALUES
    IF @i % 500 = 0 CHECKPOINT
    SET @i += 1

END
GO

------------------------------------------------------------------

SELECT StartTime
     , Duration = Duration / 1000
     , [FileName]
     , GrowType = CASE WHEN EventClass = 92 THEN 'DATA' ELSE 'LOG' END
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable([path], DEFAULT) t
WHERE t.EventClass IN (
            92, -- Data File Auto Grow
            93  -- Log File Auto Grow
        )
    AND i.is_default = 1
    AND t.DatabaseName = 'tempdb'

SELECT GrowType = CASE WHEN EventClass = 92 THEN 'DATA' ELSE 'LOG' END
     , GrowCount = COUNT(1)
     , Duration = SUM(Duration) / 1000
FROM sys.traces i
CROSS APPLY sys.fn_trace_gettable([path], DEFAULT) t
WHERE t.EventClass IN (92, 93) 
    AND i.is_default = 1
    AND t.DatabaseID = DB_ID('tempdb')
GROUP BY EventClass

------------------------------------------------------------------

SELECT d.[type_desc]
     , d.[name]
     , d.physical_name
     , current_size_mb = ROUND(d.size * 8. / 1024, 0)
     , initial_size_mb = ROUND(m.size * 8. / 1024, 0) 
     , auto_grow =
         CASE WHEN d.is_percent_growth = 1
             THEN CAST(d.growth AS VARCHAR(10)) + '%'
             ELSE CAST(ROUND(d.growth * 8. / 1024, 0) AS VARCHAR(10)) + 'MB'
         END
FROM tempdb.sys.database_files d
JOIN sys.master_files m ON d.[file_id] = m.[file_id]
WHERE m.database_id = DB_ID('tempdb')

/*
    USE [master]
    GO

    ALTER DATABASE [tempdb]
        ADD FILE (NAME = N'tempdev2', FILENAME = N'D:\DATABASE\SQL_2016\TEMP\tempdev2.ndf',
                  SIZE = 64MB, FILEGROWTH = 64MB)
    GO
    ALTER DATABASE [tempdb]
        ADD FILE (NAME = N'tempdev3', FILENAME = N'D:\DATABASE\SQL_2016\TEMP\tempdev3.ndf',
                  SIZE = 64MB, FILEGROWTH = 64MB)
    GO
    ALTER DATABASE [tempdb]
        ADD FILE (NAME = N'tempdev4', FILENAME = N'D:\DATABASE\SQL_2016\TEMP\tempdev4.ndf',
                  SIZE = 64MB, FILEGROWTH = 64MB)
    GO
*/
