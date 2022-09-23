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
                                 
--charindex code
charindex('!',feedback)
                                   
--substrings start at 1 NOT 0 
--this is taking the substring up to - and including - the first period                                   
substring(feedback,1,charindex('.',feedback) + 1)               

--converting from epoch time (data might measure in seconds not milliseconds, if milliseconds, add " / 1000" after the "/ 60 / 60" for the calculation)
to_char(to_date('19700101', 'YYYYMMDD') + ( 1 / 24 / 60 / 60 ) * startedon, 'YYYY-MM-DD HH24:MI:SS') as new_date 

--connecting to snowflake from sagemaker
-- Open a terminal instance from Jupyter
-- Install the libffi-devel package ( sudo yum install libffi-devel )
-- Open a new notebook (I used the conda_python3 kernel)
-- In the notebook, install with !pip install snowflake-connector-python

--converting timezones -- use https://en.wikipedia.org/wiki/List_of_tz_database_time_zones for reference
    ,convert_timezone('UTC','America/New_York', last_session_end) as last_session_end

--combining multiple records into a list in one record
LISTAGG(distinct catalog, '; ') WITHIN GROUP ( order by catalog ) as fall_math_enrollments
