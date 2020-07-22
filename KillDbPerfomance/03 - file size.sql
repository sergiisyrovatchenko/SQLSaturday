USE KillDB
GO

SELECT [name]
     , size = size * 8. / 1024
     , used_size = FILEPROPERTY([name], 'SpaceUsed') * 8. / 1024
     , space_used_percent = FILEPROPERTY([name], 'SpaceUsed') * 100. / size 
     , max_size
     , growth = growth * 8. / 1024
     , is_percent_growth
FROM sys.database_files