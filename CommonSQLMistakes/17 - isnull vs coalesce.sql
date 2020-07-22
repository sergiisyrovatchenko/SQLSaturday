DECLARE @c CHAR(1) = NULL
      , @i INT = NULL

SELECT ISNULL(@c, 'NULL')
     , COALESCE(@c, 'NULL')

SELECT ISNULL(@i, 7.1)
     , COALESCE(@i, 7.1)