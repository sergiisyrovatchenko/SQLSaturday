USE AdventureWorks2014
GO

BEGIN TRANSACTION

UPDATE Person.ContactType
SET ModifiedDate = GETDATE()

/*
    COMMIT
*/