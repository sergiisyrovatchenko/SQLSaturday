DBCC FREEPROCCACHE

USE AdventureWorks2012
GO

SELECT SalesOrderID, OrderDate, [Status], TerritoryID
FROM Sales.SalesOrderHeader
WHERE OrderDate = '20050701'

-------------------------------------------------------------------

-- Missing index

--CREATE NONCLUSTERED INDEX missing_index_SalesOrderHeader
--	ON [Sales].[SalesOrderHeader] ([OrderDate])

SELECT
	  s.avg_user_impact
	, OBJECT_SCHEMA_NAME(d.[object_id])
	, OBJECT_NAME(d.[object_id])
	, d.equality_columns
	, d.inequality_columns
	, d.included_columns
	, s.unique_compiles
	, s.user_seeks
	, s.user_scans
	, s.last_user_seek
	, s.last_user_scan
FROM sys.dm_db_missing_index_groups g
JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
JOIN sys.dm_db_missing_index_details d ON g.index_handle = d.index_handle
WHERE d.database_id = DB_ID()

-------------------------------------------------------------------

-- Database Engine Tuning Advisor

--CREATE NONCLUSTERED INDEX [_dta_index_SalesOrderHeader_11_1266103551__K3_1_6_13]
--	ON [Sales].[SalesOrderHeader] ([OrderDate])
--	INCLUDE ([SalesOrderID], [Status], [TerritoryID])

-------------------------------------------------------------------

IF INDEXPROPERTY(OBJECT_ID('Sales.SalesOrderHeader'), 'IX_OrderDate_H', 'IndexID') IS NOT NULL
	DROP INDEX IX_OrderDate_H ON Sales.SalesOrderHeader
GO

CREATE NONCLUSTERED INDEX IX_OrderDate_H
	ON Sales.SalesOrderHeader(OrderDate)
	--INCLUDE (TerritoryID, [Status])
	WITH (STATISTICS_ONLY = 1)

SELECT DB_ID(), i.[object_id], i.index_id, i.name, STATS_DATE(i.[object_id], i.index_id)
FROM sys.indexes i
WHERE i.[object_id] = OBJECT_ID('Sales.SalesOrderHeader')
	AND i.is_hypothetical = 1

-------------------------------------------------------------------

DBCC AUTOPILOT(0, 11, 1266103551, 13)
GO
SET AUTOPILOT ON
GO
SELECT SalesOrderID, OrderDate, [Status], TerritoryID
FROM Sales.SalesOrderHeader
WHERE OrderDate = '20050701'
GO
SET AUTOPILOT OFF
GO

SELECT SalesOrderID, OrderDate, [Status], TerritoryID
FROM Sales.SalesOrderHeader
WHERE OrderDate = '20050701'

-------------------------------------------------------------------

IF INDEXPROPERTY(OBJECT_ID('Sales.SalesOrderHeader'), 'IX_OrderDate', 'IndexID') IS NOT NULL
	DROP INDEX IX_OrderDate ON Sales.SalesOrderHeader
GO

CREATE NONCLUSTERED INDEX IX_OrderDate
	ON Sales.SalesOrderHeader(OrderDate)
	INCLUDE (TerritoryID, [Status])
GO

ALTER INDEX IX_OrderDate ON Sales.SalesOrderHeader DISABLE
GO

SELECT SalesOrderID, OrderDate, [Status], TerritoryID
FROM Sales.SalesOrderHeader
WHERE OrderDate = '20050701'

SELECT
	  i.[object_id]
	, OBJECT_SCHEMA_NAME(i.[object_id])
	, o.name
	, i.name
	, a.total_pages * 8. / 1024
	, i.is_disabled
	, i.is_hypothetical
	, u.user_seeks
	, u.user_scans
	, u.user_lookups
	, u.user_updates
	, u.last_action
FROM sys.indexes i
JOIN sys.objects o ON i.[object_id] = o.[object_id]
LEFT JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
LEFT JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
LEFT JOIN (
	SELECT *,
		last_action = (
			SELECT MAX(last_action)
			FROM (
				VALUES (last_user_seek), (last_user_scan), (last_user_lookup), (last_user_update)
			) t(last_action)
		)
	FROM sys.dm_db_index_usage_stats
	WHERE database_id = DB_ID()
) u ON u.[object_id] = i.[object_id] AND u.index_id = i.index_id
WHERE i.name LIKE '_dta_index_%'
	OR i.name LIKE 'missing_index_%'
	OR i.is_disabled = 1
	OR i.is_hypothetical = 1
ORDER BY a.total_pages DESC


