SET NOCOUNT ON

USE AdventureWorks2014
GO

DROP TABLE IF EXISTS dbo.LogJSON
GO

CREATE TABLE dbo.LogJSON (
      DatabaseLogID INT
    , InfoJSON NVARCHAR(MAX) NOT NULL
    , CONSTRAINT pk PRIMARY KEY (DatabaseLogID)
)
GO

INSERT INTO dbo.LogJSON
SELECT DatabaseLogID
     , InfoJSON = (
            SELECT PostTime, DatabaseUser, [Event], ObjectName = [Schema] + '.' + [Object]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
         )
FROM dbo.DatabaseLog

------------------------------------------------------

IF EXISTS(
    SELECT *
    FROM sys.fulltext_catalogs
    WHERE [name] = 'JSON_FTC'
)
    DROP FULLTEXT CATALOG JSON_FTC
GO

CREATE FULLTEXT CATALOG JSON_FTC WITH ACCENT_SENSITIVITY = ON AUTHORIZATION dbo
GO

IF EXISTS (
        SELECT *
        FROM sys.fulltext_indexes
        WHERE [object_id] = OBJECT_ID(N'dbo.LogJSON')
    ) BEGIN
    ALTER FULLTEXT INDEX ON dbo.LogJSON DISABLE
    DROP FULLTEXT INDEX ON dbo.LogJSON
END
GO

CREATE FULLTEXT INDEX ON dbo.LogJSON (InfoJSON) KEY INDEX pk ON JSON_FTC
GO

------------------------------------------------------

SELECT *
FROM dbo.LogJSON
--CROSS APPLY OPENJSON(InfoJSON) t
WHERE CONTAINS(InfoJSON, 'Person.Person')