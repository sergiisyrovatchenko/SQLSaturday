DROP TABLE IF EXISTS #Users
GO

CREATE TABLE #Users (
      UserID INT
    , UserName SYSNAME
    , RegDate DATETIME
)

INSERT INTO #Users
VALUES (1, 'Paul Denton', '20170123')
     , (2, 'JC Denton', NULL)
     , (3, 'Maggie Cho', NULL)

------------------------------------------------------

SELECT *
FROM #Users
FOR JSON AUTO

/*
    [
       {
          "UserID":1,
          "UserName":"Paul Denton",
          "RegDate":"2029-01-23T00:00:00"
       },
       {
          "UserID":2,
          "UserName":"JC Denton"
       },
       {
          "UserID":3,
          "UserName":"Maggie Cho"
       }
    ]
*/

------------------------------------------------------

SELECT UserID, RegDate
FROM #Users
FOR JSON AUTO, INCLUDE_NULL_VALUES

/*
    [
       {
          "UserID":1,
          "RegDate":"2017-01-23T00:00:00"
       },
       {
          "UserID":2,
          "RegDate":null
       },
       {
          "UserID":3,
          "RegDate":null
       }
    ]
*/

------------------------------------------------------

SELECT TOP(1) UserID, UserName
FROM #Users
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER

/*
    {
       "UserID":1,
       "UserName":"Paul Denton"
    }
*/

------------------------------------------------------

SELECT UserID, UserName
FROM #Users
FOR JSON AUTO, ROOT('Users')

/*
    {
       "Users":[
          {
             "UserID":1,
             "UserName":"Paul Denton"
          },
          {
             "UserID":2,
             "UserName":"JC Denton"
          },
          {
             "UserID":3,
             "UserName":"Maggie Cho"
          }
       ]
    }
*/

------------------------------------------------------


SELECT TOP(1) UserID
            , UserName AS [Detail.FullName]
            , RegDate AS [Detail.RegDate]
FROM #Users
FOR JSON PATH

/*
    [
       {
          "UserID":1,
          "Detail":{
             "FullName":"Paul Denton",
             "RegDate":"2017-01-23T00:00:00"
          }
       }
    ]
*/

------------------------------------------------------

SELECT t.[name]
     , t.[object_id]
     , [columns] = (
             SELECT c.column_id, c.[name]
             FROM sys.columns c
             WHERE c.[object_id] = t.[object_id]
             FOR JSON AUTO
         )
FROM sys.tables t
FOR JSON AUTO

/*
    [
       {
          "name":"#Users",
          "object_id":1483152329,
          "columns":[
             {
                "column_id":1,
                "name":"UserID"
             },
             {
                "column_id":2,
                "name":"UserName"
             },
             {
                "column_id":3,
                "name":"RegDate"
             }
          ]
       }
    ]
*/

------------------------------------------------------

DECLARE @json NVARCHAR(MAX) = '[{"Code":"1"},{"Code":"2"},{"Code":"33873"},{"Code":"444"}]'

/*
    ["1","2","33873","444"]
*/

SELECT Code
FROM OPENJSON(@json) WITH (Code VARCHAR(10))
FOR JSON PATH

SELECT STUFF((
    SELECT ',"' + Code + '"'
    FROM OPENJSON(@json) WITH (Code VARCHAR(10))
    FOR XML PATH('')), 1, 1, '[') + ']'