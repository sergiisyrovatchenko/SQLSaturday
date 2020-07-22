/*
    EXEC sys.sp_configure 'show advanced options', 1
    GO
    RECONFIGURE
    GO

    EXEC sys.sp_configure 'xp_cmdshell', 1
    GO
    RECONFIGURE WITH OVERRIDE
    GO
*/

USE AdventureWorks2014
GO

DROP PROCEDURE IF EXISTS ##get_xml
DROP PROCEDURE IF EXISTS ##get_json
GO

CREATE PROCEDURE ##get_xml
AS
    SELECT r.ProductID
         , r.[Name]
         , r.ProductNumber
         , d.OrderQty
         , d.UnitPrice
         , r.ListPrice
         , r.Color
         , r.MakeFlag
    FROM Sales.SalesOrderDetail d
    JOIN Production.Product r ON d.ProductID = r.ProductID
    FOR XML PATH ('Product'), ROOT('Products')
GO

CREATE PROCEDURE ##get_json
AS
    SELECT (
        SELECT r.ProductID
             , r.[Name]
             , r.ProductNumber
             , d.OrderQty
             , d.UnitPrice
             , r.ListPrice
             , r.Color
             , r.MakeFlag
        FROM Sales.SalesOrderDetail d
        JOIN Production.Product r ON d.ProductID = r.ProductID
        FOR JSON PATH
    )
GO

DECLARE @sql NVARCHAR(4000) = 'bcp "EXEC ##get_xml" queryout "X:\sample1.xml" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql
PRINT @sql

SET @sql = 'bcp "EXEC ##get_json" queryout "X:\sample1.txt" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql
GO

/*
    <Products>
      <Product>
        <ProductID>776</ProductID>
        <Name>Mountain-100 Black, 42</Name>
        <ProductNumber>BK-M82B-42</ProductNumber>
        <OrderQty>1</OrderQty>
        <UnitPrice>2024.9940</UnitPrice>
        <ListPrice>1054.9300</ListPrice>
        <Color>White</Color>
        <MakeFlag>1</MakeFlag>
      </Product>
    </Products>

    [
       {
          "ProductID":776,
          "Name":"Mountain-100 Black, 42",
          "ProductNumber":"BK-M82B-42",
          "OrderQty":1,
          "UnitPrice":2024.9940,
          "ListPrice":3374.9900,
          "Color":"Black",
          "MakeFlag":true
       }
    ]
*/

DROP PROCEDURE IF EXISTS ##get_xml
DROP PROCEDURE IF EXISTS ##get_json
GO

CREATE PROCEDURE ##get_xml
AS
    SELECT h.SalesOrderID
         , h.AccountNumber
         , h.SubTotal
         , h.TaxAmt
         , h.OrderDate
         , h.ShipDate
         , [Products] = (
                SELECT r.ProductID
                     , r.[Name]
                     , r.ProductNumber
                     , d.OrderQty
                     , d.UnitPrice
                FROM Sales.SalesOrderDetail d
                JOIN Production.Product r ON d.ProductID = r.ProductID
                WHERE d.SalesOrderID = h.SalesOrderID
                FOR XML PATH('Product'), TYPE
         )
    FROM Sales.SalesOrderHeader h
    FOR XML PATH('Order'), ROOT('Orders')
GO

CREATE PROCEDURE ##get_json
AS
    SELECT (
        SELECT h.SalesOrderID
             , h.AccountNumber
             , h.SubTotal
             , h.TaxAmt
             , h.OrderDate
             , h.ShipDate
             , [Products] = (
                    SELECT r.ProductID
                         , r.[Name]
                         , r.ProductNumber
                         , d.OrderQty
                         , d.UnitPrice
                    FROM Sales.SalesOrderDetail d
                    JOIN Production.Product r ON d.ProductID = r.ProductID
                    WHERE d.SalesOrderID = h.SalesOrderID
                    FOR JSON PATH
             )
        FROM Sales.SalesOrderHeader h
        FOR JSON PATH
    )
GO

DECLARE @sql NVARCHAR(4000) = 'bcp "EXEC ##get_xml" queryout "X:\sample2.xml" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql
PRINT @sql

SET @sql = 'bcp "EXEC ##get_json" queryout "X:\sample2.txt" -S ' + @@servername + ' -T -w -r -t'
EXEC sys.xp_cmdshell @sql

/*
    <Orders>
        <Order>
            <SalesOrderID>43660</SalesOrderID>
            <AccountNumber>10-4020-000117</AccountNumber>
            <SubTotal>1294.2529</SubTotal>
            <TaxAmt>124.2483</TaxAmt>
            <OrderDate>2011-05-31T00:00:00</OrderDate>
            <ShipDate>2011-06-07T00:00:00</ShipDate>
            <Products>
                <Product>
                    <ProductID>762</ProductID>
                    <Name>Road-650 Red, 44</Name>
                    <ProductNumber>BK-R50R-44</ProductNumber>
                    <OrderQty>1</OrderQty>
                    <UnitPrice>419.4589</UnitPrice>
                </Product>
                <Product>
                    <ProductID>758</ProductID>
                    <Name>Road-450 Red, 52</Name>
                    <ProductNumber>BK-R68R-52</ProductNumber>
                    <OrderQty>1</OrderQty>
                    <UnitPrice>874.7940</UnitPrice>
                </Product>
            </Products>
        </Order>
    </Orders>

    [
       {
          "SalesOrderID":43660,
          "AccountNumber":"10-4020-000117",
          "SubTotal":1294.2529,
          "TaxAmt":124.2483,
          "OrderDate":"2011-05-31T00:00:00",
          "ShipDate":"2011-06-07T00:00:00",
          "Products":[
             {
                "ProductID":762,
                "Name":"Road-650 Red, 44",
                "ProductNumber":"BK-R50R-44",
                "OrderQty":1,
                "UnitPrice":419.4589
             },
             {
                "ProductID":758,
                "Name":"Road-450 Red, 52",
                "ProductNumber":"BK-R68R-52",
                "OrderQty":1,
                "UnitPrice":874.7940
             }
          ]
       }
    ]
*/