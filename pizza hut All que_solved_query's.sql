create database Pizzahut;
use pizzahut;

/* imported file names:
order_details.
orders.
pizza_types.
pizzas.*/
CREATE TABLE orders (
    Order_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Order_Time TIME NOT NULL,
    PRIMARY KEY (Order_ID)
);
# View data from Table orders 
SELECT 
    *
FROM
    Orders;
 desc Orders;
# View data from Table order_deails 
SELECT 
    *
FROM
    order_Details; 
# View data from Table pizza_types
SELECT 
    *
FROM
    pizza_types;
# View data from Table pizzas 
SELECT 
    *
FROM
    pizzas;
# Retrieve the total number of orders placed.
use pizzahut;

SELECT 
    *
FROM
    orders;
SELECT 
    concat(round(COUNT(order_ID)/1000,2),"K")AS Ttl_Orders
FROM
    pizzahut.orders;
#Calculate the total revenue generated from pizza sales.
use pizzahut;

select * from pizzas;
select * from order_details;

SELECT 
    concat(ROUND(SUM(order_details.quantity * pizzas.price)/1000,
            2),"K") AS Ttl_Revenue
FROM
    order_details
        inner JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
# Identify the highest-priced pizza.
select price from pizzas order by price desc;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

# Identify the most common pizza size ordered. 
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS Ttl_Count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Ttl_Count DESC;

# List the top 5 most ordered pizza types along with their quantities.
/*
select name, order_details_id 
from pizza_types join order_details
on pizza_types.pizza_type_id = order_details.pizza_id;
*/
SELECT 
    pizza_types.name, SUM(order_details.Quantity) AS Ttl_orders
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_Id
        JOIN
    order_Details ON order_Details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Ttl_orders DESC
LIMIT 5;

# Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    count(order_details.quantity) AS Ttl_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

# Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) Count_orders
FROM
    orders
GROUP BY hours
ORDER BY Count_orders DESC;

# Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS Ttl_pizzas
FROM
    pizza_types
GROUP BY category
ORDER BY ttl_Pizzas DESC;

# Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) AS avg_Qua_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS inner_Query;
    
# Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

# Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    concat(round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            SUM(order_details.quantity * pizzas.price) AS Ttl_Sales
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,2),"%") AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category;

# Analyze the cumulative revenue generated over time.
# Cumulative Revenue means previous sales + todays sales
use pizzahut;
# datewise Revenue
SELECT 
    orders.order_date,
    round(SUM(order_details.quantity * pizzas.price),2) AS Total_revenue
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY orders.order_date;

# Cumulative Revenue
select order_date,
sum(total_revenue) over(order by order_date) as Cum_revenue
from
(select orders.order_date,
round(sum(order_details.quantity * pizzas.price),2) as Total_revenue
from orders join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by orders.order_date) as Day_Revenue;

# Determine the top 3 most ordered pizza types based on revenue for each pizza category

# Category, namewise Revenue 
SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , pizza_types.name;

# ranking Revenue
select category,name, Revenue,
rank() over(partition by category order by revenue desc) as RN
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as CTE;

# Top 3 rankwise Revenue for each pizza Category
select Category,name, Revenue 
from
(select category,name, Revenue,
rank() over(partition by category order by revenue desc) as RN
from
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as CTE) as Cte2
where RN <= 3;
 
 
 
