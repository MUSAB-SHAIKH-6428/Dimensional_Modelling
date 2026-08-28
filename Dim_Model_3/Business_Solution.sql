
--What is the average call duration and average customer satisfaction score by agent and queue?
select agent_name, queue_name, round(avg(duration_seconds),2) as avg_duration_seconds , round(avg(customer_satisfaction),2) as avg_satisfaction from fact_call f
join dim_agent a
on f.agent_key = a.agent_key
join dim_model_2.dim_queue q
on f.queue_key = q.queue_key
group by agent_name, queue_name
order by avg_satisfaction desc, avg_duration_seconds desc;

--Which agents have First Call Resolution (FCR) and which calls required a callback or escalation?

select 
agent_name,
COUNT(*) as total_calls,
COUNT(*) FILTER (WHERE first_call_resolution = 'yes') as fcr_calls, 
COUNT(*) FILTER (WHERE call_outcome = 'callback') as callback_calls,
COUNT(*) FILTER (WHERE call_outcome = 'escalated') as escalated_calls,
COUNT(*) FILTER (WHERE first_call_resolution = 'yes')
* 100.0 / COUNT(*) as fcr_rate
from fact_call f
join dim_model_2.dim_call_status s
on f.call_status_key = s.call_status_key
join dim_agent a
on f.agent_key = a.agent_key
group by agent_name;

--Is there a pattern between long hold times and low satisfaction scores?
with cte as(
select 
case
	when hold_time_seconds >= 120 then 'LONG_HOLD'
	else 'SHORT_HOLD'
end as hold_type, 
customer_satisfaction
from fact_call)
select hold_type, round(avg(customer_satisfaction),2) from cte
group by hold_type;

--Which queues have the longest average wait/hold time and highest abandonment rate?

with cte as(
select queue_name,
count(*) as total_calls,
round(avg(hold_time_seconds),2) as avg_hold_time,
sum(case when call_outcome = 'abandoned' THEN 1 else 0 end) as abandoned_calls
from fact_call f
join dim_model_2.dim_queue q
on f.queue_key = q.queue_key
join DIM_CALL_STATUS c
on f.call_status_key = c.call_status_key
group by q.queue_name)
select *, concat(round(abandoned_calls * 100.0 /total_calls, 2), '%') as abandonment_rate from cte
order by avg_hold_time desc

--Which agents should be flagged for coaching based on their performance?
with cte as
(select agent_name,
COUNT(*) FILTER (WHERE first_call_resolution = 'yes')
* 100.0 / COUNT(*) as fcr_rate, 
round(avg(customer_satisfaction),2) as avg_satisfaction, 
round(avg(hold_time_seconds),2)as avg_hold_time from fact_call f
join dim_model_2.dim_agent a
on f.agent_key = a.agent_key
join dim_call_status s
on f.call_status_key = s.call_status_key
group by agent_name)
select *, case when
	(fcr_rate < 50 
	OR
	avg_satisfaction < 3
	OR
	avg_hold_time > 150) then 'YES'
	else 'NO'
end as coaching_flag
from cte