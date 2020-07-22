/*
    Common causes for this include:
        Missing indexes causing large sort or hash join operations
        Out-of-date statistics causing incorrectly large cardinality estimates
        Large numbers of concurrent queries running that all require memory to run
        Many of the queries have incorrectly large memory grant requirements
*/

USE AdventureWorks2014
GO

SELECT *
FROM Sales.SalesOrderHeader
WHERE DueDate > ShipDate
ORDER BY OrderDate DESC

-- SQL Query Stress: 100 * 4

------------------------------------------------------------------

SELECT *
FROM sys.dm_exec_query_resource_semaphores

SELECT r.session_id
     , r.scheduler_id
     , r.dop
     , r.requested_memory_kb
     , r.granted_memory_kb
     , r.required_memory_kb
     , r.used_memory_kb
     , r.max_used_memory_kb
     , r.query_cost
     , t.[text]
     , p.query_plan
FROM sys.dm_exec_query_memory_grants r
OUTER APPLY sys.dm_exec_sql_text(r.[sql_handle]) t
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) p