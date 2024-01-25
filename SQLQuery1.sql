create database hr;
use hr;
select * from hr_data;

update hr_data
set termdate= FORMAT(CONVERT(DATETIME,LEFT(termdate,19),120),'yyyy-MM-dd');

alter table hr_data add new_termdate DATE;


-- copy converted time value from termdate to new_termdate
update hr_data set new_termdate=case
when termdate is not null and isdate(termdate)=1 then cast (termdate as DATETIME) else null end;

UPDATE hr_data
SET new_termdate = CASE
 WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST(termdate AS DATETIME) ELSE NULL
 END;

 -- create new column "age"
 alter table hr_data add age nvarchar(50);
 -- populate new column with age

update hr_data set age=datediff(YEAR,birthdate,getdate());


-- QUESTION FROM THE DATA THAT MUST BE ANSWERED
-- 1- What is the age distribution in the company

select min(age) as youngest,max(age) as oldest from hr_data;

--- Age group by gender
SELECT age_group,
count(*) AS count FROM (SELECT CASE
  WHEN age <= 21 AND age <= 30 THEN '21 to 30'
  WHEN age <= 31 AND age <= 40 THEN '31 to 40'
  WHEN age <= 41 AND age <= 50 THEN '41 to 50'
  WHEN age>50 THEN '50+'
  ELSE '50+'
  END AS age_group
 FROM hr_data WHERE new_termdate IS NULL) AS subquery GROUP BY age_group ORDER BY age_group;

 --- Age group by gender
 SELECT age_group,gender,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age <= 21 AND age <= 30 THEN '21 to 30'
  WHEN age <= 31 AND age <= 40 THEN '31 to 40'
  WHEN age <= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group,gender
 FROM hr_data
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group,gender
ORDER BY age_group,gender;

---2 What is the gender breakdown in the company
select gender,count(gender) as count from hr_data where new_termdate is null group by gender order by gender asc; 

---3 How does the gender vary accross department and job titles

SELECT department,gender,count(gender) AS count FROM hr_data
WHERE new_termdate IS NULL GROUP BY department, gender ORDER BY department, gender ASC;

-- Job titles
SELECT 
department,jobtitle,
gender,
count(gender) AS count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender,jobtitle
ORDER BY department, gender,jobtitle ASC;

--4- Race distribution in the company
select race,count(*) as count from hr_data where new_termdate is null group by race order by count desc;

---5- The average length of employment in the company
select avg(datediff(year,hire_date,new_termdate)) as tenure from hr_data where new_termdate is not null and new_termdate <=getdate();

--6- The department that has the higest turnover rate
--get total count
-- get terminated count
-- terminated count/total count
SELECT department, total_count, terminated_count,(round((CAST(terminated_count AS FLOAT)/total_count), 2)) * 100 AS turnover_rate
 FROM (SELECT  department, count(*) AS total_count, SUM(CASE WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
		END) AS terminated_count
	FROM hr_data GROUP BY department ) AS subquery ORDER BY turnover_rate DESC;

---7 The tenure distribution for each department
select department,avg(datediff(year,hire_date,new_termdate)) as tenure from hr_data where new_termdate is not null and new_termdate<=getdate()
group by department order by tenure desc;

--8 How many employees work remotly for each department
--select count(*) as count,department  from hr_data where location ='Remote' group by department;
select location, count(*) as count from hr_data where new_termdate is null group by location;

--9 The distribution of employees accross different states
select location_state, count(*) as count from hr_data where new_termdate is null group by location_state order by count desc;

--10 How are job title distribution in the company
select jobtitle ,count(*) as count from hr_data where new_termdate is null group by jobtitle order by count desc;

--11 How have employee hire counts varied  time
-- Calculate hires
--calculate terminations
--(hires-terminations)/hires percent hire charge

SELECT hire_year, hires, terminations,
 hires - terminations AS net_change,
 (round(CAST(hires-terminations AS FLOAT)/hires, 2)) * 100 AS percent_hire_change
 FROM
	(SELECT 
	 YEAR(hire_date) AS hire_year,
	 count(*) AS hires,
	 SUM(CASE
			WHEN new_termdate is not null and new_termdate <= GETDATE() THEN 1 ELSE 0
			END
			) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)) AS subquery ORDER BY percent_hire_change ASC;







