/****ORACLE is EXTREMELY case-sensitive for names of tables/columns****/

--find all columns with a name sort of like this...
SELECT t.Table_Name AS table_name,
c.Column_Name AS column_name
FROM sys.All_Tables t
INNER JOIN sys.all_tab_columns c ON T.Table_Name = C.Table_Name
WHERE C.Column_Name LIKE '%DENO%' --change here as needed -- leave the '%' unless you are searching for the beginning or end of the string
ORDER BY T.Table_Name;

--can also be done like this:
select * from ALL_TAB_COLUMNS where owner='WGUBI' and COLUMN_NAME like 'COURSE_VERSION_ID%';

--all columns from a specific table -- includes nullable
SELECT 
t.Column_Name AS column_name, t.nullable
FROM sys.all_tab_columns t
WHERE t.Table_Name = 'ACTIVE_ASMT';

--update based on join -- requires privileges to update sys tables
update  
 (
select c.column_name, c.comments, co.comments as new_comments
from sys.all_col_comments c 
  left outer join (
    select column_name cn, comments 
    from sys.all_col_comments
    where table_name = 'RST_STUDENT'
    )co on c.column_name = co.cn
where c.table_name = 'JO_RST_STUDENT'
and co.comments is not NULL
)cu
set comments = new_comments
;

--update based on join where view is not updatable
update LAX_STUD_DURATION set LAX_STUD_DURATION.course_active_date = ( 
    select
      case when row_number () over (partition by student_pidm, term_code order by course_end_date) = 1 
          then term_start_date else lag(course_end_date) over (partition by student_pidm, term_code order by course_end_date) end as cad
      from LAX_STUD_DURATION a 
    where course_active_date is NULL  
      and LAX_STUD_DURATION.stud_duration_id = a.stud_duration_id
  ) ;



--find all of the tables or views referenced by a view list
select * from sys.all_dependencies
where type = 'VIEW' 
and referenced_type in ('TABLE','VIEW') --limiting the referenced object type
and name in ('VW_RST_STUDENT','VW_RST_ASSESSMENT') --list of views for which you want the dependencies
order by name
;

--code from lines 34-39 above -- set to return each referenced table only once even if it is a dependency for multiple views
select distinct(referenced_name) from 
  (
    select * from sys.all_dependencies
      where type = 'VIEW' 
    and referenced_type in ('TABLE','VIEW') --limiting the referenced object type
    and name in ('VW_RST_STUDENT','VW_RST_ASSESSMENT')
  )vw_dep; --originally abbreviated as 'vd' which was determined to be inappropriate
  
  --search for a table or view based on the name (or part of it)
select * from ALL_OBJECTS
where owner='WGUBI' and OBJECT_TYPE in ('TABLE','VIEW')
and OBJECT_NAME like '%COURSE_VERSION%';

--search text in functions and stored procedures for key word:
select * from all_source where text like '%VW_RST_STUDENT%';

--column remains usable but doesn't count towards select *
--requires Oracle 12 or newer
alter table mytable modify column undesired_col_name INVISIBLE;

--check oracle version
select * from v$version;

--get date part from date field
extract(month from [date_field])

--get everything before first occurence of a character
select regexp_substr(objective_code, '[^.]+', 1, 1) as domain_code, objective_code

--get everything after the last occurence of a character
regexp_substr(full_objective_item_code, '[^.]*$') as competency_code

--oldest of two dates:
least([date1],[date2])

--last day of previous month (truncate if matching to another truncated date)
last_day(add_months(sysdate,-1))

--create index on student_pidm & term_code combination
CREATE UNIQUE INDEX stud_dur3 ON LAX_STUD_DURATION_PREP3(student_pidm, term_code, course_number);

--gather stats for the table
begin 
  	DBMS_STATS.GATHER_TABLE_STATS (
  		--owner name should be changed to reflect new schema
  	ownname => '"WGUBISELECT"',
    tabname => '"LAX_STUD_DURATION_PREP3"',
    estimate_percent => 1
    );
end;

--create trigger to update the LAX_modified date automatically
set define off;
create or replace
TRIGGER WGUBISELECT.stud_crs_duration_update
BEFORE INSERT OR UPDATE ON WGUBISELECT.LAX_CRS_DURATION
FOR EACH ROW
BEGIN
   :new.LAX_modified := SYSTIMESTAMP;
END; 

--t test in SQL
select course_number, count(*) as N_count
  ,avg(decode(finished_course,'0',CCR,NULL)) CCR_finished_course
  ,avg(decode(finished_course,'1',CCR,NULL)) CCR_failed_course
  ,stats_t_test_indep(finished_course,CCR, 'STATISTIC', '1') t_observed
  ,stats_t_test_indep(finished_course, CCR) two_sided_p_value
from JO_TEST_CCR_DIFF_3
group by rollup (course_number)
