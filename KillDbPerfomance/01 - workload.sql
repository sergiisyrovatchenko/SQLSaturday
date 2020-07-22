USE KillDB
GO

DROP TABLE IF EXISTS dbo.WorkTable
GO

CREATE TABLE dbo.WorkTable (
      RecordID INT IDENTITY
    , TextData1 CHAR(4000) NOT NULL DEFAULT 'aaa'
    , TextData2 CHAR(3000) NOT NULL DEFAULT 'aaa'
    , LobData NVARCHAR(MAX)
    , INDEX pk UNIQUE CLUSTERED (RecordID)
)
GO

DROP TABLE IF EXISTS dbo.LogTable
GO

CREATE TABLE dbo.LogTable (
      RecordID INT
    , StartTime DATETIME2 NOT NULL
    , EndTime DATETIME2 NOT NULL
    , INDEX pk UNIQUE CLUSTERED (RecordID)
)

------------------------------------------------------

SET NOCOUNT ON
DECLARE @date DATETIME
      , @lob NVARCHAR(MAX) = REPLICATE(CAST('a' AS NVARCHAR(MAX)), 8000)

WHILE 1=1 BEGIN

    SET @date = GETDATE()

    INSERT INTO dbo.WorkTable (LobData) VALUES (@lob)

    DECLARE @id INT = SCOPE_IDENTITY()

    INSERT INTO dbo.LogTable (RecordID, StartTime, EndTime)
    VALUES (@id, @date, GETDATE())

    IF @id % 500 = 0 BEGIN

        ;WITH cte AS 
        (
            SELECT TOP(10) PERCENT *
            FROM dbo.WorkTable
            ORDER BY NEWID()
        )
        DELETE FROM cte

    END

    WAITFOR DELAY '00:00:00.040'

END

/*
    perfmon

    Transactions/sec
    Data File(s) Size (KB)
    Log File(s) Size (KB)
    Log File(s) Used Size (KB)
*/