SELECT * FROM retail_orders.orders;
/*Q1.Find top 10 highest revenue generating products*/
select product_id, sum(sale_price) as revenue
from orders
group by product_id
order by revenue desc limit 10;

/*Q2.Find top 5 highest selling products in each region*/
with cte as(
select region, product_id, sum(sale_price) as revenue
from orders
group by region, product_id
)
select * from(
select *
, row_number() over(partition by region order by revenue desc) as rn
from cte) A
where rn<=5;

/*Q3.Find month over month growth comparison for 2022 and 2023 sales eg:jan 2022 vs jan 2023*/
select distinct year(order_date) from orders;
with cte as(
select year(order_date) as order_year, month(order_date) as order_month,
sum(sale_price) as sales
from orders
group by year(order_date),month(order_date)
)
select order_month,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by order_month
order by order_month

/*Q4. For each category which month had highest sales*/
with cte as(
select category,format(order_date,'yyyyMM') as order_year_month,
sum(sale_price) as sales
from orders
group by category,format(order_date,'yyyyMM')
/*order by category,format(order_date,'yyyyMM')*/
)
select * from(
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1;

/*Q5. Which sub category had highest growth by profit in 2023 comapre to 2022*/
with cte as(
select sub_category, year(order_date) as order_year,
sum(sale_price) as sales
from orders
group by sub_category,year(order_date)
)
, cte2 as (select sub_category,
sum(case when order_year=2022 then sales else 0 end) as sales_2022,
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/sales_2022
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc limit 1