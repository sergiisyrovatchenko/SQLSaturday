SELECT [object_id]
     , [name]
     , [type]
FROM sys.objects
FOR XML PATH

SELECT [object_id]
     , [name]
     , [type]
FROM sys.objects
FOR XML PATH('i'), ROOT('items')

SELECT [object_id]
     , [info/name] = [name]
     , [info/type] = [type]
FROM sys.objects
FOR XML PATH('i'), ROOT('items')

SELECT [@object_id] = [object_id]
     , [@name] = [name]
     , [@type] = [type]
FROM sys.objects
FOR XML PATH('i'), ROOT('items')

SELECT o.[object_id]
     , o.[name]
     , o.[type]
     , s.is_recompiled
FROM sys.objects o
JOIN sys.sql_modules s ON o.[object_id] = s.[object_id]
FOR XML PATH('i'), ROOT('items')

------------------------------------------------------

SELECT [@name] = t.[name]
     , c.[name]
FROM sys.tables t
JOIN sys.columns c ON t.[object_id] = c.[object_id]
FOR XML PATH('table'), ROOT('tables')

SELECT [@name] = t.[name]
     , [columns/column/@name] = c.[name]
FROM sys.tables t
JOIN sys.columns c ON t.[object_id] = c.[object_id]
FOR XML PATH('table'), ROOT('tables')

SELECT [@name] = t.[name]
     , [columns] = (
             SELECT c.[name]
             FROM sys.columns c
             WHERE t.[object_id] = c.[object_id]
             FOR XML PATH ('')
         )
FROM sys.tables t
FOR XML PATH('table'), ROOT('tables')

SELECT [@name] = t.[name]
     , [columns] = (
             SELECT c.[name]
             FROM sys.columns c
             WHERE t.[object_id] = c.[object_id]
             FOR XML PATH (''), TYPE
         )
FROM sys.tables t
FOR XML PATH('table'), ROOT('tables')

SELECT [@name] = t.[name]
     , [columns] = (
             SELECT [@name] = c.[name]
             FROM sys.columns c
             WHERE t.[object_id] = c.[object_id]
             FOR XML PATH ('column'), TYPE
         )
FROM sys.tables t
FOR XML PATH('table'), ROOT('tables')