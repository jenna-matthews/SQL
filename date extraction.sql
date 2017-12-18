--get time values from date field
select
  to_char(log_date,'RRRR') year, 
  to_char(log_date,'MM') MONTH, 
  to_char(log_date,'DD') DAY, 
  to_char(log_date,'HH:MM:SS') TIME 
from 
  wgubi.stg_log_entry
--add some limits so the query doesn't run forever...   
where trunc(log_date) =   '07-OCT-10'
and rownum < 10
group by 
  to_char(log_date,'RRRR'), 
  to_char(log_date,'MM'), 
  to_char(log_date,'DD'), 
  to_char(log_date,'HH:MM:SS') 
 ORDER BY 1, 2; 

 --can combine char parts to do comparisons -- all records before noon on the 30th...
 where to_char(log_date, 'DD HH:MM:SS') = '30 12:00:00'