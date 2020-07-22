USE [master]
GO

SELECT is_auto_close_on
FROM sys.databases
WHERE database_id = DB_ID('model')
GO

IF DB_ID('test') IS NOT NULL
    DROP DATABASE [test]
GO

CREATE DATABASE [test]
GO

SELECT is_auto_close_on
FROM sys.databases
WHERE database_id = DB_ID('test')