/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'C:\Program Files\PostgreSQL\18\data\Datasets\sql_course\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\Program Files\PostgreSQL\18\data\Datasets\sql_course\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\Program Files\PostgreSQL\18\data\Datasets\sql_course\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Program Files\PostgreSQL\18\data\Datasets\sql_course\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


select job_title_short as title,
job_location as location,
job_posted_date :: date as date
from job_postings_fact;

select job_title_short as title,
job_location as location,
job_posted_date at time zone 'UTC' at time zone 'est' as date_time
from job_postings_fact
limit 5

select job_title_short as title,
job_location as location,
job_posted_date at time zone 'UTC' at time zone 'est' as date_time,
extract(month from job_posted_date) as date_month,
extract(year from job_posted_date) as date_year
from job_postings_fact
limit 5

select count(job_id),
extract(month from job_posted_date) as month 
from job_postings_fact
GROUP BY month

select count(job_id) as job_posted_count,
extract(month from job_posted_date) as month
from job_postings_fact
where job_title_short = 'Data Analyst'
GROUP BY month
order by job_posted_count desc

create table january_jobs AS 
    select * 
    from job_postings_fact
    where extract(month from job_posted_date) = 1;

create table february_jobs AS
    select * 
    from job_postings_fact
    where extract(month from job_posted_date) = 2;

create table march_jobs AS
    select *
    from job_postings_fact
    where extract(month from job_posted_date) = 3;

select * from march_jobs;

SELECT 
    job_title_short,
    job_location,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'  
        ELSE 'Onsite'
    END AS location_category
from job_postings_fact;

SELECT 
    count(job_id) as number_of_jobs,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'  
        ELSE 'Onsite'
    END AS location_category
from job_postings_fact
where job_title_short = 'Data Analyst'
GROUP BY location_category;

SELECT
    salary_year_avg,
    CASE
        WHEN salary_year_avg < 12000 THEN 'Low'
        WHEN salary_year_avg BETWEEN 12000 AND 50000 THEN 'Standard'
        WHEN salary_year_avg > 50000 THEN 'High'
        ELSE 'No Salary'
    END AS salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;

with january_jobs AS(  --CTE (common table expression)
    select *
    from job_postings_fact
    where extract(month from job_posted_date) = 1
)
select
* from january_jobs;

select 
    company_id,
    job_no_degree_mention
from
    job_postings_fact
WHERE
    job_no_degree_mention = true;

-- subqueries
select 
    company_id,
    name as company_name
from 
    company_dim 
where company_id in (
    select 
        company_id
    from
        job_postings_fact
    WHERE
        job_no_degree_mention = true
)

/*
Find the companies that have the most job openings.
- get the total number of job postings per company id
- return the total number of jobs with the company name
*/

with company_job_count as (
    SELECT
        company_id,
        count(*) as total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT
    company_dim.name as company_name,
    company_job_count.total_jobs
FROM    
    company_dim
LEFT JOIN company_job_count on company_job_count.company_id = company_dim.company_id
ORDER BY
    total_jobs DESC


select count(skill_id) , skills.skills_dim , job_id from skills_job_dim
GROUP BY job_id



/*
Practice Problem 1 ?
Question:

Identify the top 5 skills that are most frequently mentioned in job postings.
 Use a subquery to find the skill IDs with the highest counts in the skills_job_dim table 
 and then join this result with the skills_dim table to get the skill names.

*/

--using CTEs
WITH top_5_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY skill_count DESC
    LIMIT 5
)

SELECT
    s.skills,
    t.skill_count
FROM top_5_skills AS t
JOIN skills_dim AS s
    ON t.skill_id = s.skill_id
ORDER BY t.skill_count DESC;

--using Subquery
SELECT
    s.skills,
    t.skill_count
FROM (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY skill_count DESC
    LIMIT 5
) AS t
JOIN skills_dim AS s
    ON t.skill_id = s.skill_id
ORDER BY t.skill_count DESC;

/*
Practice Problem 2
? Question:

Determine the size category ('Small', 'Medium', or 'Large') for each company 
by first identifying the number of job postings they have.
 Use a subquery to calculate the total job postings per company. 
 A company is considered 'Small' if it has less than 10 job postings,
  'Medium' if the number of job postings is between 10 and 50, and 'Large' 
  if it has more than 50 job postings. Implement a subquery to aggregate job 
  counts per company before classifying them based on size.
*/



SELECT
    company_id,
    job_count,
    CASE
        WHEN job_count < 10 THEN 'Small'
        WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
        WHEN job_count > 50 THEN 'Large'
    END AS size_category
FROM (
    SELECT
        company_id,
        COUNT(job_id) AS job_count
    FROM job_postings_fact
    GROUP BY company_id
) AS company_jobs;

select * from company_dim

select * from job_postings_fact

select * from skills_dim

/*
Find the count of the number of remote job postings per skill 
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring the skill
*/

with remote_skills as (
    select job_postings.job_id, skill_id, job_postings.job_work_from_home 
    from skills_job_dim AS skill_to_job
    INNER JOIN job_postings_fact as job_postings on job_postings.job_id = skill_to_job.job_id
    where job_work_from_home = 'true'    
)
select remote_skills.skill_id , skills ,count(remote_skills.job_id) as skill_count
from skills_dim
inner join remote_skills on skills_dim.skill_id = remote_skills.skill_id
GROUP BY remote_skills.skill_id, skills
order by skill_count desc
limit 5

/*
Find the count of the number of remote job postings per skill 
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring the skill
*/
with remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim as skills_to_job
    INNER JOIN job_postings_fact as job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = True 
    GROUP BY
        skill_id
)
SELECT
    skills.skill_id,
    skills as skill_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills on skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5

/* UNION operators
Combine result set of two or more SELECT statements into a single result set.
 - UNION : remove duplicate row 
 - UNION ALL : Includes all duplicate rows

! NOTE : Each SELECT statement within the UNION must have the same numbers of columns in
the result sets of with similar data types


UNION - combines results from two or more SELECT statements
- they need to have the same amount of columns, and the data type must match

    SELECT col_name
    FROM table_one

    UNION -- combine the two tables
    
    SELECT col_name
    FROM table_two;

- Gets tid of duplicate rows (unlike UNION ALL)
 -  all rows are required 
*/
  

-- Get jobs and companies from january
SELECT 
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION

-- Get jobs and companies from february
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION -- combine another table

-- Get jobs and companies from march
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs

-- same
(SELECT job_title_short, company_id, job_location
 FROM january_jobs
)

UNION

(SELECT job_title_short, company_id, job_location
 FROM february_jobs
)

UNION

(SELECT job_title_short, company_id, job_location
 FROM march_jobs
);

/*
UNION ALL
- UNION ALL - combine the result of two or more SELECT statements
- they need to have the same amount of columns, and the data type must match

    SELECT col_name
    FROM table_one

    UNION ALL -- combine the tables

    SELCT col_name 
    FROM table_two;

- returns all rows, even duplicates(unlike UNION)
 - Luke Barousse personal note : mostly use this to combine two tables together
*/

-- Get jobs and companies from january
SELECT 
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

-- Get jobs and companies from february
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL -- combine another table

-- Get jobs and companies from march
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs

/* Practice problem 1
question :

- get the corresponding skill and skill type for each job postings in q1
- Includes those without any skills, too
- why? look at the skills and the type for each job in
  the first quarter that has a salary > $70,000
*/

--chat GPT
WITH q1_jobs AS (
    SELECT *
    FROM january_jobs

    UNION ALL

    SELECT *
    FROM february_jobs

    UNION ALL

    SELECT *
    FROM march_jobs
)

SELECT
    q1.job_id,
    q1.job_title,
    q1.salary_year_avg,
    s.skills,
    s.type
FROM q1_jobs AS q1
LEFT JOIN skills_job_dim AS sj
    ON q1.job_id = sj.job_id
LEFT JOIN skills_dim AS s
    ON sj.skill_id = s.skill_id
WHERE q1.salary_year_avg > 70000
ORDER BY q1.salary_year_avg DESC;


--
SELECT
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::DATE

FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000