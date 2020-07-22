SET NOCOUNT ON
SET STATISTICS IO, TIME ON

/*
    DBCC FREEPROCCACHE
*/

USE test
GO

SELECT TOP(1000) *
FROM big_table
WHERE B = 'X'
ORDER BY A DESC

SELECT TOP(1000) *
FROM big_table
WHERE B = 'A'
ORDER BY A DESC
GO

------------------------------------------------------------------

DROP PROCEDURE IF EXISTS #proc
GO

CREATE PROCEDURE #proc
(
    @var VARCHAR(10)
)
AS
    SELECT TOP(1000) *
    FROM big_table
    WHERE B = @var
    ORDER BY A DESC
    --OPTION(RECOMPILE)
GO

------------------------------------------------------------------

EXEC #proc @var = 'X'
EXEC #proc @var = 'A'

------------------------------------------------------------------

USE AdventureWorks2014
GO

SELECT SalesOrderDetailID, UnitPrice * OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 870
GO

SELECT SalesOrderDetailID, UnitPrice * OrderQty
FROM Sales.SalesOrderDetail
WHERE ProductID = 897
GO

------------------------------------------------------

IF OBJECT_ID('tempdb.dbo.#GetOrderTotalSum') IS NOT NULL
    DROP PROCEDURE #GetOrderTotalSum
GO

CREATE PROCEDURE #GetOrderTotalSum
(
    @ProductID INT
)
AS BEGIN

    SELECT SalesOrderDetailID, Total = UnitPrice * OrderQty
    FROM Sales.SalesOrderDetail
    WHERE ProductID = @ProductID

END
GO

EXEC #GetOrderTotalSum @ProductID = 870
EXEC #GetOrderTotalSum @ProductID = 897
GO

------------------------------------------------------

ALTER PROCEDURE #GetOrderTotalSum
(
    @ProductID INT
)
WITH RECOMPILE
AS BEGIN

    SELECT SalesOrderDetailID, Total = UnitPrice * OrderQty
    FROM Sales.SalesOrderDetail
    WHERE ProductID = @ProductID

END
GO

EXEC #GetOrderTotalSum @ProductID = 870
EXEC #GetOrderTotalSum @ProductID = 897
GO

------------------------------------------------------

ALTER PROCEDURE #GetOrderTotalSum
(
    @Products XML
)
WITH RECOMPILE
AS BEGIN

    SELECT SalesOrderDetailID, Total = UnitPrice * OrderQty
    FROM Sales.SalesOrderDetail
    WHERE ProductID IN (SELECT t.c.value('(./text())[1]', 'INT') FROM @Products.nodes('*') t(c))

END
GO

EXEC #GetOrderTotalSum @Products = '<x>870</x><x>871</x>'
EXEC #GetOrderTotalSum @Products = '<x>897</x>'
GO

------------------------------------------------------

ALTER PROCEDURE #GetOrderTotalSum
(
    @Products XML
)
AS BEGIN

    SELECT SalesOrderDetailID, Total = UnitPrice * OrderQty
    FROM Sales.SalesOrderDetail
    WHERE ProductID IN (SELECT t.c.value('(./text())[1]', 'INT') FROM @Products.nodes('*') t(c))
    OPTION(RECOMPILE)

END
GO

EXEC #GetOrderTotalSum @Products = '<x>870</x><x>871</x>'
EXEC #GetOrderTotalSum @Products = '<x>897</x>'
GO

------------------------------------------------------

ALTER PROCEDURE #GetOrderTotalSum
(
    @Products XML
)
AS BEGIN

    DECLARE @t TABLE(id INT PRIMARY KEY)
    INSERT INTO @t
    SELECT t.c.value('(./text())[1]', 'INT') FROM @Products.nodes('*') t(c)

    SELECT SalesOrderDetailID, Total = UnitPrice * OrderQty
    FROM Sales.SalesOrderDetail
    WHERE ProductID IN (SELECT * FROM @t)
    --OPTION(RECOMPILE)

END
GO

EXEC #GetOrderTotalSum @Products = '<x>870</x><x>871</x>'
EXEC #GetOrderTotalSum @Products = '<x>897</x>'
GO