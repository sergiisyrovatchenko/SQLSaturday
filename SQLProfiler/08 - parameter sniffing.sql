USE Users
GO

SET ARITHABORT OFF -- SSMS 2016: ON
SET NOCOUNT ON

SET STATISTICS IO, TIME ON

/*
    DBCC FREEPROCCACHE
*/

/*
exec sp_executesql N'SELECT COUNT(*), COUNT(DISTINCT FirstName)
                           FROM dbo.Users
                           WHERE City = @City',N'@City varchar(30)',@City='Berlin'

exec sp_executesql N'SELECT COUNT(*), COUNT(DISTINCT FirstName)
                           FROM dbo.Users
                           WHERE City = @City',N'@City varchar(30)',@City='Kharkiv'
*/

SELECT t.[text]
     , p.query_plan
     , s.query_hash
     , s.plan_handle
     , s.execution_count
     , s.last_logical_reads
     , s.last_elapsed_time
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) p
WHERE t.[text] LIKE '(@City varchar(30))SELECT COUNT(*), COUNT(DISTINCT FirstName)%'
GO

------------------------------------------------------

DECLARE @plan1 VARBINARY(64) = 
      , @plan2 VARBINARY(64) = 

SELECT seek.attribute
     , seek.[value]
     , scan.[value]
     , seek.is_cache_key
FROM sys.dm_exec_plan_attributes(@plan1) seek
JOIN sys.dm_exec_plan_attributes(@plan2) scan ON seek.attribute = scan.attribute
WHERE seek.[value] != scan.[value]
GO

------------------------------------------------------

DECLARE @val INT = 

SELECT 'DISABLE_DEF_CNST_CHK'    WHERE 1 & @val = 1 UNION ALL
SELECT 'IMPLICIT_TRANSACTIONS'   WHERE 2 & @val = 2 UNION ALL
SELECT 'CURSOR_CLOSE_ON_COMMIT'  WHERE 4 & @val = 4 UNION ALL
SELECT 'ANSI_WARNINGS'           WHERE 8 & @val = 8 UNION ALL
SELECT 'ANSI_PADDING'            WHERE 16 & @val = 16 UNION ALL
SELECT 'ANSI_NULLS'              WHERE 32 & @val = 32 UNION ALL
SELECT 'ARITHABORT'              WHERE 64 & @val = 64 UNION ALL
SELECT 'ARITHIGNORE'             WHERE 128 & @val = 128 UNION ALL
SELECT 'QUOTED_IDENTIFIER'       WHERE 256 & @val = 256 UNION ALL
SELECT 'NOCOUNT'                 WHERE 512 & @val = 512 UNION ALL
SELECT 'ANSI_NULL_DFLT_ON'       WHERE 1024 & @val = 1024 UNION ALL
SELECT 'ANSI_NULL_DFLT_OFF'      WHERE 2048 & @val = 2048 UNION ALL
SELECT 'CONCAT_NULL_YIELDS_NULL' WHERE 4096 & @val = 4096 UNION ALL
SELECT 'NUMERIC_ROUNDABORT'      WHERE 8192 & @val = 8192 UNION ALL
SELECT 'XACT_ABORT'              WHERE 16384 & @val = 16384

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUserCount
GO
CREATE PROCEDURE dbo.GetUserCount
(
      @City VARCHAR(30)
)
AS BEGIN

    SET NOCOUNT ON

    SELECT COUNT(*), COUNT(DISTINCT FirstName)
    FROM dbo.Users
    WHERE City = @City
    OPTION(RECOMPILE)

END
GO