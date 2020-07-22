USE AdventureWorks2012
GO

SELECT
	  d.ProductID
	, EOMONTH(m.OrderDate)
	, Sales = SUM(d.OrderQty * d.UnitPrice)
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader m ON d.SalesOrderID = m.SalesOrderID
GROUP BY
	  d.ProductID
	, EOMONTH(m.OrderDate)

-------------------------------------------------------------------

IF OBJECT_ID('Sales.SalesOrderMonth') IS NOT NULL
	DROP TABLE Sales.SalesOrderMonth
GO
CREATE TABLE Sales.SalesOrderMonth (
	ProductID INT,
	OrderMonth DATE,
	Sales MONEY NOT NULL,
	CONSTRAINT pk PRIMARY KEY (ProductID, OrderMonth DESC)
)
GO

IF OBJECT_ID('Sales.Update_SalesOrderMonth') IS NOT NULL
	DROP PROCEDURE Sales.Update_SalesOrderMonth
GO
CREATE PROCEDURE Sales.Update_SalesOrderMonth
(
	  @StartMonth DATE
	, @EndMonth DATE
)
AS BEGIN

	SET NOCOUNT ON;

	SELECT
		  @StartMonth = EOMONTH(DATEADD(MONTH, -1, ISNULL(@StartMonth, GETDATE())))
		, @EndMonth = EOMONTH(ISNULL(@EndMonth, GETDATE()))

	;WITH cte AS 
    (
    	SELECT *
    	FROM Sales.SalesOrderMonth
		WHERE OrderMonth BETWEEN @StartMonth AND @EndMonth
    )
	MERGE cte t
	USING (
		SELECT
			  d.ProductID
			, OrderMonth = EOMONTH(m.OrderDate)
			, Sales = SUM(d.OrderQty * d.UnitPrice)
		FROM Sales.SalesOrderDetail d
		JOIN Sales.SalesOrderHeader m ON d.SalesOrderID = m.SalesOrderID
		WHERE m.OrderDate BETWEEN @StartMonth AND @EndMonth
		GROUP BY
			  d.ProductID
			, EOMONTH(m.OrderDate)
	) s ON s.ProductID = t.ProductID
	WHEN MATCHED AND t.Sales != s.Sales
		THEN
			UPDATE SET Sales = s.Sales
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (ProductID, OrderMonth, Sales)
			VALUES (s.ProductID, s.OrderMonth, s.Sales)
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE;

END
GO

SELECT MAX(OrderDate), MIN(OrderDate)
FROM Sales.SalesOrderHeader

EXEC Sales.Update_SalesOrderMonth
	@StartMonth = '2005-07-01 00:00:00.000',
	@EndMonth = '2008-07-31 00:00:00.000'


-------------------------------------------------------------------

SELECT *
FROM Sales.SalesOrderMonth

SELECT
	  d.ProductID
	, EOMONTH(m.OrderDate)
	, Sales = SUM(d.OrderQty * d.UnitPrice)
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader m ON d.SalesOrderID = m.SalesOrderID
GROUP BY
	  d.ProductID
	, EOMONTH(m.OrderDate)

-------------------------------------------------------------------

SET STATISTICS IO ON

SELECT *
FROM (
	SELECT *, RowNum = ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY OrderMonth DESC)
	FROM Sales.SalesOrderMonth
) t
WHERE t.RowNum = 1

SELECT *
FROM (
	SELECT *, RowNum = ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY OrderMonth DESC)
	FROM (
		SELECT
			  d.ProductID
			, OrderMonth = EOMONTH(m.OrderDate)
			, Sales = SUM(d.OrderQty * d.UnitPrice)
		FROM Sales.SalesOrderDetail d
		JOIN Sales.SalesOrderHeader m ON d.SalesOrderID = m.SalesOrderID
		GROUP BY
			  d.ProductID
			, EOMONTH(m.OrderDate)
	) t
) t
WHERE t.RowNum = 1
