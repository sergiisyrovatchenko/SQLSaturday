USE db
GO

DECLARE
      @split_value VARCHAR(24)
    , @merge_value VARCHAR(24)
    , @filegroup_old SYSNAME
    , @filegroup_new SYSNAME
    , @obj_id INT = OBJECT_ID('dbo.WordMention')
    , @SQL NVARCHAR(MAX)

SELECT
      @split_value = CONVERT(VARCHAR(24), DATEADD(MONTH, 1, CAST(MAX(value) AS DATETIME)), 126) 
    , @merge_value = CONVERT(VARCHAR(24), MIN(value), 126) 
FROM sys.partition_range_values v
JOIN sys.partition_functions f ON v.function_id = f.function_id
WHERE f.name = 'WM_PF'

SELECT
      @filegroup_old = MAX(CASE WHEN p.partition_number = 1 THEN f.name END)
    , @filegroup_new = MAX(CASE WHEN p.partition_number = 2 THEN f.name END)
FROM sys.partitions p
JOIN sys.destination_data_spaces d ON d.destination_id = p.partition_number
JOIN sys.filegroups f ON d.data_space_id = f.data_space_id
WHERE p.[object_id] = @obj_id
    AND p.partition_number IN (1, 2)
    AND p.index_id = 1

IF OBJECT_ID('dbo.WordMention_temp') IS NOT NULL
    DROP TABLE dbo.WordMention_temp

SET @SQL = '
CREATE TABLE dbo.WordMention_temp (
    MonthLastDay DATE,
    WordID INT,
    Mentions TINYINT NOT NULL,
    PRIMARY KEY CLUSTERED (MonthLastDay, WordID) ON [' + @filegroup_old + ']
)'

EXEC sys.sp_executesql @SQL

ALTER TABLE dbo.WordMention SWITCH PARTITION 1 TO dbo.WordMention_temp

IF OBJECT_ID('dbo.WordMention_temp') IS NOT NULL
    DROP TABLE dbo.WordMention_temp

ALTER PARTITION FUNCTION WM_PF() MERGE RANGE (@merge_value)

SET @SQL = 'ALTER PARTITION SCHEME WM_PS NEXT USED [' + @filegroup_new + ']'

EXEC sys.sp_executesql @SQL

ALTER PARTITION FUNCTION WM_PF() SPLIT RANGE (@split_value)
GO

-------------------------------------------------------------------

SELECT
	  i.index_id
	, p.partition_number
	, fg.name
	, p.[rows]
	, prv.value
FROM sys.indexes i
JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
LEFT JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
LEFT JOIN sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id AND p.partition_number = dds.destination_id
LEFT JOIN sys.partition_range_values prv ON ps.function_id = prv.function_id AND p.partition_number = prv.boundary_id + 1
JOIN sys.filegroups fg ON COALESCE(dds.data_space_id, i.data_space_id) = fg.data_space_id
WHERE i.[object_id] = OBJECT_ID('dbo.WordMention')
ORDER BY p.partition_number
