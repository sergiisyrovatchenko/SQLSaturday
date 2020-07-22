USE Refactoring
GO

IF EXISTS(SELECT 1 FROM sys.indexes WHERE [object_id] = OBJECT_ID('Labour.WorkOut') AND name = 'ix')
	DROP INDEX ix ON Labour.WorkOut
GO

SET STATISTICS IO ON
SET STATISTICS TIME ON

SELECT
	  TimeSheetDate
	, EmployeeID
	, SUM(WorkHours)
FROM Labour.WorkOut
WHERE WorkShiftCD IS NULL AND WorkHours IS NOT NULL
GROUP BY TimeSheetDate, EmployeeID
OPTION(MAXDOP 1)
GO

-------------------------------------------------------------------

CREATE NONCLUSTERED INDEX ix
	ON Labour.WorkOut (TimeSheetDate, EmployeeID)
	INCLUDE (WorkHours, WorkShiftCD) -- filter
	WHERE WorkShiftCD IS NULL AND WorkHours IS NOT NULL
GO

SELECT
	  TimeSheetDate
	, EmployeeID
	, SUM(WorkHours)
FROM Labour.WorkOut
WHERE WorkShiftCD IS NULL AND WorkHours IS NOT NULL
GROUP BY TimeSheetDate, EmployeeID
OPTION(MAXDOP 1)
GO