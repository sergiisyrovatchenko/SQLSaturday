USE AdventureWorks2014
GO

SELECT *
FROM sys.database_scoped_configurations

/*
    ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 1
*/

/*
      ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = ON
    or
      -T9481
    or
      Compatibility level <= 2012
*/

/*
      ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = OFF
    or
      -T4136
    or
      OPTIMIZE FOR UNKNOWN
*/

/*
      ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = ON
    or
      -T4199
*/

/*
    ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
*/

DECLARE @id INT = DB_ID()
DBCC FLUSHPROCINDB(@id)

SELECT db = DB_NAME(t.[dbid])
     , plan_cache_kb = SUM(size_in_bytes / 1024)
FROM sys.dm_exec_cached_plans p
CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) t
WHERE t.[dbid] < 32767
GROUP BY t.[dbid]
ORDER BY plan_cache_kb DESC