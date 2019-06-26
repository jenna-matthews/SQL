--show all public tables with records
select * from (
select table_schema, table_name,
       (xpath('/row/count/text()', query_to_xml('select count(*) from '||format('%I.%I', table_schema, table_name), true, true, '')))[1]::text::int as row_count
from information_schema.tables
	--temporary condition
	where table_schema = 'public'
	)y
where row_count > 0
order by row_count desc

--find tables/columns with name like ...
select t.table_schema,
       t.table_name, c."column_name"
from information_schema.tables t
inner join information_schema.columns c on c.table_name = t.table_name 
                                and c.table_schema = t.table_schema
where c.column_name like '%pk1%'
      and t.table_schema not in ('information_schema', 'pg_catalog')
      and t.table_type = 'BASE TABLE'
      and t."table_name" like '%resou%'
order by t."table_name";
