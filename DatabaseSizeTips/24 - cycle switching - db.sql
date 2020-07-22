USE [master]
GO

IF DB_ID('db') IS NOT NULL BEGIN
	ALTER DATABASE [db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE [db]
END
GO

CREATE DATABASE [db]
GO

USE [db]
GO

DECLARE @SQL NVARCHAR(MAX)

DECLARE @db_path SYSNAME = (
    SELECT REVERSE(SUBSTRING(pt, CHARINDEX('\', pt), LEN(pt)))
    FROM (
        SELECT pt = REVERSE(d.physical_name)
        FROM sys.master_files d
        JOIN sys.data_spaces s ON d.data_space_id = s.data_space_id
        WHERE d.database_id = DB_ID()
            AND d.[type] = 0
            AND s.is_default = 1
    ) t
)

SET @SQL = (
    SELECT TOP(13) '
    ALTER DATABASE [' + DB_NAME() + '] ADD FILEGROUP [WM_' + LEFT(NEWID(), 8) + ']'
    FROM [master].dbo.spt_values
    WHERE [type] = 'P'
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')

--PRINT @SQL
EXEC sys.sp_executesql @SQL

SET @SQL = (
    SELECT '
    ALTER DATABASE [' + DB_NAME() + ']
    ADD FILE (
        NAME = ' + name + ', SIZE = 10MB, FILEGROWTH = 10%,
        FILENAME = ''' + @db_path + name + '.ndf''
    ) TO FILEGROUP [' + name + ']'
    FROM sys.filegroups
    WHERE is_default = 0
        AND name LIKE 'WM_%'
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)')

--PRINT @SQL
EXEC sys.sp_executesql @SQL

--ALTER DATABASE [db] ADD FILEGROUP [WM_699203D2]
--ALTER DATABASE [db] ADD FILEGROUP [WM_F89C21D0]
--...

--ALTER DATABASE [db]
--ADD FILE (
--    NAME = WM_699203D2, SIZE = 10MB, FILEGROWTH = 10%
--    FILENAME = 'D:\DATABASES\SQL_2012\DATA\WM_699203D2.ndf' 
--) TO FILEGROUP [WM_699203D2]
--ALTER DATABASE [db]
--ADD FILE (
--    NAME = WM_F89C21D0, SIZE = 10MB, FILEGROWTH = 10%
--    FILENAME = 'D:\DATABASES\SQL_2012\DATA\WM_F89C21D0.ndf'
--) TO FILEGROUP [WM_F89C21D0]
--...

GO

DECLARE @SQL NVARCHAR(MAX)

SET @SQL = 'CREATE PARTITION FUNCTION [WM_PF] (DATE) AS RANGE RIGHT FOR VALUES (' + STUFF((
    SELECT ', N''' + CONVERT(VARCHAR, DATEADD(mm, DATEDIFF(mm, 0, DATEADD(MONTH, -number, GETDATE())), 0), 112) + ''''
    FROM [master].dbo.spt_values
    WHERE [type] = 'P'
        AND number BETWEEN 0 AND 11
    ORDER BY -number
    FOR XML PATH('')), 1, 2, '') + ')'

--PRINT @SQL
EXEC sys.sp_executesql @SQL

SET @SQL = 'CREATE PARTITION SCHEME [WM_PS] AS PARTITION [WM_PF] TO (' + STUFF((
    SELECT ', [' + name + ']'
    FROM sys.filegroups
    WHERE name LIKE 'WM_%'
    ORDER BY name
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') + ')'

--PRINT @SQL
EXEC sys.sp_executesql @SQL

--CREATE PARTITION FUNCTION [WM_PF] (DATE)
--    AS RANGE RIGHT FOR VALUES (
--        N'20141201', N'20150101', N'20150201',
--        N'20150301', N'20150401', N'20150501',
--        N'20150601', N'20150701', N'20150801',
--        N'20150901', N'20151001', N'20151101'
--    )

--CREATE PARTITION SCHEME [WM_PS]
--    AS PARTITION [WM_PF] TO (
--         [WM_081D0115], [WM_09733DC9], [WM_699203D2],
--         [WM_6BD777EE], [WM_72393C0E], [WM_73A554B5],
--         [WM_747A6EA0], [WM_A1454DF1], [WM_BB837F6D],
--         [WM_DB1F8743], [WM_EBB73992], [WM_F02216C0],
--         [WM_F89C21D0]
--    )

GO

-------------------------------------------------------------------

IF OBJECT_ID('dbo.WordMention', 'U') IS NOT NULL
	DROP TABLE dbo.WordMention
GO
CREATE TABLE dbo.WordMention (
    MonthLastDay DATE,
    WordID INT,
    Mentions TINYINT NOT NULL,
    PRIMARY KEY CLUSTERED (MonthLastDay, WordID) ON [WM_PS](MonthLastDay)
)
GO

INSERT INTO dbo.WordMention
SELECT EOMONTH(CAST(value AS DATE)), 1, 1
FROM sys.partition_range_values

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