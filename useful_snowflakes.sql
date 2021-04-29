--find populated tables with column name like so
select c.TABLE_SCHEMA, c.table_name, c.column_name, t.ROW_COUNT
from x.INFORMATION_SCHEMA.COLUMNS c
    join x.INFORMATION_SCHEMA.TABLES t on c.TABLE_NAME = t.TABLE_NAME and c.TABLE_SCHEMA = t.TABLE_SCHEMA
where COLUMN_NAME like '%CLUST%'
and t.ROW_COUNT > 0;

--change default role for the server
--avoids the nuisance of switching, plus it's useful for connecting other applications like Tableau
alter user SET DEFAULT_ROLE = (name of the role that should be the default)

--pivot (slightly different syntax)
select * from (
select cluster_name, outcome, records from (
select *
from /table name here/ )y
) pivot (max(records) for outcome in ('dfw','pass'));

--pivot with alias (to deal with the issue of quoted strings as column names
select cluster_name, "'pass'" AS passed, "'dfw'" AS failed 
from /table name here/
pivot(max(records) for outcome IN ('dfw', 'pass')) as p;                                      
                                    
--date add (in this case adding six days to the date field)
dateadd(day,6,START_DATE)
                                   
--regex expressions
--in this example pulling the exercise number from a field in this structure "chapter 10 section 4 exercise 31"                                   
regexp_substr(chapter_section_exercise, 'exercise\\W+(\\w+)', 1, 1, 'e', 1) as "exercise"                                    

--snowflake doesn't support now() - use current_date() function instead
and "Assignment Due Date" <= current_date()                                   

--alternative option to cast
message:autobahnMetadata:receivedDt::datetime -- the ::datetime casts the field as a datetime data type                                   
                                 
