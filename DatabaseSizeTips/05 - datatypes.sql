USE tempdb
GO

IF OBJECT_ID('WorkOut1') IS NOT NULL
	DROP TABLE WorkOut1
GO
CREATE TABLE WorkOut1 (
	  DateOut DATETIME -- 8
	, EmployeeID BIGINT -- 8
	, DepartmentCD NCHAR(10) -- 20
	, WorkShiftCD NVARCHAR(10) -- 2 * len
	, WorkHours DECIMAL(24,2) -- 13
	, IsFullDay SMALLINT -- 2
	, CONSTRAINT PK_WorkOut1 PRIMARY KEY (DateOut, EmployeeID)
)
GO

IF OBJECT_ID('WorkOut2') IS NOT NULL
	DROP TABLE WorkOut2
GO
CREATE TABLE WorkOut2 (
	  DateOut SMALLDATETIME -- 4 (date - 3)
	, EmployeeID INT -- 4
	, DepartmentCD NVARCHAR(10) -- len
	, WorkShiftCD VARCHAR(10) -- len
	, WorkHours DECIMAL(8,2) -- 5
	, IsFullDay BIT NOT NULL -- 1
	, CONSTRAINT PK_WorkOut2 PRIMARY KEY (DateOut, EmployeeID)
)
GO

UPDATE STATISTICS WorkOut1 WITH ROWCOUNT = 10000000
UPDATE STATISTICS WorkOut2 WITH ROWCOUNT = 10000000
GO

-------------------------------------------------------------------

SELECT * FROM WorkOut1
SELECT * FROM WorkOut2
