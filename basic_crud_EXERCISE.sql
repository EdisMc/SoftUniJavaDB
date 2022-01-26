select name from departments
order by department_id;

select first_name, middle_name, last_name
from employees
order by employee_id;

select concat(`first_name`, '.', `last_name`, '@softuni.bg') as full_email_address from employees;

select distinct salary from employees;

select * from employees
where job_title = 'Sales Representative'
order by employee_id;

select first_name, last_name, job_title from employees
where salary between 20000 and 30000
order by employee_id;

select concat(`first_name`, ' ', `middle_name`, ' ', `last_name`) as `Full Name`
from employees
where salary = 25000 or salary = 14000 or salary = 12500 or salary = 23600;

select first_name, last_name
from employees
where manager_id is null;

select first_name, last_name, salary
from employees
where salary > 50000
order by salary desc;

select first_name, last_name
from employees
order by salary desc
limit 5;

select first_name, last_name
from employees
where department_id !=4;

select * from employees
order by salary desc, first_name asc, last_name desc, middle_name asc, employee_id;

create view v_employees_salaries
as select first_name, last_name, salary
from employees;

create view v_employees_job_titles as
select concat_ws(' ', `first_name`,`middle_name`, `last_name`)
as 'Full Name',
job_title from employees;
select * from v_employees_job_titles;

select distinct job_title
from employees
order by job_title asc;


select * from projects
order by start_date, `name`
limit 10;

select first_name, last_name, hire_date
from employees
order by hire_date desc
limit 7;

update employees e
set e.salary = 1.12 * e.salary
where department_id in (1,2,4,11);
select peak_name
from peaks
order by peak_name;

select country_name, population
from countries
where continent_code = 'EU'
order by population desc, country_name asc
limit 30;

SELECT country_name, country_code, 
IF (`currency_code` = 'EUR', 'Euro', 'Not Euro') as `currency` 
FROM countries as c
ORDER BY c.country_name;

select name from characters
order by name asc;
















