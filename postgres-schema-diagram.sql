WITH
  table_info AS (
    SELECT
      t.table_schema,
      t.table_name,
      c.column_name
    FROM
      information_schema.tables AS t
      JOIN information_schema.columns AS c
        ON t.table_schema = c.table_schema
        AND t.table_name = c.table_name
    WHERE
      t.table_type = 'BASE TABLE'
  ),
  primary_keys AS (
    SELECT
      ccu.table_schema,
      ccu.table_name,
      ccu.column_name
    FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.constraint_column_usage AS ccu
        ON tc.constraint_schema = ccu.constraint_schema
        AND tc.constraint_name = ccu.constraint_name
    WHERE
      tc.constraint_type = 'PRIMARY KEY'
  ),
  foreign_keys AS (
    SELECT
      ccu.table_schema,
      ccu.table_name,
      ccu.column_name,
      kcu.table_schema AS key_table_schema,
      kcu.table_name AS key_table_name,
      kcu.column_name AS key_column_name
    FROM
      information_schema.table_constraints AS tc
      JOIN information_schema.constraint_column_usage AS ccu
        ON tc.constraint_schema = ccu.constraint_schema
        AND tc.constraint_name = ccu.constraint_name
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_schema = kcu.constraint_schema
        AND tc.constraint_name = kcu.constraint_name
    WHERE
      tc.constraint_type = 'FOREIGN KEY'
  )

SELECT '
digraph structs {
'
UNION ALL

SELECT '
rankdir="LR"
'
UNION ALL

SELECT '
node [shape=none]
'
UNION ALL

SELECT
  CASE
    WHEN LAG(t.table_schema || '.' || t.table_name) OVER () = t.table_schema || '.' || t.table_name THEN ''
    ELSE
      '"' || t.table_schema || '.' || t.table_name || '" [label=<
      <TABLE BORDER="0" CELLSPACING="0" CELLBORDER="1">
        <TR>
          <TD COLSPAN="2"><B>' ||
            CASE
              WHEN t.table_schema = current_schema THEN t.table_name
              ELSE t.table_schema || '.' || t.table_name
            END ||
          '</B></TD>
        </TR>
      '
    END || '
        <TR>
          <TD PORT="' || t.column_name || '_to">' ||
            CASE WHEN p.column_name IS NULL THEN '&nbsp;' ELSE '🔑' END ||
          '</TD>
          <TD PORT="' || t.column_name || '_from">' || t.column_name || '</TD>
        </TR>
      ' ||
  CASE
    WHEN LEAD(t.table_schema || '.' || t.table_name) OVER () = t.table_schema || '.' || t.table_name THEN ''
    ELSE '
      </TABLE>
    >];
    '
  END
FROM
  table_info AS t
  LEFT JOIN primary_keys AS p
    ON t.table_schema = p.table_schema
    AND t.table_name = p.table_name
    AND t.column_name = p.column_name
WHERE
  t.table_schema NOT LIKE 'pg_%' AND t.table_schema != 'information_schema'
UNION ALL

SELECT
  '"' || f.key_table_schema || '.' || f.key_table_name || '":' || f.key_column_name || '_from:e -> ' ||
  '"' || f.table_schema || '.' || f.table_name || '":' || f.column_name || '_to:w'
FROM
  foreign_keys AS f
WHERE
  f.table_schema NOT LIKE 'pg_%' AND f.table_schema != 'information_schema'
UNION ALL

SELECT '
}';
