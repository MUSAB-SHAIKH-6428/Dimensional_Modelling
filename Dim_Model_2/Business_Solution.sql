--What is the attendance rate by department?

select department_name, round((count(is_present)Filter(where is_present = TRUE) *100.0)/sum(attendance_count), 2) as attendance_rate 
from dim_model_1.fact_attendance_per_day f
join dim_department d
on f.department_key = d.department_key
group by department_name
order by attendance_rate desc;

--How many PTO days has each employee used, and how many PTO days do they have available?

select 
employee_name,
pto_days_used,
pto_days_available
from dim_model_1.fact_pto_balance f
join dim_model_1.dim_employee e
on f.employee_key = e.employee_key 
order by pto_days_used desc;

--Which employees have frequent absences?

select employee_name, round((count(is_present)Filter(where is_present = False) *100.0)/sum(attendance_count), 2) as absence_rate 
from dim_model_1.fact_attendance_per_day f
join dim_model_1.dim_employee e
on f.employee_key = e.employee_key
group by e.employee_name 
order by absence_rate desc;

--Do attendance patterns differ by office location?

select location, round((count(is_present)Filter(where is_present = TRUE) *100.0)/sum(attendance_count), 2) as attendance_rate 
from dim_model_1.fact_attendance_per_day f
join dim_department d
on f.department_key = d.department_key
group by location
order by attendance_rate desc;

--How does attendance change over the year?

select year, month_name, round((count(is_present)Filter(where is_present = TRUE) *100.0)/sum(attendance_count), 2) as attendance_rate 
from dim_model_1.fact_attendance_per_day f
join dim_date d
on f.date_key = d.date_key
group by year, month_name, month
ORDER BY year, month;

