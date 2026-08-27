--1. How much revenue did we make by product category this month?

select category ,sum(revenue) as revenue from fact_order_item f
join dim_product p
on f.product_key = p.product_key
join dim_date d
on f.date_key = d.date_key
where month  = 12 and year = 2025
group by category


--2. Which customers are our most valuable, and how did we acquire them?

select customer_name,
acquisition_channel,
sum(revenue) as total_revenue 
from fact_order_item f
join dim_customer c
on f.customer_key = c.customer_key
group by customer_name, acquisition_channel
order by total_revenue desc

--3. What products sell best during holidays vs regular days?

select product_name, 
case
	when is_holiday = true then 'HOLIDAY'
	else 'REGULAR'
end
as day_type, 
sum(quantity) as total_quantity 
from fact_order_item f
join dim_product p
on f.product_key = p.product_key
join dim_date d
on f.date_key = d.date_key
group by product_name, d.is_holiday
order by total_quantity desc


--4. How does average order size vary by country?
--   Assumption: "order size" = gross order value (SUM(quantity × unit_price)).

with cte as(
select order_id,sum(quantity * unit_price) as orders_total, country from fact_order_item f
join dim_customer c
on f.customer_key = c.customer_key
group by order_id, country)
select country, avg(orders_total) as avg_order_size from cte
group by country
order by avg_order_size

--5. Which products do repeat customers buy vs first-time buyers?
--Assumption: A customer's first order is FIRST_TIME; every subsequent order is REPEAT.


WITH first_purchase AS (
    SELECT
        customer_key,
        MIN(date) AS first_order_date
    FROM fact_order_item f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY customer_key
),
order_level AS (
    SELECT
        f.order_id,
        f.customer_key,
        p.product_name,
        d.date,
        f.quantity,
        fp.first_order_date,
        CASE
            WHEN d.date = fp.first_order_date THEN 'FIRST_TIME'
            ELSE 'REPEAT'
        END AS buyer_type
    FROM fact_order_item f
    JOIN dim_product p
        ON f.product_key = p.product_key
    JOIN dim_date d
        ON f.date_key = d.date_key
    JOIN first_purchase fp
        ON f.customer_key = fp.customer_key
)
SELECT
    product_name,
    buyer_type,
    SUM(quantity) AS quantity_sold
FROM order_level
GROUP BY product_name, buyer_type
ORDER BY product_name, buyer_type;