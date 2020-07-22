SELECT Tag = 1
     , Parent = NULL
     , [schema!1!name] = s.[name]
     , [object!2!object_id] = NULL
     , [object!2!name] = NULL
FROM sys.schemas s

UNION ALL

SELECT Tag = 2
     , Parent = 1
     , s.[name]
     , o.[object_id]
     , o.[name]
FROM sys.schemas s
JOIN sys.objects o ON s.[schema_id] = o.[schema_id]
ORDER BY [schema!1!name]
       , [object!2!object_id]
FOR XML EXPLICIT