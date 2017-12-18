--create tables
create table jo_1 (
  id number primary key,
  start_date date not null check (start_date = trunc(start_date)),
  end_date date not null check (end_date = trunc(end_date)),
  check (end_date > start_date)
);

create table jo_2 (
  id number,
  review_date date not null check (review_date = trunc(review_date)),
  group_id varchar2(20) not null,
  primary key (id, review_date)
);



alter session set nls_date_format='DD';
 
--insert to jo_1 
insert into jo_1 select
0, to_date(1),to_date(2) from dual union all select
1, to_date(1),to_date(2) from dual union all select
2, to_date(1),to_date(2) from dual union all select
3, to_date(1),to_date(3) from dual union all select
4, to_date(1),to_date(3) from dual union all select
5, to_date(1),to_date(4) from dual union all select
6, to_date(1),to_date(2) from dual union all select
7, to_date(1),to_date(2) from dual union all select
8, to_date(1),to_date(3) from dual union all select
9, to_date(2),to_date(3) from dual union all select
10, to_date(2),to_date(3) from dual union all select
11, to_date(2),to_date(4) from dual union all select
12, to_date(2),to_date(3) from dual union all select
13, to_date(3),to_date(4) from dual;
 
insert into jo_1
select id+13, start_date, end_date
from jo_1
where id > 0;


--insert to jo_2
insert into jo_2 select
1, to_date(3),'precedes' from dual union all select
2, to_date(2),'meets' from dual union all select
3, to_date(2),'overlaps' from dual union all select
4, to_date(2),'finished by' from dual union all select
5, to_date(2),'contains' from dual union all select
6, to_date(1),'starts' from dual union all select
7, to_date(1),'equals' from dual union all select
8, to_date(1),'started by' from dual union all select
9, to_date(1),'during' from dual union all select
10, to_date(1),'finishes' from dual union all select
11, to_date(1),'overlapped by' from dual union all select
12, to_date(1),'met by' from dual union all select
13, to_date(1),'preceded by' from dual;
 
insert into jo_2
select id+13, review_date, group_id from jo_2;
 
insert into jo_2
select id,
review_date +
case when group_id = 'during' then 3
  when group_id in ('overlaps','starts','finishes','overlapped by') then 2
  else 1
end,
'after ' || group_id
from jo_2
where id > 13;
commit;


alter session set nls_date_format='yyyy-mm-dd';