DECLARE @json NVARCHAR(MAX) =
'[
   {
      "horseId":462896,
      "horse_type":"damn",
      "ancestors":[
         {
            "horseId":300025,
            "childId":462896,
            "horse_type":"sire",
            "ancestors":[
               {
                  "horseId":300758,
                  "childId":300025,
                  "horse_type":"sire",
                  "ancestors":[
                     {
                        "horseId":301976,
                        "childId":300758,
                        "horse_type":"sire",
                        "ancestors":[
                           {
                              "horseId":303011,
                              "childId":301976,
                              "horse_type":"sire"
                           },
                           {
                              "horseId":443068,
                              "childId":301976,
                              "horse_type":"damn"
                           }
                        ]
                     },
                     {
                        "horseId":525197,
                        "childId":300758,
                        "horse_type":"damn",
                        "ancestors":[
                           {
                              "horseId":54023,
                              "childId":525197,
                              "horse_type":"damn"
                           },
                           {
                              "horseId":611465,
                              "childId":525197,
                              "horse_type":"sire"
                           }
                        ]
                     }
                  ]
               }
            ]
         },
         {
            "horseId":438338,
            "childId":462896,
            "horse_type":"damn",
            "ancestors":[
               {
                  "horseId":302351,
                  "childId":438338,
                  "horse_type":"sire"
               },
               {
                  "horseId":567497,
                  "childId":438338,
                  "horse_type":"damn"
               }
            ]
         }
      ]
   }
]'

;WITH cte AS
(
    SELECT *, lvl = CAST(0 AS INT)
    FROM OPENJSON(@json)
        WITH (
              horseId INT
            , childId INT
            , horse_type VARCHAR(10)
            , ancestors NVARCHAR(MAX) AS JSON
        )

    UNION ALL

    SELECT t2.*, t1.lvl + 1
    FROM cte t1
    CROSS APPLY OPENJSON(ancestors)
        WITH (
              horseId INT
            , childId INT
            , horse_type VARCHAR(10)
            , ancestors NVARCHAR(MAX) AS JSON
        ) t2
)
SELECT *
FROM cte
OPTION (MAXRECURSION 0)