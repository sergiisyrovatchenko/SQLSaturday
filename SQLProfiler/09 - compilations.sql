USE Users
GO

SET NOCOUNT ON

/*
    DBCC FREEPROCCACHE
*/

DROP PROCEDURE IF EXISTS dbo.IsUserExists
GO
CREATE PROCEDURE dbo.IsUserExists
(
      @UserID INT
)
AS BEGIN

    DECLARE @sql NVARCHAR(MAX) = '
        SELECT IIF(EXISTS(
            SELECT *
            FROM dbo.Users
            WHERE UserID = ' + CAST(@UserID AS VARCHAR(10)) + '), 1, 0)'

    EXEC(@sql)

END
GO

------------------------------------------------------

EXEC dbo.IsUserExists @UserID = 1
EXEC dbo.IsUserExists @UserID = 2
GO

SELECT t.[text]
     , p.query_plan
     , s.query_hash
     , s.plan_handle
     , s.execution_count
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) p
WHERE t.[text] LIKE '%SELECT IIF(EXISTS(%'
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.IsUserExists
GO
CREATE PROCEDURE dbo.IsUserExists
(
      @UserID INT
)
AS BEGIN

    SELECT IIF(EXISTS(
        SELECT 1
        FROM dbo.Users
        WHERE UserID = @UserID), 1, 0)

END
GO

------------------------------------------------------

EXEC dbo.IsUserExists @UserID = 1
EXEC dbo.IsUserExists @UserID = 2
GO

SELECT t.[text]
     , p.query_plan
     , s.query_hash
     , s.plan_handle
     , s.execution_count
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.[sql_handle]) t
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) p
WHERE p.objectid = OBJECT_ID('dbo.IsUserExists')