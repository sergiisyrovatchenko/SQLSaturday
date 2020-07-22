SET NOCOUNT ON

USE AdventureWorks2014
GO

SET STATISTICS TIME ON

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey')
SELECT BusinessEntityID
FROM Person.Person
WHERE Demographics.value('(IndividualSurvey/Gender)[1]', 'CHAR(1)') = 'F'
OPTION(MAXDOP 1)

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey')
SELECT BusinessEntityID
FROM Person.Person
CROSS APPLY Demographics.nodes('IndividualSurvey/Gender[. = "F"]') t(c)
OPTION(MAXDOP 1)

;WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey')
SELECT BusinessEntityID
FROM Person.Person
WHERE Demographics.exist('IndividualSurvey/Gender[. = "F"]') = 1
OPTION(MAXDOP 1)

SET STATISTICS TIME OFF

/*
    CPU time = 297 ms, elapsed time = 457 ms

    CPU time = 15 ms, elapsed time = 396 ms

    CPU time = 0 ms, elapsed time = 192 ms
*/