SELECT [object_id]
     , [name]
     , [type]
FROM sys.objects
FOR XML AUTO

SELECT [object_id]
     , [name]
     , [type]
FROM sys.objects o
FOR XML AUTO

SELECT o.[object_id]
     , o.[name]
     , o.[type]
     , s.is_recompiled
     , m.principal_id
FROM sys.objects o
JOIN sys.sql_modules s ON o.[object_id] = s.[object_id]
JOIN sys.schemas m ON o.[schema_id] = m.[schema_id]
FOR XML AUTO