USE CCI
GO

DROP VIEW IF EXISTS dbo.vCCI
GO

CREATE VIEW dbo.vCCI
WITH SCHEMABINDING
AS
    SELECT CustomerID
         , TotalSum = SUM(ISNULL(OrderQty * UnitPrice, 0))
         , Cnt = COUNT_BIG(*)
    FROM dbo.tCCI
    GROUP BY CustomerID
GO

/*
    CREATE CLUSTERED COLUMNSTORE INDEX CCI ON dbo.vCCI_Table

    The statement failed because a clustered columnstore index cannot be created on a view.
    Consider creating a nonclustered columnstore index on the view, creating a clustered columnstore index on the base table or creating an index without the COLUMNSTORE keyword on the view.
*/

CREATE UNIQUE CLUSTERED INDEX PK ON dbo.vCCI (CustomerID)
CREATE NONCLUSTERED COLUMNSTORE INDEX NCCI ON dbo.vCCI (CustomerID, TotalSum, Cnt)
GO

SET STATISTICS IO, TIME ON

SELECT *
FROM dbo.vCCI WITH(NOEXPAND)
WHERE CustomerID = 15404

/*
    UPDATE TOP(1) dbo.tCCI
    SET UnitPrice = 1
    WHERE CustomerID = 15404

    UPDATE TOP(1) dbo.tCCI
    SET ShipDate = GETDATE()
    WHERE CustomerID = 15404
*/

SELECT *
FROM dbo.vCCI
WHERE CustomerID = 15404
OPTION (EXPAND VIEWS)

SET STATISTICS IO, TIME OFF

/*
    SQL Server Execution Times:
        CPU time = 0 ms,  elapsed time = 0 ms.

    SQL Server Execution Times:
        CPU time = 329 ms,  elapsed time = 429 ms.
*/

DROP VIEW IF EXISTS dbo.vCCI
GO