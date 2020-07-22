USE [master]
GO

ALTER DATABASE [model] SET CURSOR_DEFAULT LOCAL
GO
ALTER DATABASE [model] SET RECOVERY SIMPLE
GO

ALTER DATABASE [model] MODIFY FILE (NAME = N'modeldev', SIZE = 32MB, FILEGROWTH = 64MB)
GO
ALTER DATABASE [model] MODIFY FILE (NAME = N'modellog', SIZE = 32MB, FILEGROWTH = 64MB) -- VLF
GO

------------------------------------------------------------------

IF DB_ID('db') IS NOT NULL BEGIN
    ALTER DATABASE db SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE db
END
GO

CREATE DATABASE db
GO

------------------------------------------------------------------

USE db
GO

SELECT t.is_local_cursor_default
     , t.recovery_model_desc
     , d.[type_desc]
     , d.physical_name
     , space_used_percent = FILEPROPERTY(d.name, 'SpaceUsed') * 100. / d.size 
     , current_size_mb = ROUND(d.size * 8. / 1000, 0)
     , initial_size_mb = ROUND(m.size * 8. / 1000, 0) 
     , auto_grow =
         CASE WHEN d.is_percent_growth = 1
             THEN CAST(d.growth AS VARCHAR(10)) + '%'
             ELSE CAST(ROUND(d.growth * 8. / 1000, 0) AS VARCHAR(10)) + 'MB'
         END
FROM sys.databases t
CROSS JOIN sys.database_files d
JOIN sys.master_files m ON d.[file_id] = m.[file_id] AND t.database_id = m.database_id
WHERE t.database_id = DB_ID()