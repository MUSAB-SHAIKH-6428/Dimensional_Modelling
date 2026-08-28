-- 1. What is the attendance rate by department?

select 
    department_name, 
    round((count(is_present) filter (where is_present = true) * 100.0) / sum(attendance_count), 2) as attendance_rate 
from dim_model_1.fact_attendance_per_day f
join dim_model_1.dim_department d
    on f.department_key = d.department_key
group by department_name
order by attendance_rate desc;


-- 2. How many PTO days has each employee used, and how many PTO days do they have available?

select 
    employee_name,
    pto_days_used,
    pto_days_available
from dim_model_1.fact_pto_balance f
join dim_model_1.dim_employee e
    on f.employee_key = e.employee_key 
order by pto_days_used desc;


-- 3. Which employees have frequent absences?

select 
    employee_name, 
    round((count(is_present) filter (where is_present = false) * 100.0) / sum(attendance_count), 2) as absence_rate 
from dim_model_1.fact_attendance_per_day f
join dim_model_1.dim_employee e
    on f.employee_key = e.employee_key
group by e.employee_name 
order by absence_rate desc;


-- 4. Do attendance patterns differ by office location?

select 
    location, 
    round((count(is_present) filter (where is_present = true) * 100.0) / sum(attendance_count), 2) as attendance_rate 
from dim_model_1.fact_attendance_per_day f
join dim_model_1.dim_department d
    on f.department_key = d.department_key
group by location
order by attendance_rate desc;


-- 5. How does attendance change over the year?

select 
    year, 
    month_name, 
    round((count(is_present) filter (where is_present = true) * 100.0) / sum(attendance_count), 2) as attendance_rate 
from dim_model_1.fact_attendance_per_day f
join dim_model_1.dim_date d
    on f.date_key = d.date_key
group by year, month_name, month
order by year, month;
