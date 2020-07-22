USE Refactoring
GO

SET STATISTICS TIME ON

SELECT SUM(CASE WHEN WorkFactorCD = 'overtime_hours' THEN [Value] ELSE 0 END) +
       SUM(CASE WHEN WorkFactorCD = 'night_hours'    THEN [Value] ELSE 0 END) +
       SUM(CASE WHEN WorkFactorCD = 'evening_hours'  THEN [Value] ELSE 0 END) +
       SUM(CASE WHEN WorkFactorCD = 'holiday_hours'  THEN [Value] ELSE 0 END)
FROM Labour.WorkOutFactor
WHERE WorkFactorCD IN (N'overtime_hours', N'night_hours', N'evening_hours', N'holiday_hours')

SELECT SUM([Value])
FROM Labour.WorkOutFactor
WHERE WorkFactorCD IN ('overtime_hours', 'night_hours', 'evening_hours', 'holiday_hours')

SET STATISTICS TIME OFF

-- SQL Query Stress: 50 * 4

------------------------------------------------------------------

SELECT r.session_id
     , s.[program_name]
     , t.[text]
     , DB_NAME(r.database_id)
     , p.query_plan
     , r.cpu_time
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.[sql_handle]) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p
WHERE s.is_user_process = 1
    AND r.last_wait_type = N'SOS_SCHEDULER_YIELD'
ORDER BY r.session_id

------------------------------------------------------------------

USE AdventureWorks2014
GO

SET STATISTICS IO ON

SELECT BusinessEntityID
FROM Person.Person
WHERE BusinessEntityID * 2 = 10000

SELECT BusinessEntityID
FROM Person.Person
WHERE BusinessEntityID = 5000

------------------------------------------------------------------

SELECT CustomerID, AccountNumber
FROM Sales.Customer
WHERE AccountNumber = N'AW00000009'

SELECT CustomerID, AccountNumber
FROM Sales.Customer
WHERE AccountNumber = 'AW00000009'

------------------------------------------------------------------

DECLARE @NationalIDNumber INT = 30845
SELECT BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = @NationalIDNumber
GO

DECLARE @NationalIDNumber NVARCHAR(15) = '30845'
SELECT BusinessEntityID
FROM HumanResources.Employee
WHERE NationalIDNumber = @NationalIDNumber
GO

------------------------------------------------------------------

SELECT AddressLine1
FROM Person.[Address]
WHERE SUBSTRING(AddressLine1, 1, 3) = '100'

SELECT AddressLine1
FROM Person.[Address]
WHERE AddressLine1 LIKE '100%'