/*
Question: what are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst. 
- focus on all job postings. 
- why? retrieves insights into the most valuable skills for job seekers. 
*/ 
SELECT skills, count(skills_job_dim.job_id) as skills_count
from job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where job_title_short = 'Data Analyst'
GROUP BY
skills
ORDER BY skills_count DESC
limit 5
