/*
    https://www.mytechmantra.com/LearnSQLServer/Identify-Deadlocks-in-SQL-Server-Using-Trace-Flag-1222-and-1204/
*/

------------------------------------------------------------------

USE AdventureWorks2014
GO

ALTER DATABASE AdventureWorks2014 SET ALLOW_SNAPSHOT_ISOLATION OFF
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO

SET NOCOUNT ON

WHILE 1=1 BEGIN

    DECLARE @ModifiedDate DATETIME
    SELECT TOP(1) @ModifiedDate = ModifiedDate
    FROM Person.Person
    WHERE LastName = 'Ivanov'

END

------------------------------------------------------------------

USE AdventureWorks2014
GO

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
GO

SET NOCOUNT ON

WHILE 1=1 BEGIN

    UPDATE Person.Person
    SET LastName = 'Petrov'
    WHERE BusinessEntityID = 13293

    UPDATE Person.Person
    SET LastName = 'Ivanov'
    WHERE BusinessEntityID = 13293

END