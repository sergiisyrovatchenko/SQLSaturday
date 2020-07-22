DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS

------------------------------------------------------------------

USE AdventureWorks2014
GO
SELECT TOP(1) e.BusinessEntityID, p.*
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate > '19800101'
GO
SELECT TOP(1) e.BusinessEntityID, p.*
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate > '20000101'
GO

------------------------------------------------------------------

SELECT p.usecounts
     , p.cacheobjtype
     , p.objtype
     , p.size_in_bytes
     , t.[text]
FROM sys.dm_exec_cached_plans p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) t
WHERE t.[text] LIKE '%SELECT TOP(1) %'

------------------------------------------------------------------

USE [master]
GO

EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure 'optimize for ad hoc workloads', 1 -- 2008+
GO
RECONFIGURE WITH OVERRIDE
GO

------------------------------------------------------------------

USE AdventureWorks2014
GO

SELECT TOP(1) * FROM HumanResources.Employee
GO 10

SELECT p.usecounts
     , p.cacheobjtype
     , p.objtype
     , p.size_in_bytes
     , t.[text]
FROM sys.dm_exec_cached_plans p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) t
WHERE t.[text] LIKE '%SELECT TOP(1) %'

------------------------------------------------------------------

SELECT cache_type = objtype
     , total_plans = COUNT_BIG(*)
     , total_mb = CAST(SUM(size_in_bytes) * 1. / 1048576 AS DECIMAL(18, 2))
     , total_plans_1 = COUNT_BIG(CASE WHEN usecounts = 1 THEN 1 END)
     , total_mb_1 = CAST(SUM(
          CASE WHEN usecounts = 1
              THEN size_in_bytes
              ELSE 0
          END * 1. ) / 1048576 AS DECIMAL(18,2))
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY total_mb DESC

SELECT SUM(size_in_bytes * 1.) / 1048576
FROM sys.dm_exec_cached_plans

SELECT TOP(10) [type], SUM(pages_kb)
FROM sys.dm_os_memory_clerks
GROUP BY [type]
ORDER BY 2 DESC