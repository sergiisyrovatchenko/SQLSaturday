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