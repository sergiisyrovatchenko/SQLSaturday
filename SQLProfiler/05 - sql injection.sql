USE Users
GO

SET NOCOUNT ON

DECLARE @UserID VARCHAR(100) = 1
--SET @UserID = '1; select ''hack'''

DECLARE @SQL NVARCHAR(MAX) = 'SELECT * FROM dbo.Users WHERE UserID = ' + @UserID

EXEC (@SQL)
EXEC sys.sp_executesql N'SELECT * FROM dbo.Users WHERE UserID = @UserID', N'@UserID INT', @UserID = @UserID