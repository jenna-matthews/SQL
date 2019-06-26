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
