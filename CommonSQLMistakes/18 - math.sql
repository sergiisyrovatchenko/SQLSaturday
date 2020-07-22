SELECT 1 / 3
SELECT 1.0 / 3

----------------------------------------------------

SELECT COUNT(*)
     , COUNT(1)
     , COUNT(val)
     , COUNT(DISTINCT val)
     , SUM(val)
     , SUM(DISTINCT val)
FROM (
    VALUES (1), (2), (2), (NULL), (NULL)
) t (val)

SELECT AVG(val)
     , SUM(val) / COUNT(val)
     , AVG(val * 1.)
     , AVG(CAST(val AS FLOAT))
FROM (
    VALUES (1), (2), (2), (NULL), (NULL)
) t (val)