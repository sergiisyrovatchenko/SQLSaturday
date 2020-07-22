SELECT [name]
FROM sys.databases
WHERE is_query_store_on = 1

------------------------------------------------------------------

DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = STUFF((
    SELECT '
    ALTER DATABASE ' + QUOTENAME([name]) + ' SET QUERY_STORE = OFF;'
    FROM sys.databases
    WHERE is_query_store_on = 1
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @SQL