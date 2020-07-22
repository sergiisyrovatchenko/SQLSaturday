DECLARE @x XML = N'<html><body><b>Value:</b><i>2</i></body></html>'

SELECT @x.value('.', 'NVARCHAR(MAX)')
GO

DECLARE @x NVARCHAR(MAX) = N'<p>Value:<br><br><b>2</b></p><html>'

SELECT x.value('.', 'NVARCHAR(MAX)')
FROM (
    SELECT x = CAST(REPLACE(REPLACE(@x, '>', '/>'), '</', '<') AS XML)
) r