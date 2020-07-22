USE tempdb
GO

DROP TABLE IF EXISTS dbo.OrderDetails
GO

CREATE TABLE dbo.OrderDetails (
      SalesOrderID INT NOT NULL
    , ProductID INT NOT NULL
    , [Name] NVARCHAR(50) NOT NULL
    , ProductNumber NVARCHAR(25) NOT NULL
    , OrderQty SMALLINT NOT NULL
    , UnitPrice MONEY NOT NULL
    , PRIMARY KEY CLUSTERED (SalesOrderID, ProductID)
)
GO

DROP TABLE IF EXISTS dbo.Orders
GO

CREATE TABLE dbo.Orders (
      SalesOrderID INT IDENTITY PRIMARY KEY
    , AccountNumber NVARCHAR(15) NOT NULL
    , OrderDate SMALLDATETIME NOT NULL
    , ShipDate SMALLDATETIME
    , SubTotal MONEY NOT NULL
    , TaxAmt MONEY NOT NULL
)
GO

ALTER TABLE dbo.OrderDetails WITH CHECK
    ADD CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY(SalesOrderID)
    REFERENCES dbo.Orders (SalesOrderID)
GO

ALTER TABLE dbo.OrderDetails CHECK CONSTRAINT FK_OrderDetails_Orders
GO