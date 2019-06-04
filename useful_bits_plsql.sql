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

--if the table is a remote one
select column_name
  from all_tab_columns@WGUBI_PRDLOG
 where table_name = 'USERS';
 
--use to identify CLOB fields (cause problems)
select *
  from all_tab_columns@WGUBI_PRDLOG
 where table_name = 'COURSES_COSB'
 and data_type != 'CLOB'; 

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

--get everything before first occurence of a character (in example the . is the character)
select regexp_substr(objective_code, '[^.]+', 1, 1) as domain_code, objective_code

--get everything after the last occurence of a character
regexp_substr(full_objective_item_code, '[^.]*$') as competency_code

--oldest of two dates:
least([date1],[date2])

--last day of previous month (truncate if matching to another truncated date)
last_day(add_months(sysdate,-1))
--first day
trunc((quarter_end_date),'month') as release_cutoff


--create index on student_pidm & term_code combination
CREATE UNIQUE INDEX stud_dur3 ON LAX_STUD_DURATION_PREP3(student_pidm, term_code, course_number);

--a non-unique index
CREATE INDEX stud_crs_pass ON jo_stud_crs_passed(student_pidm, course_number);

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

--calculate percentile rank
select term_end_date, course_number, course_version, empowering_1
  ,percent_rank() over (partition by term_end_date order by empowering_1) as empower_ranking
from jo_crs_rank_prep2 

--alter table change column datatype (column must be empty to make the change)
alter table [table_name]
modify [column_name] [new_data_type];

--cast to a datatype in table creation (as a select statement from existing table/view)
create table jo_stud_crs_passed as 
select cast(student_pidm as varchar(15)) student_pidm, calendar_date, course_number 
  ,pass_sequence, course_completion
from wgubi.vw_rst_assessment; 

--running totals (can be handled for multiple fields at a time as shown)
--can use count(*) instead of sum([field_name]) if you want all rows preceding this row.
select student_pidm, calendar_date
  ,sum(not_engage) over (partition by student_pidm order by calendar_date rows unbounded preceding) as cnt_not_engage
  ,sum(not_attempt) over (partition by student_pidm order by calendar_date rows unbounded preceding) as cnt_not_attempt
  ,sum(not_pass) over (partition by student_pidm order by calendar_date rows unbounded preceding) as cnt_not_pass
  ,sum(pass_not_engage) over (partition by student_pidm order by calendar_date rows unbounded preceding) as cnt_pass_not_engage
  ,sum(passed) over (partition by student_pidm order by calendar_date rows unbounded preceding) as cnt_passed
from jo_crs_seq 
                                    
--running totals in both directions - can be in the same query!!!
  ,sum(cm_contact_other) over (partition by student_pidm, term_code, course_number order by calendar_date rows unbounded preceding) as CI_Contact_pre_critical
  ,sum(cm_contact_other) over (partition by student_pidm, term_code, course_number order by calendar_date desc rows unbounded preceding) as CI_Contact_post_critical
                                      

--rolling average for last 12 rows
select course_number, course_version, term_end_date
  ,avg(troubles) over (partition by course_number, course_version order by term_end_date rows between 11 preceding and current row) as avg_troubles_rolling_12
from jo_crs_rank_prep3
where course_number = 'AFT2';

--rolling average for last 12 months (when there isn't a 1 row to 1 month relationship)
select p3.course_number, p3.course_version, p3.term_end_date
  ,avg(rp3.troubles) as average_troubles
from jo_crs_rank_prep3 p3
  join jo_crs_rank_prep3 rp3
    on p3.course_number = rp3.course_number
    and p3.course_version = rp3.course_version
where trunc(rp3.term_end_date) >= trunc(last_day(add_months(p3.term_end_date,-12)))
and trunc(rp3.term_end_date) <= trunc(p3.term_end_date)
group by p3.course_number, p3.course_version, p3.term_end_date;

--sample given percentage of code
select * from lax_crs_duration sample(99); --number in parentheses is the sample % you are getting

--quick get non-completers (or non-[any category]
select ass.student_pidm, ass.course_number 
from wgubi.vw_rst_assessment ass
  left outer join (
    select student_pidm, course_number
    from wgubi.vw_rst_assessment
    --what do you want them NOT to have done?
    where course_completion = 1
    )fin
    on ass.student_pidm = fin.student_pidm
    and ass.course_number = fin.course_number
where fin.student_pidm is NULL;

--using variables in PL/SQL
variable_name [CONSTANT] datatype [NOT NULL] [:= | DEFAULT initial_value] 
--ex
course_number CONSTANT char(4)
course_number CONSTANT char(4) DEFAULT 'C270'
--set later
course_number := 'C278'

--change the size of a column -- new size must be big enough for existing data -- sql won't allow a modify if it is going to truncate
alter table [table name] modify ([field name], [new data type/size])

--one row per day between the two dates (term_fourth_month and term_last_month)
with maxspread as
  (select max( term_last_month-term_fourth_month )+1 days from lax_term_months_dlu ),
data as
  (select level l from maxspread connect by level <= days )
select term_fourth_month + l--, term_last_month
from data, lax_term_months_dlu
where l <= term_last_month-term_fourth_month
and term_code = 201709
order by 1;

--change timestamp
--if changing by days just add/subtract the int value of days
--if changing by hours add/subtract int hours divided by 24 -- so 5 hours would be 5/24

--be able to subtract hours from a timestamp where hours is a variable (d.UTC_TIME_DIFFERENCE) 
--this one comes from Tim Long
,(TO_TIMESTAMP(event_date||' '||hour||':'||minute||':'||second, 'DD-Mon-RR HH24:MI:SS') - NUMTODSINTERVAL(d.UTC_TIME_DIFFERENCE, 'HOUR')) as event_tstamp


--pivot
select * from (
select coin_market, p_date_typed, price_usd from (
select coin, coin || '_' || exchange as coin_market, p_date_typed, price_usd
from jo_p_test3 )y
)
pivot (max(price_usd) for (p_date_typed) in ('09-FEB-18','10-FEB-18','11-FEB-18','12-FEB-18','13-FEB-18') )

--pivot multiple 
create table JO_WR_1ST_C459_C278_P as
select * from (
select student_pidm, ca1_course_comp, ca1_comp_score, ca2_course_comp, ca2_comp_score from (
select *
from jo_wr_1st_C459_C278 )y
)
pivot (max(ca1_comp_score) for (CA1_COURSE_COMP) in ('C459-1','C459-2','C459-3','C459-4','C459-5','C459-6'))
pivot (max(ca2_comp_score) for (CA2_COURSE_COMP) in ('C278-1','C278-2','C278-3','C278-4','C278-5','C278-6'))

--pivot with alias (from https://stackoverflow.com/questions/22103060/oracle-pivot-query-gives-columns-with-quotes-around-the-column-names-what answer by ShoeLace)
with testdata as
(
    select 'Fred' First_Name, 10 Items from dual
    union
    select 'John' First_Name, 5  Items from dual
    union 
    select 'Jane' First_Name, 12 Items from dual
    union
    select 'Fred' First_Name, 15 Items from dual
)
select * from testdata
pivot (
      sum(Items) 
      for First_Name
      in ('Fred' as fred,'John' as john,'Jane' as jane)
      )

--insert multiple rows
INSERT ALL
  INTO mytable (column1, column2, column_n) VALUES (expr1, expr2, expr_n)
  INTO mytable (column1, column2, column_n) VALUES (expr1, expr2, expr_n)
  INTO mytable (column1, column2, column_n) VALUES (expr1, expr2, expr_n)

--remove red circle with white X
--first try recompiling the view
ALTER VIEW MY_VIEW COMPILE;
--next check for tables that the view references (when recompiling Oracle doesn't give the 'table or view doesn't exist' error even if one of the referenced tables isn't there.)

--find all of the synonyms
select * from sys.synonyms;

--The way Oracle handles ISNUMERIC ISSTUPID
where (LENGTH(TRIM(TRANSLATE(answer,' +-.0123456789', ' '))) > 1);

--percentiles
select percentile_cont(0.25) within group (order by item_duration asc) percentile_25
  ,percentile_cont(0.75) within group (order by item_duration asc) percentile_75
from wgubi.vw_rst_objective_assessment;  

--epoch to date
 select completion_date, to_char(to_date('19700101', 'YYYYMMDD') + ( 1 / 24 / 60 / 60 / 1000) * completion_date, 'YYYY-MM-DD HH24:MI:SS') as new_date
from mhe_vyc1;                  

 --deal with T & +00:00 in timestamp
  to_timestamp_tz(event_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS.ff6"+"TZH:TZM') as event_date
                   
--looking for constraints in the process of cleaning up tables                   
select table_name, constraint_name, status, owner
from all_constraints
where r_owner = 'WGUBISELECT'
and constraint_type = 'R'
and r_constraint_name in
 (
   select constraint_name from all_constraints
   where constraint_type in ('P', 'U')
   and table_name = 'LAX_STUD_TERM_SUMMARY'
   and owner = 'WGUBISELECT'
 )
order by table_name, constraint_name;

SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'LAX_STUD_TERM_SUMMARY';

--get substring from the end of the string
select substr(studentid,-6)                 

