USE AdventureWorks2014
GO

DECLARE @BusinessEntityID INT

DECLARE cur CURSOR FOR
    SELECT BusinessEntityID
    FROM HumanResources.Employee

OPEN cur

FETCH NEXT FROM cur INTO @BusinessEntityID

WHILE @@FETCH_STATUS = 0 BEGIN

    UPDATE HumanResources.Employee
    SET VacationHours = 0
    WHERE BusinessEntityID = @BusinessEntityID

    FETCH NEXT FROM cur INTO @BusinessEntityID

END

CLOSE cur
DEALLOCATE cur
GO

UPDATE HumanResources.Employee
SET VacationHours = 0
--WHERE VacationHours <> 0

/*
    UPDATE ...
    SET OldValue = NewValue
    WHERE OldValue <> NewValue
*/