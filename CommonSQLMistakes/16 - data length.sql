DECLARE @t1 VARCHAR(MAX) = '123456789_123456789_123456789_123456789_'
DECLARE @t2 VARCHAR = @t1

SELECT LEN(@t1)
     , @t1
     , LEN(@t2)
     , @t2
     , LEN(CONVERT(VARCHAR, @t1))
     , LEN(CAST(@t1 AS VARCHAR))
GO

------------------------------------------------------------------

DECLARE @a DECIMAL
      , @b VARCHAR(10) = '0.1'
      , @c SQL_VARIANT

SELECT @a = @b
     , @c = @a

SELECT @a
     , @c
     , SQL_VARIANT_PROPERTY(@c,'BaseType')
     , SQL_VARIANT_PROPERTY(@c,'Precision')
     , SQL_VARIANT_PROPERTY(@c,'Scale')

------------------------------------------------------------------

DECLARE @t TABLE (val DECIMAL) -- DECIMAL(18,0)
INSERT INTO @t VALUES (0.2)

DECLARE @val CHAR(3) = '0.1'
SELECT * FROM @t WHERE val = @val -- [val]=CONVERT_IMPLICIT(decimal(18,0),[@val],0)
GO

DECLARE @t TABLE (val DECIMAL(18,2))
INSERT INTO @t VALUES (0.2)

DECLARE @val CHAR(3) = '0.1'
SELECT * FROM @t WHERE val = @val -- [val]=CONVERT_IMPLICIT(decimal(18,2),[@val],0)