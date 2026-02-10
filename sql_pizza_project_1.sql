-- My first beginner SQL project analyzing pizza sales data to find total revenue, popular pizzas, and sales trends. Built for practice and skill improvement in Data Analytics.

CREATE DATABASE pizzahut;
use pizzahut;

select * from orders;
select * from orders_details;
select * from pizza_types;
select * from pizzas;
select database();
use pizzahut;
select * from orders_details;
show tables;
-- Question's 
-- Basic
-- Retrieve the total number of orders placed.

select count(order_id) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.

select
round(sum(orders_details.quantity * pizzas.price),2) as total_sales
from orders_details join pizzas
on pizzas.pizza_id = orders_details.pizza_id;

-- Identify the highest-priced pizza.

select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc
limit 1;

-- Identify the most common pizza size ordered.

select distinct pizzas.size from pizzas ; # just check how many size are there?!
select pizzas.size, count(orders_details.order_details_id) as order_count
from pizzas join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size
order by order_count desc;


-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(orders_details.quantity) as Quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by Quantity desc
limit 5;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
 
 select pizza_types.category, sum(orders_details.quantity) as total_quantity
 from pizza_types join pizzas
 on pizza_types.pizza_type_id = pizzas.pizza_type_id
 join orders_details
 on orders_details.pizza_id = pizzas.pizza_id
 group by pizza_types.category;

-- Determine the distribution of orders by hour of the day.

select hour(order_time) as hour, count(order_id) as order_count 
from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select * from pizza_types;   # just to check table cloumn

select category, count(name) as pizza_distribution
from pizza_types
group by category
order by pizza_distribution;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) as avg_number_of_pizzas_ordered_per_day from
(select orders.order_date as per_day, sum(orders_details.quantity) as quantity
from orders join orders_details
on orders.order_id = orders_details.order_id
group by per_day) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, 
sum(orders_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;	

-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category, 
round(sum(orders_details.quantity * pizzas.price) / (select
	round(sum(orders_details.quantity * pizzas.price),2) as total_sales
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id) * 100,2) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details 
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by revenue desc;


-- Analyze the cumulative revenue generated over time.
select order_date, 
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, 
round(sum(orders_details.quantity * pizzas.price),2) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders	
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales ;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by  pizza_types.category, pizza_types.name ) as a;






