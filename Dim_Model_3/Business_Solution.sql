-- 1. What is the average call duration and average customer satisfaction score by agent and queue?

select 
    agent_name, 
    queue_name, 
    round(avg(duration_seconds), 2) as avg_duration_seconds, 
    round(avg(customer_satisfaction), 2) as avg_satisfaction 
from dim_model_2.fact_call f
join dim_model_2.dim_agent a
    on f.agent_key = a.agent_key
join dim_model_2.dim_queue q
    on f.queue_key = q.queue_key
group by agent_name, queue_name
order by avg_satisfaction desc, avg_duration_seconds desc;


-- 2. Which agents have First Call Resolution (FCR) and which calls required a callback or escalation?

select 
    agent_name,
    count(*) as total_calls,
    count(*) filter (where first_call_resolution = 'yes') as fcr_calls, 
    count(*) filter (where call_outcome = 'callback') as callback_calls,
    count(*) filter (where call_outcome = 'escalated') as escalated_calls,
    round(count(*) filter (where first_call_resolution = 'yes') * 100.0 / count(*), 2) as fcr_rate
from dim_model_2.fact_call f
join dim_model_2.dim_call_status s
    on f.call_status_key = s.call_status_key
join dim_model_2.dim_agent a
    on f.agent_key = a.agent_key
group by agent_name
order by fcr_rate desc;


-- 3. Is there a pattern between long hold times and low satisfaction scores?

with cte as (
    select 
        case
            when hold_time_seconds >= 120 then 'long_hold'
            else 'short_hold'
        end as hold_type, 
        customer_satisfaction
    from dim_model_2.fact_call
)
select 
    hold_type, 
    round(avg(customer_satisfaction), 2) as avg_satisfaction 
from cte
group by hold_type;


-- 4. Which queues have the longest average wait/hold time and highest abandonment rate?

with cte as (
    select 
        queue_name,
        count(*) as total_calls,
        round(avg(hold_time_seconds), 2) as avg_hold_time,
        sum(case when call_outcome = 'abandoned' then 1 else 0 end) as abandoned_calls
    from dim_model_2.fact_call f
    join dim_model_2.dim_queue q
        on f.queue_key = q.queue_key
    join dim_model_2.dim_call_status c
        on f.call_status_key = c.call_status_key
    group by q.queue_name
)
select 
    queue_name,
    total_calls,
    avg_hold_time,
    abandoned_calls,
    concat(round(abandoned_calls * 100.0 / total_calls, 2), '%') as abandonment_rate 
from cte
order by avg_hold_time desc;


-- 5. Which agents should be flagged for coaching based on their performance?

with cte as (
    select 
        agent_name,
        round(count(*) filter (where first_call_resolution = 'yes') * 100.0 / count(*), 2) as fcr_rate, 
        round(avg(customer_satisfaction), 2) as avg_satisfaction, 
        round(avg(hold_time_seconds), 2) as avg_hold_time 
    from dim_model_2.fact_call f
    join dim_model_2.dim_agent a
        on f.agent_key = a.agent_key
    join dim_model_2.dim_call_status s
        on f.call_status_key = s.call_status_key
    group by agent_name
)
select 
    agent_name,
    fcr_rate,
    avg_satisfaction,
    avg_hold_time,
    case 
        when (fcr_rate < 50 or avg_satisfaction < 3 or avg_hold_time > 150) then 'yes'
        else 'no'
    end as coaching_flag
from cte
order by coaching_flag desc, avg_satisfaction asc;