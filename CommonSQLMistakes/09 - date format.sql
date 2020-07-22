SELECT GETDATE()

/*
    SELECT *
    FROM sys.objects
    WHERE create_date < ''
*/

------------------------------------------------------------------

SET LANGUAGE English
SET DATEFORMAT DMY

DECLARE @d1 DATETIME = '05/12/2016'
      , @d2 DATETIME = '2016/12/05'
      , @d3 DATETIME = '2016-12-05'
      , @d4 DATETIME = '05-dec-2016'

SELECT @d1, @d2, @d3, @d4
GO

SET DATEFORMAT MDY

DECLARE @d1 DATETIME = '05/12/2016'
      , @d2 DATETIME = '2016/12/05'
      , @d3 DATETIME = '2016-12-05'
      , @d4 DATETIME = '05-dec-2016'

SELECT @d1, @d2, @d3, @d4
GO

DECLARE @t TABLE (a DATETIME)
--SET DATEFORMAT DMY
INSERT INTO @t VALUES ('05/13/2016')
GO

------------------------------------------------------------------

SET DATEFORMAT YMD

SET LANGUAGE English

DECLARE @d1 DATETIME = '2016/01/12'
      , @d2 DATETIME = '2016-01-12'
      , @d3 DATETIME = '12-jan-2016'
      , @d4 DATETIME = '20160112'

SELECT @d1, @d2, @d3, @d4
GO

SET LANGUAGE Deutsch

DECLARE @d1 DATETIME = '2016/01/12'
      , @d2 DATETIME = '2016-01-12'
      , @d3 DATETIME = '12-jan-2016'
      , @d4 DATETIME = '20160112'

SELECT @d1, @d2, @d3, @d4
GO

------------------------------------------------------------------

SET LANGUAGE French
DECLARE @d DATETIME = '12-jan-2016'

------------------------------------------------------------------

SET LANGUAGE English
SET DATEFORMAT YMD

DECLARE @d1 DATE = '2016-01-12'
      , @d2 DATETIME = '2016-01-12'

SELECT @d1, @d2
GO

SET LANGUAGE Deutsch
SET DATEFORMAT DMY

DECLARE @d1 DATE = '2016-01-12'
      , @d2 DATETIME = '2016-01-12'

SELECT @d1, @d2