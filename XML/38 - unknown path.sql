DECLARE @xml XML = '
<QueryPlan>
    <RelOp NodeId="0" PhysicalOp="Stream Aggregate">
        <StreamAggregate>
            <GroupBy>
                <ColumnReference Column="UnitPrice" />
            </GroupBy>
            <RelOp NodeId="1" PhysicalOp="Nested Loops">
                <NestedLoops>
                    <RelOp NodeId="3">
                        <RelOp NodeId="4" PhysicalOp="Index Scan">
                            <OutputList />
                            <IndexScan>
                                <Warnings NoJoinPredicate="1" />
                            </IndexScan>
                        </RelOp>
                    </RelOp>
                    <RelOp NodeId="7" PhysicalOp="Nested Loops">
                        <Warnings TempdbSpills="1" />
                    </RelOp>
                </NestedLoops>
            </RelOp>
        </StreamAggregate>
    </RelOp>
</QueryPlan>'

;WITH cte AS 
(
    SELECT [type] = t.c.value('local-name(.)', 'NVARCHAR(100)')
         , node = CAST(NULL AS XML)
         , x = t.c.query('./*')
    FROM @XML.nodes('*') t(c)

    UNION ALL

    SELECT t.c.value('local-name(.)', 'NVARCHAR(100)')
         , t.c.query('.')
         , t.c.query('./*')
    FROM cte
    CROSS APPLY x.nodes('*') t(c)
)
SELECT node
FROM cte
WHERE [type] = 'Warnings'

SELECT t.c.query('.')
FROM @xml.nodes('//Warnings') t(c)