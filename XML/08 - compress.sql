DECLARE @nvarchar NVARCHAR(MAX) = N'
<Product Name="Lenovo ThinkPad E460">
    <Ratings Value="4" Reviews="2">
        <Rating Value="5" Reviews="1" />
        <Rating Value="3" Reviews="1" />
    </Ratings>
</Product>'

DECLARE @nvarchar_d NVARCHAR(MAX) = N'<Product Name="Lenovo ThinkPad E460"><Ratings Value="4" Reviews="2"><Rating Value="5" Reviews="1" /><Rating Value="3" Reviews="1" /></Ratings></Product>'

DECLARE @xml XML = @nvarchar
      , @varchar VARCHAR(MAX) = @nvarchar
      , @xml_d XML = @nvarchar_d
      , @varchar_d VARCHAR(MAX) = @nvarchar_d

SELECT *
FROM (
    VALUES
          ('Unicode', DATALENGTH(@nvarchar),                             DATALENGTH(@nvarchar_d),
                      DATALENGTH(COMPRESS(@nvarchar)),                   DATALENGTH(COMPRESS(@nvarchar_d)))
        , ('ANSI',    DATALENGTH(@varchar),                              DATALENGTH(@varchar_d),
                      DATALENGTH(COMPRESS(@varchar)),                    DATALENGTH(COMPRESS(@varchar_d)))
        , ('XML',     DATALENGTH(@xml),                                  DATALENGTH(@xml_d), 
                      DATALENGTH(COMPRESS(CAST(@xml AS NVARCHAR(MAX)))), DATALENGTH(COMPRESS(CAST(@xml_d AS NVARCHAR(MAX)))))
) t(DataType, Delimeters, NoDelimeters, CompressDelimeters, CompressNoDelimeters)

------------------------------------------------------

-- COMPRESS/DECOMPRESS (2016+) using the GZIP algorithm

DECLARE @t TABLE (val VARBINARY(MAX))
INSERT INTO @t
VALUES (COMPRESS('<item val="123">')) -- VARCHAR(8000)
     , (COMPRESS(N'<item val="123">')) -- NVARCHAR(4000)

SELECT val
     , DECOMPRESS(val)
     , CAST(DECOMPRESS(val) AS NVARCHAR(MAX))
     , CAST(DECOMPRESS(val) AS VARCHAR(MAX))
FROM @t