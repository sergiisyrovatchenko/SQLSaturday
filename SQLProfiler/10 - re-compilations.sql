USE Users
GO

SET NOCOUNT ON

/*
    DBCC FREEPROCCACHE
*/

DROP PROCEDURE IF EXISTS dbo.GetLastUsers
GO
CREATE PROCEDURE dbo.GetLastUsers
(
    @Count INT
)
AS BEGIN

    CREATE TABLE #users (
          UserID INT NOT NULL --PRIMARY KEY
    )

    ALTER TABLE #users ADD PRIMARY KEY (UserID)

    INSERT INTO #users (UserID)
    SELECT TOP(@Count) UserID
    FROM dbo.Users
    ORDER BY UserID DESC

    SELECT City, COUNT(*)
    FROM dbo.Users
    WHERE UserID IN (SELECT u.UserID FROM #users u)
    GROUP BY City

END
GO

------------------------------------------------------

EXEC dbo.GetLastUsers @Count = 1
EXEC dbo.GetLastUsers @Count = 100
EXEC dbo.GetLastUsers @Count = 10000
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetLastUsers
GO
CREATE PROCEDURE dbo.GetLastUsers
(
    @Count INT
)
AS BEGIN

    DECLARE @users TABLE (UserID INT NOT NULL PRIMARY KEY)

    INSERT INTO @users (UserID)
    SELECT TOP(@Count) UserID
    FROM dbo.Users
    ORDER BY UserID DESC

    --DBCC TRACEON(2453)

    SELECT City, COUNT(*)
    FROM dbo.Users
    WHERE UserID IN (SELECT u.UserID FROM @users u)
    GROUP BY City
    --OPTION(RECOMPILE)

    --DBCC TRACEOFF(2453)

END
GO

------------------------------------------------------

EXEC dbo.GetLastUsers @Count = 1
EXEC dbo.GetLastUsers @Count = 100
EXEC dbo.GetLastUsers @Count = 10000
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetLastUsers
GO
CREATE PROCEDURE dbo.GetLastUsers
(
    @Count INT
)
AS BEGIN

    SELECT TOP(@Count) *
    FROM dbo.Users
    ORDER BY UserID DESC
    OPTION(OPTIMIZE FOR (@Count = 1))

END
GO