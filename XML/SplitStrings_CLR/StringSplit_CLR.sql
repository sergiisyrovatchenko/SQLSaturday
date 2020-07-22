USE tempdb
GO

EXEC sys.sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO

EXEC sys.sp_configure 'clr enabled', 1
GO
RECONFIGURE WITH OVERRIDE
GO

CREATE ASSEMBLY StringSplit_CLR FROM 'D:\PROJECT\XML\SplitStrings_CLR\StringSplit_CLR.dll'
    WITH PERMISSION_SET = SAFE
GO

CREATE FUNCTION dbo.StringSplit_CLR
(
      @List NVARCHAR(MAX)
    , @Delimiter NVARCHAR(255)
)
RETURNS TABLE (Item NVARCHAR(4000))
    EXTERNAL NAME StringSplit_CLR.UserDefinedFunctions.StringSplit_CLR;
GO

