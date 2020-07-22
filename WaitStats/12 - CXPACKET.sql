/*
    Check:
        Execution plans
        Statistics
        Cost threshold for parallelism
        Degree of parallelism
        DBCC CHECKDB without MAXPOD
*/

/*
    USE [master]
    GO

    EXEC sys.sp_configure 'show advanced options', '1'
    GO
    RECONFIGURE WITH OVERRIDE
    GO

    EXEC sys.sp_configure 'cost threshold for parallelism', '15' --5
    GO
    EXEC sys.sp_configure 'max degree of parallelism', '2' -- 0
    GO
    RECONFIGURE WITH OVERRIDE
    GO
*/

USE Refactoring
GO

SELECT WorkOutID
     , OvertimeHours = SUM(CASE WHEN WorkFactorCD = 'overtime_hours' THEN [Value] END)
     , NightHours =    SUM(CASE WHEN WorkFactorCD = 'night_hours'    THEN [Value] END)
     , EveningHours =  SUM(CASE WHEN WorkFactorCD = 'evening_hours'  THEN [Value] END)
     , HolidayHours =  SUM(CASE WHEN WorkFactorCD = 'holiday_hours'  THEN [Value] END)
FROM Labour.WorkOutFactor
WHERE WorkFactorCD IN (N'overtime_hours', N'night_hours', N'evening_hours', N'holiday_hours')
GROUP BY WorkOutID
--OPTION(MAXDOP 1)
--OPTION(RECOMPILE, QUERYTRACEON 8649)

/*
    USE ... -- 2016+
    GO

    ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 1
*/