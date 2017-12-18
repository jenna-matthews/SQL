--last_day gets the last day of the month
--months_between will calculate months between two dates 
--for days between just subtract the dates
--years between get days or month difference and roll up (days is better)

select id, column_value each_date, start_date, end_date, 
  --dates can be compared using basic comparison operators
  case when column_value >= review_date then review_date end review_date, 
  case when column_value >= review_date then group_id end group_id
from (
  select a.id, start_date, end_date, review_date, group_id,
  case when prev_rd is null
    then start_date
    --dates can also be handled using greatest or least - syntax is similar to coalesce but it evaluates all simultaneously
    --greatest & least are not limited to two values -- can evaluate with more
    --(max evaluates each record for a column -- greatest/least gets highest column for row)
    else greatest(start_date, review_date)
  end range_start,
  case when end_rd is null
    then end_date
    else least(end_date, end_rd)
  end range_end
  from jo_1 a
  left join (
    select review_date, group_id, id, --these fields are handled similar to a group by for the lead/lag functions -- they specify which fields are forming groups
    --lead pulls the next value -- requires partition and order by (which can be the same field as shown)
    lead(review_date) over (partition by id order by review_date) end_rd, --can order by descending
      --partition with multiple works like inner-join -- order with multiple uses subsets
    --lag pulls the last value -- also requires partition and order by
    lag(review_date) over (partition by id order by review_date) prev_rd
    from jo_2
  ) b
  on a.id = b.id
    and start_date < coalesce(end_rd, end_date)--coalesce can be used on date fields and as part of a comparison equation
    and end_date > review_date
) 
,
--this section provides the column value (used for each_date) field and the comparisons above
--that column value is used to identify the groups (group_id in the results)
table(cast(multiset(
  select range_start-1+level from dual
  connect by range_start-1+level < range_end
) as sys.odcidatelist))
order by id, each_date;

--both <> and != can be used to compare dates (both are not equals) but after Oracle 10.2 != executes more quickly
--18 records in 0.041 seconds
select * from jo_1 a
  left join (
    select review_date, group_id, id, --these fields are handled similar to a group by for the lead/lag functions -- they specify which fields are forming groups
    --lead pulls the next value -- requires partition and order by (which can be the same field as shown)
    lead(review_date) over (partition by id order by review_date) end_rd,
    --lag pulls the last value -- also requires partition and order by
    lag(review_date) over (partition by id order by review_date) prev_rd
    from jo_2
  ) b
  on a.id = b.id
    and start_date < coalesce(end_rd, end_date) --coalesce can be used on date fields and as part of a comparison equation
    and end_date > review_date where start_date <> review_date;

--18 records in 0.033 seconds
select * from jo_1 a
  left join (
    select review_date, group_id, id, --these fields are handled similar to a group by for the lead/lag functions -- they specify which fields are forming groups
    --lead pulls the next value -- requires partition and order by (which can be the same field as shown)
    lead(review_date) over (partition by id order by review_date) end_rd,
    --lag pulls the last value -- also requires partition and order by
    lag(review_date) over (partition by id order by review_date) prev_rd
    from jo_2
  ) b
  on a.id = b.id
    and start_date < coalesce(end_rd, end_date) --coalesce can be used on date fields and as part of a comparison equation
    and end_date > review_date where start_date != review_date;