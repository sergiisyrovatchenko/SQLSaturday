USE db
GO

TRUNCATE TABLE dbo.WordMention WITH (PARTITIONS (1, 3 TO 4))

-------------------------------------------------------------------

DECLARE
      @split_value VARCHAR(24)
    , @merge_value VARCHAR(24)
    , @SQL NVARCHAR(MAX)

SELECT
      @split_value = CONVERT(VARCHAR(24), DATEADD(MONTH, 1, CAST(MAX(value) AS DATETIME)), 126) 
    , @merge_value = CONVERT(VARCHAR(24), MIN(value), 126) 
FROM sys.partition_range_values v
JOIN sys.partition_functions f ON v.function_id = f.function_id
WHERE f.name = 'WM_PF'

SELECT @SQL = 'ALTER PARTITION SCHEME WM_PS NEXT USED [' + f.name + ']'
FROM sys.partitions p
JOIN sys.destination_data_spaces d ON d.destination_id = p.partition_number
JOIN sys.filegroups f ON d.data_space_id = f.data_space_id
WHERE p.[object_id] = OBJECT_ID('dbo.WordMention')
    AND p.partition_number = 2
    AND p.index_id = 1

TRUNCATE TABLE dbo.WordMention WITH (PARTITIONS (1))

ALTER PARTITION FUNCTION WM_PF() MERGE RANGE (@merge_value)

EXEC sys.sp_executesql @SQL

ALTER PARTITION FUNCTION WM_PF() SPLIT RANGE (@split_value)
