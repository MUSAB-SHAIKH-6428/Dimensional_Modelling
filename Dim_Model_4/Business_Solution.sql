set search_path to loyalty_model;

-- 1. What is the total points balance across all members at each month-end?
--    Note: Points balance is semi-additive (valid to aggregate across members for a snapshot date, but NOT across time).

select 
d.year, 
d.month_name, 
sum(b.points_balance) as total_points_balance 
from loyalty_model.fact_point_balance_monthly b
join loyalty_model.dim_date d
on b.date_key = d.date_key
group by d.year, d.month, d.month_name
order by d.year, d.month;


-- 2. For each month, calculate total points earned, total points redeemed, and total points expired.
--    Note: Monthly earned, redeemed, and expired point metrics are fully additive across dimensions and time.

select 
d.month_name, 
sum(b.points_earned_month) as points_earned,
sum(b.points_redeemed_month) as points_redeemed,
sum(b.points_expired_month) as points_expired 
from loyalty_model.fact_point_balance_monthly b
join loyalty_model.dim_date d
on b.date_key = d.date_key
group by d.month, d.month_name
order by d.month;


-- 3. Which campaigns generated the most points earned and transaction activity?
--    Evaluates promotional campaign attribution, engagement volume, and spend generated.

select 
c.campaign_name,
c.campaign_type,
count(*) as total_transactions,
sum(e.points_earned) as total_points_earned, 
sum(e.transaction_amount) as total_transaction_amount 
from loyalty_model.fact_point_earning e
join loyalty_model.dim_campaign c
on e.campaign_key = c.campaign_key
group by c.campaign_name, c.campaign_type
order by total_transactions desc;


-- 4. Compare member spending and points earned by tier.
--    Evaluates how tier progression (e.g. Silver -> Gold -> Platinum) impacts member transaction behavior.

select 
t.tier_name, 
count(distinct m.member_id) as total_members,
sum(p.transaction_amount) as total_spending,
sum(p.points_earned) as total_points_earned
from loyalty_model.fact_point_earning p
join loyalty_model.dim_tier t
on p.tier_key = t.tier_key
join loyalty_model.dim_member m
on p.member_key = m.member_key
group by t.tier_name
order by total_spending desc;


-- 5. Calculate the total spending and total points earned for each member, along with their current segment and current tier.
--    Analyzes member lifetime value (LTV) using SCD Type 2 current record filtering (is_current = true).

select 
m.member_name,
m.segment,
t.tier_name,
sum(p.transaction_amount) as lifetime_spending,
sum(p.points_earned) as lifetime_points_earned
from loyalty_model.fact_point_earning p
join loyalty_model.dim_member m
on p.member_key = m.member_key
join loyalty_model.dim_tier t
on p.tier_key = t.tier_key
where m.is_current = true
group by m.member_name, m.segment, t.tier_name
order by lifetime_points_earned desc;

-- NOTE
-- SCD handling was the problem. Q5 needs a rewrite