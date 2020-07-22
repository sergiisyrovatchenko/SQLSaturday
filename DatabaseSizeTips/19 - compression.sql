USE tempdb
GO

IF OBJECT_ID('t') IS NOT NULL
	DROP TABLE t
GO
CREATE TABLE t (
	  A BIGINT
	, B CHAR(40)
	, C VARCHAR(MAX) -- LOB
)
GO

INSERT INTO t
VALUES (1, 'ab'), (1289, 'b'), (23, NULL), (1289, 'b')

-- ROW

-- A -> "1" -> 8 -> 1 -> TINYINT
-- A -> "1289" -> 8 -> 2 -> SMALLINT
-- B -> "ab    ..." -> 40 -> 2 -> CHAR(2)
-- B -> "NULL" -> 40 -> 1 -> CHAR(1)

-- PAGE

-- (1289, 'b'), (1289, 'b') -> (1289, 'b')
