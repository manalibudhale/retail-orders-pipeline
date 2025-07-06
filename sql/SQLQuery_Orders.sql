select * from df_orders;

-- List the top 10 products generating the highest revenue
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc

-- Identify the 5 highest-selling products for every region
with cte as (
select region, product_id, sum(sale_price) as sales
from df_orders
group by region,product_id)
select * from (
select * 
, ROW_NUMBER() over(partition by region order by sales desc) as rn
from cte) A
where rn<=5

-- Calculate the month-over-month sales growth for 2022 and 2023
with cte as(
select year(order_date) as order_year, MONTH(order_date) as order_month, 
SUM(sale_price) as sales
from df_orders
group by year(order_date), month(order_date)
--order by order_year, order_month
)
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

-- find which month has highest sale for each category 

with cte as (
select category, format(order_date,'yyyyMM') as order_year_month, 
sum(sale_price) as sales 
from df_orders
group by category, FORMAT(order_date, 'yyyyMM')
--order by category, FORMAT(order_date, 'yyyyMM')
)
select * from(
select *,
ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte) a
where rn=1

-- Which sub-category experienced the highest profit growth in 2023 compared to 2022

with cte as(
select sub_category, year(order_date) as order_year,
SUM(sale_price) as sales
from df_orders
group by sub_category, year(order_date)
--order by order_year, order_month
)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)*100/sales_2022
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc

