USE tempdb
GO

IF OBJECT_ID('t') IS NOT NULL
	DROP TABLE t
GO
CREATE TABLE t (
	ProductID INT NOT NULL,
	ReviewCode VARCHAR(20) NOT NULL,
	ReviewDate DATE NOT NULL,
	FoundHelpful SMALLINT NOT NULL,
	NotFoundHelpful SMALLINT NOT NULL,
	Stars TINYINT NOT NULL,
	Reviewer NVARCHAR(128) NOT NULL,
	Caption NVARCHAR(128) NULL,
	[Text] NVARCHAR(MAX) NOT NULL,
	PRIMARY KEY CLUSTERED (ProductID, ReviewCode)
)
GO

INSERT INTO t
VALUES
	(200111344, 'R1SKQKVVAB7X63', '2007-01-18', 1, 5, 4, 'T. Fabio', 'Very Nice', 'I very much liked this tool.'),
	(200111344, 'RN98OXS99JGDA', '2014-08-05', 1, 0, 5, 'sweetie3', 'Great value!!!', 'Good quality, just as described.'),
	(200111345, 'RN98OXS99JGDA', '2014-08-05', 1, 0, 5, 'sweetie3', 'Great value!!!', 'Good quality, just as described.'),
	(200111346, 'RN98OXS99JGDA', '2014-08-05', 1, 0, 5, 'sweetie3', 'Great value!!!', 'Good quality, just as described.'),
	(200111347, 'RN98OXS99JGDA', '2014-08-05', 1, 0, 5, 'sweetie3', 'Great value!!!', 'Good quality, just as described.'),
	(200111348, 'RN98OXS99JGDA', '2014-08-05', 1, 0, 5, 'sweetie3', 'Great value!!!', 'Good quality, just as described.'),
	(200163816, 'RN98OXS99JGDA', '2014-08-05', 1, 0, 5, 'sweetie3', 'Great value!!!', 'Good quality, just as described.')
GO

IF OBJECT_ID('t_main') IS NOT NULL
	DROP TABLE t_main
GO
CREATE TABLE t_main (
	ProductID INT NOT NULL,
	ReviewID INT NOT NULL,
	PRIMARY KEY CLUSTERED (ProductID, ReviewID)
)
GO
IF OBJECT_ID('t_detail') IS NOT NULL
	DROP TABLE t_detail
GO
CREATE TABLE t_detail (
	ReviewID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	ReviewCode VARCHAR(20) NOT NULL,
	ReviewDate DATE NOT NULL,
	FoundHelpful SMALLINT NOT NULL,
	NotFoundHelpful SMALLINT NOT NULL,
	Stars TINYINT NOT NULL,
	Reviewer NVARCHAR(128) NOT NULL,
	Caption NVARCHAR(128) NULL,
	[Text] NVARCHAR(MAX) NOT NULL
)
GO
CREATE UNIQUE NONCLUSTERED INDEX ix_review_code ON t_detail (ReviewCode)
GO
