SELECT [object_id]
     , [name]
     , [type]
FROM sys.objects
FOR XML RAW

SELECT o.[object_id]
     , o.[name]
     , o.[type]
     , s.is_recompiled
FROM sys.objects o
JOIN sys.sql_modules s ON o.[object_id] = s.[object_id]
FOR XML RAW