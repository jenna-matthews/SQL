--find populated tables with column name like so
select c.TABLE_SCHEMA, c.table_name, c.column_name, t.ROW_COUNT
from x.INFORMATION_SCHEMA.COLUMNS c
    join x.INFORMATION_SCHEMA.TABLES t on c.TABLE_NAME = t.TABLE_NAME and c.TABLE_SCHEMA = t.TABLE_SCHEMA
where COLUMN_NAME like '%CLUST%'
and t.ROW_COUNT > 0;
