/*
    ALTER DATABASE [master] SET COMPATIBILITY_LEVEL = 130
*/

DECLARE @json NVARCHAR(MAX) = N'
    {
        "UserID": 1,
        "UserName": "JC Denton",
        "IsActive": true,
        "RegDate": "2016-05-31T00:00:00"
    }'

SELECT * FROM OPENJSON(@json)
GO

/*
    0: Null
    1: String
    2: Int
    3: True/False
    4: Array
    5: Object
*/

------------------------------------------------------

DECLARE @json NVARCHAR(MAX) = N'
    [
        {
            "User ID": 1,
            "UserName": "JC Denton",
            "IsActive": true,
            "Date": "2016-05-31T00:00:00",
            "Settings": [
                 {
                    "Language": "EN"
                 },
                 {
                    "Skin": "FlatUI"
                 }
              ]
        },
        {
            "User ID": 2,
            "UserName": "Paul Denton",
            "IsActive": false
        }
    ]'

SELECT * FROM OPENJSON(@json)
SELECT * FROM OPENJSON(@json, '$[0]')
SELECT * FROM OPENJSON(@json, '$[0].Settings[0]')

SELECT *
FROM OPENJSON(@json)
    WITH (
          UserID INT '$."User ID"'
        , UserName SYSNAME
        , IsActive BIT
        , RegDate DATETIME '$.Date'
        , Settings NVARCHAR(MAX) AS JSON
        , Skin SYSNAME '$.Settings[1].Skin'
    )
GO

------------------------------------------------------

DECLARE @json NVARCHAR(MAX) = N'
    [
        {
            "FullName": "JC Denton",
            "Children": [
                { "FullName": "Mary", "Male": "Female" },
                { "FullName": "Paul", "Male": "Male" }
            ]
        },
        {
            "FullName": "Paul Denton"
        }
    ]'

SELECT t.FullName, c.*
FROM OPENJSON(@json)
    WITH (
          FullName SYSNAME
        , Children NVARCHAR(MAX) AS JSON
    ) t
OUTER APPLY OPENJSON(Children)
    WITH (
          ChildrenName SYSNAME '$.FullName'
        , Male SYSNAME
    ) c