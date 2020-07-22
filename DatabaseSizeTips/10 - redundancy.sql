USE tempdb
GO

IF OBJECT_ID('t1') IS NOT NULL
	DROP TABLE t1
GO
CREATE TABLE t1 (
	ProductID INT NOT NULL,
	RelatedProductID INT NOT NULL,
	MonthLastDay DATE NOT NULL,
	PRIMARY KEY CLUSTERED (ProductID, RelatedProductID, MonthLastDay)
)
GO

INSERT INTO t1
VALUES
	(1, 2, '2015-01-31'), (1, 3, '2015-01-31'), (1, 4, '2015-01-31'),
	(1, 2, '2015-02-28'), (1, 3, '2015-02-28'), (1, 4, '2015-02-28'), (1, 5, '2015-02-28'), (1, 6, '2015-02-28'),
	(1, 2, '2015-03-31'), (1, 3, '2015-03-31'), (1, 4, '2015-03-31'), (1, 6, '2015-03-31')

IF OBJECT_ID('t2') IS NOT NULL
	DROP TABLE t2
GO
CREATE TABLE t2 (
	ProductID INT NOT NULL,
	RelatedProductID INT NOT NULL,
	UpdateDate DATE NOT NULL,
	PRIMARY KEY CLUSTERED (ProductID, RelatedProductID)
)
GO

-------------------------------------------------------------------

INSERT INTO t2
SELECT ProductID, RelatedProductID, MAX(MonthLastDay)
FROM t1
GROUP BY ProductID, RelatedProductID
GO

SELECT * FROM t2

