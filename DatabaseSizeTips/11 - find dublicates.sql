USE Refactoring
GO

SELECT t.WorkOutID
FROM (
	SELECT
		  WorkOutID
		, RowNum = ROW_NUMBER() OVER (
				PARTITION BY DateOut, EmployeeID
				ORDER BY WorkOutID DESC
			)
	FROM Labour.WorkOut
) t
WHERE t.RowNum > 1
OPTION(MAXDOP 1)

-------------------------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#t') IS NOT NULL
	DROP TABLE #t
GO
CREATE TABLE #t (WorkOutID INT PRIMARY KEY)
GO

INSERT INTO #t
SELECT MAX(WorkOutID)
FROM Labour.WorkOut
GROUP BY DateOut, EmployeeID
OPTION(MAXDOP 1)

SELECT w.WorkOutID
FROM Labour.WorkOut w
WHERE w.WorkOutID NOT IN (SELECT * FROM #t)
OPTION(MAXDOP 1)