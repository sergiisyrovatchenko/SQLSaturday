USE [master]
GO

IF DB_ID('CCI') IS NOT NULL BEGIN
    ALTER DATABASE CCI SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE CCI
END
GO

CREATE DATABASE CCI ON
    PRIMARY (NAME = N'CCI', FILENAME = N'C:\DB\CCI.mdf', SIZE = 3GB, FILEGROWTH = 64MB)
    LOG ON (NAME = N'CCI_log', FILENAME = N'C:\DB\CCI_log.ldf', SIZE = 512MB, FILEGROWTH = 64MB)
GO

ALTER DATABASE CCI SET RECOVERY SIMPLE
GO

---------------------------------------------------------------------------------------------------------

USE CCI
GO

DROP TABLE IF EXISTS dbo.tHeap
GO

CREATE TABLE dbo.tHeap (
    RowID INT NOT NULL,
    RowID_Varchar VARCHAR(100) NOT NULL,
    RowID_NVarcharMax NVARCHAR(MAX) NOT NULL,
    RowID_Datetime DATETIME NULL,
    SalesOrderID INT NOT NULL,
    SalesOrderDetailID INT NOT NULL,
    CarrierTrackingNumber NVARCHAR(25) NULL,
    OrderQty SMALLINT NOT NULL,
    ProductID INT NOT NULL,
    SpecialOfferID INT NOT NULL,
    UnitPrice MONEY NULL,
    UnitPriceDiscount MONEY NULL,
    LineTotal NUMERIC(38,6) NOT NULL,
    OrderDate DATETIME NOT NULL,
    DueDate DATETIME NOT NULL,
    ShipDate DATETIME NULL,
    SalesOrderNumber NVARCHAR(25) NOT NULL,
    PurchaseOrderNumber NVARCHAR(25) NULL,
    CustomerID INT NOT NULL,
    TotalSum MONEY NOT NULL
)
GO

INSERT INTO dbo.tHeap
SELECT TOP(5000000) RowID = ROW_NUMBER() OVER (ORDER BY 1/0)
                  , RowID_Varchar = CAST(ROW_NUMBER() OVER (ORDER BY 1/0) AS VARCHAR(100))
                  , RowID_NVarcharMax = CAST(ROW_NUMBER() OVER (ORDER BY 1/0) AS VARCHAR(100))
                  , RowID_Datetime = DATEADD(DAY, ROW_NUMBER() OVER (ORDER BY 1/0) % 100, '20180101')
                  , sd.SalesOrderID
                  , sd.SalesOrderDetailID
                  , sd.CarrierTrackingNumber
                  , sd.OrderQty
                  , sd.ProductID
                  , sd.SpecialOfferID
                  , sd.UnitPrice
                  , sd.UnitPriceDiscount
                  , sd.LineTotal
                  , soh.OrderDate
                  , soh.DueDate
                  , soh.ShipDate
                  , soh.SalesOrderNumber
                  , soh.PurchaseOrderNumber
                  , soh.CustomerID
                  , sd.OrderQty * sd.UnitPrice
FROM AdventureWorks2019.Sales.SalesOrderDetail sd
JOIN AdventureWorks2019.Sales.SalesOrderHeader soh ON sd.SalesOrderID = soh.SalesOrderID
CROSS JOIN (SELECT TOP(100) 1 FROM sys.objects) t(a)
GO

CHECKPOINT
GO

---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.tNoCompress
SELECT * INTO dbo.tNoCompress FROM dbo.tHeap
GO

CREATE CLUSTERED INDEX IX ON dbo.tNoCompress (RowID) WITH (DATA_COMPRESSION = NONE)
GO

CHECKPOINT
GO

---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.tRowCompress
SELECT * INTO dbo.tRowCompress FROM dbo.tHeap WHERE 1 = 0
GO

CREATE CLUSTERED INDEX IX ON dbo.tRowCompress (RowID) WITH (DATA_COMPRESSION = ROW)
GO

INSERT INTO dbo.tRowCompress WITH(TABLOCK)
SELECT * FROM dbo.tNoCompress
GO

CHECKPOINT
GO

---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.tPageCompress
SELECT * INTO dbo.tPageCompress FROM dbo.tRowCompress WHERE 1 = 0
GO

CREATE CLUSTERED INDEX IX ON dbo.tPageCompress (RowID) WITH (DATA_COMPRESSION = PAGE)
GO

INSERT INTO dbo.tPageCompress WITH(TABLOCK)
SELECT * FROM dbo.tRowCompress
GO

CHECKPOINT
GO

---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.tCCI
SELECT * INTO dbo.tCCI FROM dbo.tRowCompress WHERE 1 = 0
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI ON dbo.tCCI WITH (DATA_COMPRESSION = COLUMNSTORE)
GO

INSERT INTO dbo.tCCI WITH(TABLOCK)
SELECT * FROM dbo.tRowCompress
GO

CHECKPOINT
GO

---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.tCCIArch
SELECT * INTO dbo.tCCIArch FROM dbo.tCCI WHERE 1 = 0
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCI ON dbo.tCCIArch WITH (DATA_COMPRESSION = COLUMNSTORE_ARCHIVE)
GO

INSERT INTO dbo.tCCIArch WITH(TABLOCK)
SELECT * FROM dbo.tCCI
GO

ALTER INDEX CCI ON dbo.tCCIArch REBUILD
CHECKPOINT
GO