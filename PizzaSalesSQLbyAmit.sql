
#Pizza - Sales- Analysis -- Mentorness Internship
Amit Sharma   Date -- 17/07/2024 


USE Pizza_sales

select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients


-- #Reference File for Pizza Sales Analysis

-- Q1: The total number of order place

select count(distinct order_id) as 'Total Orders' from orders;

-- Q2: The total revenue generated from pizza sales

select order_details.pizza_id, order_details.quantity, pizzas.price
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id

select cast(sum(order_details.quantity * pizzas.price) as decimal(10,2)) as 'Total Revenue'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id

-- Q3: The highest priced pizza.

select top 1 pizza_types.name as 'Pizza Name', cast(pizzas.price as decimal(10,2)) as 'Price'
from pizzas 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc

-- Q4: The most common pizza size ordered.

with cte as (
select pizza_types.name as 'Pizza Name', cast(pizzas.price as decimal(10,2)) as 'Price',
rank() over (order by price desc) as rnk
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
)
select [Pizza Name], 'Price' from cte where rnk = 1 

-- Q5: The top 5 most ordered pizza types along their quantities.     pizzas p

select top 5 pizza_types.name as 'Pizza', sum(quantity) as 'Total Ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name 
order by sum(quantity) desc

select top 5 pizza_types.category, sum(quantity) as 'Total Quantity Ordered'
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category 
order by sum(quantity)  desc


-- Q6: The quantity of each pizza categories ordered.

SELECT category, SUM(quantity) AS total_quantity
FROM order_details
JOIN pizza ON pizza_id = pizza_id
JOIN pizza_type ON pizza_type_id = pizza_type_id
GROUP BY category;


-- Q7: The distribution of orders by hours of the day.

select datepart(hour, time) as 'Hour of the day', count(distinct order_id) as 'No of Orders'
from orders
group by datepart(hour, time) 
order by [No of Orders] desc

-- Q8: The category-wise distribution of pizzas.

select category, count(distinct pizza_type_id) as [No of pizzas]
from pizza_types
group by category
order by [No of pizzas]


-- Q9: The average number of pizzas ordered per day.	

select avg([Total Pizza Ordered that day]) as [Avg Number of pizzas ordered per day] from 
(
	select orders.date as 'Date', sum(order_details.quantity) as 'Total Pizza Ordered that day'
	from order_details
	join orders on order_details.order_id = orders.order_id
	group by orders.date
) as pizzas_ordered

-- Q10: Top 3 most ordered pizza type base on revenue.

select top 3 pizza_types.name, sum(order_details.quantity*pizzas.price) as 'Revenue from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue from pizza] desc

-- Q11: The percentage contribution of each pizza type to revenue.	

select pizza_types.category, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category


-- Q12: The cumulative revenue generated over time.

with cte as (
select date as 'Date', cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
-- order by [Revenue] desc
)
select Date, Revenue, sum(Revenue) over (order by date) as 'Cumulative Sum'
from cte 
group by date, Revenue


-- Q13: The top 3 most ordered pizza type based on revenue for each pizza category.

with cte as (
select category, name, cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name
-- order by category, name, Revenue desc
)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue