/*
    USE tempdb
    GO

    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE
    GO

    EXEC sys.sp_configure 'clr strict security', 0
    GO
    RECONFIGURE WITH OVERRIDE
    GO

    EXEC sys.sp_configure 'clr enabled', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO

    CREATE ASSEMBLY FormatJSON_CLR FROM 'D:\PROJECT\JSON\FormatJSON_CLR\FormatJSON_CLR.dll'
        WITH PERMISSION_SET = SAFE
    GO

    DROP FUNCTION IF EXISTS dbo.FormatJSON_CLR
    GO

    CREATE FUNCTION dbo.FormatJSON_CLR
    (
        @JSON NVARCHAR(MAX)
    )
    RETURNS NVARCHAR(MAX) AS
        EXTERNAL NAME FormatJSON_CLR.[Json].FormatJson;
    GO
*/

USE tempdb
GO

DECLARE @json NVARCHAR(MAX) = '{"event":{"event_name":"SQL Saturday Kharkiv #780","event_date":"September 2018","speaker":{"fullname":"Sergey Syrovatchenko","email":"sergey.syrovatchenko@gmail.com","blog":"https://habrahabr.ru/users/AlanDenton"},"program":[{"name":"XML & JSON v2.0"}]}}'

SELECT @json
     , dbo.FormatJSON_CLR(@json)
     , CAST((SELECT dbo.FormatJSON_CLR(@json) FOR XML PATH('')) AS XML)