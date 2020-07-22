DECLARE @x XML = N'
<messages>
    <message>
        <id>397300589</id>
        <pdu_id>673399673</pdu_id>
        <val>12</val>
        <id>397300589</id>
        <pdu_id>673399675</pdu_id>
        <val>13</val>
    </message>
    <message>
        <id>397300591</id>
        <pdu_id>673399669</pdu_id>
        <val>14</val>
        <id>397300591</id>
        <pdu_id>673399671</pdu_id>
        <val>15</val>
    </message>
</messages>'

SELECT id = MAX(CASE WHEN rn_group = 1 THEN val END)
     , pdu_id = MAX(CASE WHEN rn_group = 2 THEN val END)
     , val = MAX(CASE WHEN rn_group = 3 THEN val END)
FROM (
    SELECT val = t.c.value('(./text())[1]', 'BIGINT')
         , rn = ROW_NUMBER() OVER (ORDER BY 1/0)
         , rn_group = ISNULL(NULLIF(ROW_NUMBER() OVER (ORDER BY 1/0) % 3, 0), 3)
    FROM @x.nodes('/messages/message/*') t(c)
) t
GROUP BY rn - rn_group