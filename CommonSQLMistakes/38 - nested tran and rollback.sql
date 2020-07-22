DROP TABLE IF EXISTS #tran
CREATE TABLE #tran (id INT)
GO

BEGIN TRAN --1

INSERT INTO #tran VALUES (1)

    BEGIN TRAN --2

    INSERT INTO #tran VALUES (2)

    ROLLBACK -- 2?

SELECT @@trancount

SELECT * FROM #tran

---------------------

DROP TABLE IF EXISTS #tran
CREATE TABLE #tran (id INT)
GO

BEGIN TRAN tr1

    INSERT INTO #tran VALUES(1)
    SELECT * FROM #tran

    BEGIN TRAN tr2
        SAVE TRAN tr2

        INSERT INTO #tran VALUES(2)
        SELECT * FROM #tran

        SELECT @@trancount

    ROLLBACK TRAN tr2
    SELECT * FROM #tran

ROLLBACK TRAN tr1

SELECT * FROM #tran