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
---end here 


with profile as(select distinct
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
end as Province,

Age,a.UserID,Channel2,
Recorddate2_new,`Duration 2`

from workspace.tv.viewership as a
left join workspace.tv.profiles as b
 on a.UserID = b.UserID) 

SELECT gender,race,CHANNEL2,PROVINCE,AGE,USERID,recorddate2_new,`Duration 2`,
      date_format(recorddate2_new, 'yyyy-MM-dd') AS Full_date,
      date_format(recorddate2_new, 'MMMM') AS Month_name,
      date_format(recorddate2_new, 'MM-yyyy') AS Month_id,
      date_format(recorddate2_new, 'EEEE') AS Weekday,
      date_format(recorddate2_new, 'HH:mm') AS TIME,
      date_format(`duration 2`, 'HH:mm') AS DURATION,

    -- Duration Group
    CASE
        WHEN `Duration 2` BETWEEN '00:00' AND '00:14' THEN 'Short_View_00:00-00:14'
        WHEN `Duration 2` BETWEEN '00:15' AND '00:59' THEN 'Standard_View_00:15-00:59'
        WHEN `Duration 2` BETWEEN '01:00' AND '02:59' THEN 'Engaged_View_01:00-02:59'
        ELSE 'Marathon_View_03:00-11:59'
    END AS Duration_Group,

    -- Time of Day Group
    CASE
        WHEN date_format(recorddate2_new, 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'Morning_06:00-11:59'
        WHEN date_format(recorddate2_new, 'HH:mm') BETWEEN '12:00' AND '16:59' THEN 'Afternoon_12:00-16:59'
        WHEN date_format(recorddate2_new, 'HH:mm') BETWEEN '17:00' AND '21:59' THEN 'Evening_17:00-21:59'
        ELSE 'Night_22:00-05:59'
    END AS Time_Group,

    -- Age Group
    CASE
        WHEN age BETWEEN 0 AND 12 THEN 'Children_0-12'
        WHEN age BETWEEN 13 AND 19 THEN 'Teen_13-19'
        WHEN age BETWEEN 20 AND 39 THEN 'Young_Adults_20-39'
        WHEN age BETWEEN 40 AND 59 THEN 'Middle_Aged_Adults_40-59'
        ELSE 'Seniors_60+'
    END AS Age_Basket,

    COUNT(userid) AS Total_Viewership,
    COUNT(DISTINCT userid) AS Total_Customers,
    COUNT(channel2) AS Total_Channel_Views,
    COUNT(DISTINCT channel2) AS Total_Channels,
    ROUND(AVG(age), 0) AS Average_Age

FROM PROFILE

GROUP BY 
     Full_Date, Month_Name, Month_ID, Weekday, Time, Duration, 
     Duration_Group, Time_Group, Age_Basket,gender,race,CHANNEL2,
     PROVINCE,AGE,USERID,recorddate2_new,`Duration 2`

ORDER BY
      Month_ID, Full_Date, Time;
     ;
