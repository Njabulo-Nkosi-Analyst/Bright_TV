----EDA
---base table
---userid,channel2,recorddate2,duration2 
  select * from workspace.tv.viewership;
---checking data type
  describe  workspace.tv.viewership;

----checking duplicates
select count(*) as `row count`--10000
, count(distinct userid) as `total customer`,
UserID---4386
from workspace.tv.viewership
group by userid
having `row count`> 1
order by `row count` desc ;--have duplicates
---count total channel
select count(distinct Channel2)as `total channels`
,
date_format(recorddate2_new, 'MMMM') AS Month_name---21
from workspace.tv.viewership
group by month_name
;

---null value
select `Recorddate2_new`, `Channel2`, `Duration 2`
from workspace.tv.viewership
where `channel2` IS NULL
  OR `Recorddate2_new` IS NULL
  OR  `Duration 2` IS NULL;---no null value

`Recorddate2_new`, `Channel2`, `Duration 2` ;

---------------------------------------------------------------- 
-----second table
---userid,gender,age,race,province
select *
from workspace.tv.profiles;

----checking data type
describe workspace.tv.profiles;

---checking null value
 select userid,gender,age,race,province
 from workspace.tv.profiles
 where userid is null or gender is null or age is null or race is null or province is null;----no null

----checking duplicates

select count(*) as `row count`,
     ----  count (distinct userid) as customer 
       userid
       from workspace.tv.profiles
       group by `userid`
       having count(*)>1;

---checking gender column
select distinct gender 
  from workspace.tv.profiles;

with profile as(select 
    case 
        when gender is null or trim(gender) = '' or gender = 'None' then 'unknown'
        else gender
    end as gender,
    case when race in ('other/none comined') then 'Unknown'
    when trim(race) ='' or race ='None' then 'unknown'
    else Race
    end as Race,
case   when trim(Province) ='' or Province ='None' then 'unknown'    
else Province
end as Province,Age,a.UserID,Channel2,Recorddate2_new,`Duration 2`,
---date
  date_format(recorddate2_new, 'yyyy-MM-dd') AS    Full_date,
      date_format(recorddate2_new, 'MMMM') AS Month_name,
      date_format(recorddate2_new, 'MM-yyyy') AS Month_id,
      date_format(recorddate2_new, 'EEEE') AS Weekday,
      date_format(recorddate2_new, 'HH:mm') AS TIME,
      date_format(`duration 2`, 'HH:mm') AS DURATION,
---CASE STATEMENT(TIME)
 case 
     when TIME between '06:00'and'11:59' then 'Morning_06:00-11:59' 
     when  TIME between '12:00'and'16:59' then 'Afternoon_12:00-16:59'
     when  TIME between '17:00'and'21:59' then 'Evening_17:00-21:59'
     else 'Night_22:00-05:59'
     end as Time_Group,
---CASE STATEMENT(DURATION)     
case 
    when DURATION  between '00:00'and '00:14' then 'Short_View_00:00-00:14'
    when DURATION between '00:15' and'00:59' then 'Standard_View_00:15-00:59'
    when DURATION between '01:00' and '02:59' then 'Engaged_View_01:00-02:59'
    else 'Marathon_view_03:00-11:59'
    end as Duration_Group,
    case 
    when age between 0 and 12 then 'Children_0-12'
    when age between 13 and 19 then 'Teen_13-19'
    when age between 20 and 39 then  'Young_Adults_20-39'     
    when age between 40 and 59 then 'Middle_Aged_Adults_40-59'
    else 'Seniors_60+' 
    end as Age_basket 
from workspace.tv.viewership as a
left join workspace.tv.profiles as b
on a.userid = b.userid
 ) select  *, COUNT(userid) AS Total_viewership,
    COUNT(DISTINCT userid) AS total_customers, 
    COUNT(channel2) AS total_channel,
    COUNT(distinct channel2) AS total_channels,
     ROUND(AVG(AGE),0) AS AVERAGE_AGE 
     from profile
     group by gender,race,province,age,userid,channel2,Recorddate2_new,`Duration 2`,full_date,month_id,month_name,
     weekday,time,duration,time_group,duration_group,age_basket
     ;
