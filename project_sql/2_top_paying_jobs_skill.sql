/*
Question: what skills are required fot the top-paying data analyst jobs?
- use the top 10 highest-paying data analyst jobs from first query
- add the specific skills required for these roles 
- why? it provides a detailed look at which skills to develop that align with top salaries
*/ 
with top_paying_jobs AS ( 
    SELECT	
        job_id,
        job_title,
        salary_year_avg,
        name As company_name
    FROM
        job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' AND 
        job_location = 'Anywhere' AND 
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
)
select 
    top_paying_jobs.*,
    skills
from top_paying_jobs
INNER JOIN skills_job_dim on top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
order by salary_year_avg desc



