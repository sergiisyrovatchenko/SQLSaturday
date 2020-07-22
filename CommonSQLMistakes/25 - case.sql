USE AdventureWorks2014
GO

SELECT BusinessEntityID
     , Gender
     , Gender =
            CASE Gender
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'Unknown'
            END
FROM HumanResources.Employee

SELECT BusinessEntityID
     , Gender
     , Gender =
            CASE
                WHEN Gender = 'M' THEN 'Male'
                WHEN Gender = 'F' THEN 'Female'
                ELSE 'Unknown'
            END
FROM HumanResources.Employee

------------------------------------------------------------------

IF OBJECT_ID('dbo.GetMailUrl') IS NOT NULL
    DROP FUNCTION dbo.GetMailUrl
GO

CREATE FUNCTION dbo.GetMailUrl
(
    @Email NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS BEGIN

    RETURN SUBSTRING(@Email, CHARINDEX('@', @Email) + 1, LEN(@Email))

END
GO

/*
    SQL Profiler: SQL:StmtStarting + SP:StmtCompleted
    XEvent:       sp_statement_starting + sp_statement_completed
*/

SELECT TOP(10) EmailAddressID
             , EmailAddress
             , CASE dbo.GetMailUrl(EmailAddress)
                   --WHEN 'brainacad.kh.ua' THEN 'Brain Academy'
                   --WHEN 'microsoft.com' THEN 'Microsoft'
                   WHEN 'adventure-works.com' THEN 'AdventureWorks'
               END
FROM Person.EmailAddress

SELECT EmailAddressID
     , EmailAddress
     , CASE MailUrl
           WHEN 'brainacad.kh.ua' THEN 'Brain Academy'
           WHEN 'microsoft.com' THEN 'Microsoft'
           WHEN 'adventure-works.com' THEN 'AdventureWorks'
       END
FROM (
    SELECT TOP(10) EmailAddressID
                 , EmailAddress
                 , MailUrl = dbo.GetMailUrl(EmailAddress)
    FROM Person.EmailAddress
) t

------------------------------------------------------------------

SELECT DISTINCT
    CASE
        WHEN Gender = 'M' THEN 'Male'
        WHEN Gender = 'M' THEN '...'
        WHEN Gender = 'M' THEN '......'
        WHEN Gender = 'F' THEN 'Female'
        WHEN Gender = 'F' THEN '...'
        ELSE 'Unknown'
    END
FROM HumanResources.Employee

------------------------------------------------------------------

DECLARE @i INT = 1
SELECT
    CASE WHEN @i = 1
        THEN 1
        ELSE 1/0
    END
GO

DECLARE @i INT = 1
SELECT
    CASE WHEN @i = 1
        THEN 1
        ELSE MIN(1/0)
    END