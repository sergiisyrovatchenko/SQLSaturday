USE Users
GO

SET NOCOUNT ON

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsers
GO
CREATE PROCEDURE dbo.GetUsers
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    SELECT UserID
    FROM dbo.Users
    WHERE (CreatedDate = @Date AND @Date IS NOT NULL AND @City IS NULL)
        OR (City = @City AND @Date IS NULL AND @City IS NOT NULL)

END
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsersDyn
GO
CREATE PROCEDURE dbo.GetUsersDyn
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @sql NVARCHAR(MAX) = '
        SELECT UserID
        FROM dbo.Users
        WHERE ' +
        CASE
            WHEN @Date IS NOT NULL AND @City IS NULL THEN 'CreatedDate = @Date'
            WHEN @Date IS NULL AND @City IS NOT NULL THEN 'City = @City'
        END

    EXEC sys.sp_executesql @sql
                         , N'@Date DATE, @City VARCHAR(30)'
                         , @Date = @Date, @City = @City

END
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsersDyn2
GO
CREATE PROCEDURE dbo.GetUsersDyn2
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    DECLARE @sql NVARCHAR(MAX) = '
        SELECT UserID
        FROM dbo.Users
        WHERE ' +
        CASE
            WHEN @Date IS NOT NULL AND @City IS NULL THEN 'CreatedDate = ''' + CONVERT(VARCHAR(10), @Date, 112) + ''''
            WHEN @Date IS NULL AND @City IS NOT NULL THEN 'City = ''' + @City + ''''
        END

    EXEC(@sql)

END
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsersIF
GO
CREATE PROCEDURE dbo.GetUsersIF
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    IF @Date IS NOT NULL AND @City IS NULL BEGIN
        SELECT UserID
        FROM dbo.Users
        WHERE CreatedDate = @Date
    END
    ELSE IF @Date IS NULL AND @City IS NOT NULL BEGIN
        SELECT UserID
        FROM dbo.Users
        WHERE City = @City
    END

END
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsersUnion
GO
CREATE PROCEDURE dbo.GetUsersUnion
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    SELECT UserID
    FROM dbo.Users
    WHERE CreatedDate = @Date
        AND @Date IS NOT NULL AND @City IS NULL

    UNION ALL

    SELECT UserID
    FROM dbo.Users
    WHERE City = @City
        AND @Date IS NULL AND @City IS NOT NULL

END
GO

------------------------------------------------------

DROP PROCEDURE IF EXISTS dbo.GetUsersRecompile
GO
CREATE PROCEDURE dbo.GetUsersRecompile
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    SELECT UserID
    FROM dbo.Users
    WHERE (CreatedDate = @Date AND @Date IS NOT NULL AND @City IS NULL)
        OR (City = @City AND @Date IS NULL AND @City IS NOT NULL)
    OPTION(RECOMPILE)

END
GO

------------------------------------------------------

/*
    DBCC FREEPROCCACHE

    DROP INDEX IF EXISTS IX_City_CreatedDate ON dbo.Users
    GO
    CREATE NONCLUSTERED INDEX IX_City_CreatedDate ON dbo.Users (City, CreatedDate)
    GO

    DROP INDEX IF EXISTS IX_CreatedDate ON dbo.Users
    GO
    CREATE NONCLUSTERED INDEX IX_CreatedDate ON dbo.Users (CreatedDate)
    GO

    DROP INDEX IF EXISTS IX_City ON dbo.Users
    GO
    CREATE NONCLUSTERED INDEX IX_City ON dbo.Users (City)
    GO
*/

------------------------------------------------------

SET STATISTICS IO, TIME ON

PRINT 'dbo.GetUsers'
EXEC dbo.GetUsers @City = 'Kharkiv'
EXEC dbo.GetUsers @Date = '20170320'

PRINT 'dbo.GetUsersDyn'
EXEC dbo.GetUsersDyn @City = 'Kharkiv'
EXEC dbo.GetUsersDyn @Date = '20170320'

PRINT 'dbo.GetUsersDyn2'
EXEC dbo.GetUsersDyn2 @City = 'Kharkiv'
EXEC dbo.GetUsersDyn2 @Date = '20170320'

PRINT 'dbo.GetUsersIF'
EXEC dbo.GetUsersIF @City = 'Kharkiv'
EXEC dbo.GetUsersIF @Date = '20170320'

PRINT 'dbo.GetUsersUnion'
EXEC dbo.GetUsersUnion @City = 'Kharkiv'
EXEC dbo.GetUsersUnion @Date = '20170320'

PRINT 'dbo.GetUsersRecompile'
EXEC dbo.GetUsersRecompile @City = 'Kharkiv'
EXEC dbo.GetUsersRecompile @Date = '20170320'

SET STATISTICS IO, TIME OFF
GO

------------------------------------------------------

ALTER PROCEDURE dbo.GetUsers
(
      @Date DATE = NULL
    , @City VARCHAR(30) = NULL
)
AS BEGIN

    SET NOCOUNT ON

    IF @Date IS NOT NULL AND @City IS NULL BEGIN
        SELECT UserID
        FROM dbo.Users
        WHERE CreatedDate = @Date
    END
    ELSE IF @Date IS NULL AND @City IS NOT NULL BEGIN
        SELECT UserID
        FROM dbo.Users
        WHERE City = @City
    END

END