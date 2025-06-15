-- select * from customers;
-- select * from deliveries;
-- select * from orders;
-- select * from restaurants;
-- select * from riders;

# Q1.Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.

-- with cte as (
-- 	SELECT c.customer_id,c.customer_name,o.order_item,
-- 	count(*) as most_orders_cnt,
-- 	dense_rank() over(order by count(*) desc) as rnk 
-- 	FROM customers c
-- 	left join orders o
-- 	using(customer_id)
-- 	where c.customer_name like "%Arjun Mehta%" and o.order_date >= date_add('2024-01-25',interval -1 year)
-- 	group by 1,2,3
--             )
-- select * from cte where rnk <= 5

# Q2.Identify the time slots during which the most orders are placed, based on 2-hour intervals.

-- select 
-- concat_ws("-",from_hour,To_hour) as time_slot ,
-- count(order_id) as order_cnt
-- from (
--  SELECT  order_id,
--  case when order_date then floor(hour(order_time)/2)*2 end as from_hour,
--  case when order_date then floor(hour(order_time)/2)*2 + 2 end as To_hour
--  FROM orders
-- ) x
-- group by concat_ws("-",from_hour,To_hour)
-- order by order_cnt  desc

# Q3: Find the average order value (AOV) per customer who has placed more than 750 orders. Return: customer_name, aov (average order value).in DESC of AOV

-- select customer_name, round(avg(o.total_amount),2) as AOV
-- from customers c join orders o
-- using(customer_id)
-- group by customer_name
-- having count(*) > 750
-- order by AOV desc

# Q4: List the customers who have spent more than 100K in total on food orders.

-- select customer_id, customer_name, sum(o.total_amount) as total_spend
-- from customers join orders o using (customer_id)
-- group by customer_id, customer_name
-- having total_spend > 100000
-- order by total_spend desc

# Q5: Write a query to find orders that were placed but not delivered. Return: restaurant_name, city, and the number of not delivered orders.

-- select r.restaurant_name, r.city , count(order_id) as not_delivered
-- from orders as o
-- left join deliveries d
-- using (order_id)
-- left join restaurants r 
-- using (restaurant_id)
-- where order_id is not null and delivery_id is null 
-- group by r.restaurant_name, r.city
-- order by not_delivered desc

# Q6: Rank restaurants by their total revenue from the last year. Return: restaurant_name, city,total_revenue, and their rank within their city.

-- SELECT r.restaurant_name,r.city,sum(total_amount) as total_Revenue,
-- dense_rank() over(partition by r.city order by sum(total_amount) desc) as Res_rnk 
-- FROM orders as o
-- left join restaurants as r
-- using(restaurant_id)
-- where year(order_Date) = year(curdate()) - 1
-- group by r.restaurant_name,r.city
-- order by city,Res_rnk

# Q7: Identify the most popular dish in each city based on the number of orders. Return : city,most popular dish,total order, rnk

-- with cte as 
-- (
-- 	SELECT r.city,o.order_item as most_popular_dish,
-- 	count(order_id) as total_orders, 
-- 	dense_Rank()over(partition by r.city order by count(order_id) desc) rnk
-- 	FROM orders as o
-- 	left join restaurants as r
-- 	using(restaurant_id)
-- 	group by r.city,o.order_item
-- 	order by r.city,rnk
-- )
-- select * from cte where rnk = 1

# Q8: Find customers who haven’t placed an order in 2024 but did in 2023.

-- with cte as (SELECT c.customer_id,c.customer_name,o.order_id,year(o.order_date) as yr FROM customers as c
-- join orders as o
-- using(customer_id)
-- )
-- select distinct customer_name as "2023",customer_id from cte
-- where yr = 2023
-- and customer_id not in (select customer_id from cte where yr = 2024)
-- order by customer_id

#Q9: Calculate and compare (restaurant are in both year) the order cancellation(not delivered)rate for each restaurant between the current year and the previous year.

# restaurents order cnt and cancelled cnt in 2023
-- with cte1 as(
-- select o.restaurant_id, count(*) as total_orders_2023,
-- count(case when d.delivery_id is null then 1 else null end) as "Not_Delivered_2023"
-- from orders o left join deliveries d 
-- using (order_id)
-- where year(o.order_date)= 2023
-- group by o.restaurant_id
-- ),

-- # restaurents order cnt and cancelled cnt in 2024
-- cte2 as(
-- select o.restaurant_id, count(*) as total_orders_2024,
-- count(case when d.delivery_id is null then 1 else null end)as "Not_Delivered_2024"
-- from orders o left join deliveries as d
-- using (order_id)
-- where year(order_date)=2024
-- group by o.restaurant_id
-- )

-- # compamparision from 2023 vs 2024
-- select cte1.restaurant_id,
-- round((not_Delivered_2023/total_orders_2023)*100,2) as "2023_cancellation_Date",
-- round((not_Delivered_2024/total_orders_2024)*100,2) as "2024_cancellation_Date" 
-- from cte1 join cte2
-- using(restaurant_id)
-- order by cte1.restaurant_id

#Q10: Determine each rider's average delivery time.

-- SELECT 
--     r.rider_id,
--     r.rider_name,
--     ROUND(AVG(TIME_TO_SEC(d.delivery_time) / 60), 2) AS avg_delivery_time_mins
-- FROM deliveries d
-- JOIN riders r ON d.rider_id = r.rider_id
-- WHERE d.delivery_status = 'Delivered'
-- GROUP BY r.rider_id, r.rider_name
-- ORDER BY avg_delivery_time_mins ASC;

#Q11: Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining.

-- with cte as 
-- (
-- SELECT r.restaurant_name,o.restaurant_id,
-- month(o.order_Date) as mnt,year(o.order_date) as yr,count(order_id) as order_cnt
-- FROM orders as o
-- join restaurants as r
-- using(restaurant_id)
-- join deliveries
-- using(order_id)
-- where delivery_status  = "Delivered"
-- group by r.restaurant_name, o.restaurant_id, mnt, yr
-- order by restaurant_name,yr,mnt
-- ),
-- cte1 as (
-- select *,
-- lag(order_cnt) over(partition by restaurant_name order by yr)as prv_month_Value
-- from cte
-- )
-- select *,
-- round((((order_cnt-prv_month_Value)/prv_month_Value)*100),2) as Growth_Rate
-- from cte1
-- order by restaurant_id 

#Q12: Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the average order value (AOV). 
#	  If a customer's total spending exceeds the AOV, label them as 'Gold'; otherwise, label them as 'Silver'.

-- with cte as(
-- select  c.customer_id, c.customer_name, sum(o.total_amount) as total_spend, count(o.order_id) as total_orders
-- from customers c left join orders o 
-- using (customer_id)
-- group by c.customer_id, c.customer_name
-- ),
-- cte1 as(
-- select *, case when total_spend > (select avg(total_orders) as aov from cte) then 'Gold' 
-- 			   else 'Silver'
-- 		  end as Segment from cte
-- )

-- select segment, sum(total_spend) as total_revenue , sum(total_orders) as number_of_orders
-- from cte1
-- group by segment


# Q13 Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

-- select r.rider_id as rider_id, r.rider_name as rider_name, year(o.order_date) as yr, month(o.order_date) as mnt, 
-- sum(o.total_amount) as total_revenue, round(sum(total_amount*0.08),2) as monthly_earning
-- from riders as r left join deliveries d 
-- using(rider_id) 
-- left join orders o 
-- using (order_id)
-- group by rider_id, rider_name, yr, mnt
-- order by rider_id, rider_name, yr, mnt

#Q14 Find the number of 5-star, 4-star, and 3-star ratings each rider has. Riders receive ratings based on delivery time: ● 5-star: Delivered in less than 15 minutes ● 4-star: Delivered between 15 and 20 minutes ● 3-star: Delivered after 20 minutes

-- # Step 1: Get relevant records
-- WITH cte AS (
--     SELECT 
--         r.rider_id,
--         d.order_id,
--         o.order_time,
--         d.delivery_time
--     FROM riders r
--     LEFT JOIN deliveries d ON r.rider_id = d.rider_id
--     JOIN orders o ON d.order_id = o.order_id
--     WHERE d.delivery_status = 'Delivered'
-- ),

-- # Step 2: Convert order and delivery times into seconds
-- cte1 as
-- (
-- select rider_id, order_id, time_to_sec(order_time) as order_time_sec,
-- case when time_to_sec(delivery_time) < TIME_TO_SEC(order_time) then time_to_sec(delivery_time) + 86400 else time_to_sec(delivery_time) end as delivery_time_sec
-- from cte
-- ),

-- # Step 3: Calculate delivery duration in minutes
-- cte2 as (
-- select *, Round((delivery_time_sec-order_time_sec)/60,2) as delivery_duration
-- from cte1
-- )

-- # Step 4: Classify ratings and count per rider

-- select rider_id, 
--     COUNT(CASE WHEN ratings = '5-star' THEN 1 END) AS `5-star_rating`,
--     COUNT(CASE WHEN ratings = '4-star' THEN 1 END) AS `4-star_rating`,
--     COUNT(CASE WHEN ratings = '3-star' THEN 1 END) AS `3-star_rating` from
-- (select *,
-- case when delivery_duration < 15 then '5-star' 
--      when delivery_duration between 15 and 20 then '4-star'
--      else '3-star'
-- end as ratings     
-- from cte2) x
-- group by rider_id
-- order by rider_id;

# Q15 Analyze order frequency per day of the week and identify the peak day for each restaurant.

-- with cte as(
-- select r.restaurant_name, count(o.order_id) as order_frequency , dayname(order_date) as "Week_day"
-- from orders o join restaurants r 
-- using(restaurant_id)
-- group by r.restaurant_name, week_day
-- ),
-- cte1 as(
-- select *,
-- dense_rank() over(partition by restaurant_name order by order_frequency desc) as Ranking
-- from cte
-- )

-- select * from cte1 
-- where ranking =1

#Q16: Calculate the total revenue generated by each customer over all their orders.

-- select customer_id, round(sum(total_amount),0) as total_revenue
-- from orders
-- group by customer_id

#Q17: Identify sales trends by comparing each month's total sales to the previous month.

-- with cte as
-- (select 
-- year(order_date) as yr, 
-- monthname(order_date) as month_name,
-- month(order_date) as mnth,
-- sum(total_amount) as total_sales
-- from orders
-- group by yr,month_name, mnth
-- order by yr,month_name, mnth)

-- select *,
-- lag(total_sales,1,0) over() as prev_month_sales,
-- ifnull(round((
-- (total_Sales -lag(total_sales,1,0) over()) / lag(total_sales,1,0) over())*100,2),0)
-- as growth
-- from cte

#Q18 Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages(0nly top 2 and bottom 2)

-- # Step 1: Get relevant delivered orders
-- WITH cte AS (
--     SELECT 
--         r.rider_id,
--         d.order_id,
--         o.order_time,
--         d.delivery_time
--     FROM riders r
--     LEFT JOIN deliveries d ON r.rider_id = d.rider_id
--     JOIN orders o ON d.order_id = o.order_id
--     WHERE d.delivery_status = 'Delivered'
-- ),

-- # Step 2: Convert times into seconds
-- cte1 AS (
--     SELECT 
--         rider_id,
--         order_id,
--         TIME_TO_SEC(order_time) AS order_time_in_seconds,
--         CASE 
--             WHEN TIME_TO_SEC(delivery_time) < TIME_TO_SEC(order_time) 
--                 THEN TIME_TO_SEC(delivery_time) + 86400
--             ELSE TIME_TO_SEC(delivery_time)
--         END AS delivery_time_in_seconds
--     FROM cte
-- ),

-- # Step 3: Calculate delivery duration in minutes
-- cte2 AS (
--     SELECT *,
--            ROUND((delivery_time_in_seconds - order_time_in_seconds) / 60, 2) AS duration_delivery_time
--     FROM cte1
-- ),

-- # Step 4: Get Top 2 riders with highest average delivery time
-- cte3 AS (
--     SELECT 
--         rider_id,
--         ROUND(AVG(duration_delivery_time), 2) AS avg_efficiency_time,
--         'top_2' AS avg_eff
--     FROM cte2
--     GROUP BY rider_id
--     ORDER BY avg_efficiency_time DESC
--     LIMIT 2
-- ),

-- # Step 5: Get Bottom 2 riders with lowest average delivery time
-- cte4 AS (
--     SELECT 
--         rider_id,
--         ROUND(AVG(duration_delivery_time), 2) AS avg_efficiency_time,
--         'bottom_2' AS avg_eff
--     FROM cte2
--     GROUP BY rider_id
--     ORDER BY avg_efficiency_time ASC
--     LIMIT 2
-- )

-- # Final result: Union of Top 2 and Bottom 2 riders
-- SELECT * FROM cte3
-- UNION
-- SELECT * FROM cte4;


#Q19: Track the popularity of specific order items over time and identify seasonal demand spikes.

-- select order_item,
-- count(case when month(order_date) in (12,1,2) then 1 else null end) as "Winter",
-- count(case when month(order_date) in (3,4,5) then 1 else null end) as "Spring",
-- count(case when month(order_date) in (6,7,8) then 1 else null end) as "Summer",
-- count(case when month(order_date) in (9,10,11) then 1 else null end) as "Autumn"
-- from orders
-- group by order_item
-- order by Winter desc, Spring desc, Summer desc, Autumn desc


#Q20: Rank each city based on the total revenue for the last year (2023).

-- select city, sum(total_amount) as total_revenue,
-- rank() over(order by sum(total_amount) desc) as rnk
-- from restaurants r left join orders o 
-- using(restaurant_id)
-- where year(order_date)=2023
-- group by city


#Q21: Calculate the average delivery time per restaurant and rank them based on fastest average delivery.

-- with cte as
-- (select o.restaurant_id, time_to_sec(d.delivery_time)/60 as delivery_mins
-- from deliveries d 
-- JOIN Orders o using(order_id)
-- where delivery_status="Delivered" )

-- select 
-- r.restaurant_name,
-- ROUND(AVG(c.delivery_mins), 2) AS avg_delivery_time_mins,
-- RANK() OVER (ORDER BY AVG(c.delivery_mins)) AS speed_rank
-- from cte c
-- JOIN restaurants r ON r.restaurant_id = c.restaurant_id
-- GROUP BY r.restaurant_name;

#Q22: Identify the top 3 customers with the highest number of orders in each city.

-- with cte as
-- (select c.customer_id, c.customer_name, r.city, count(o.order_id) as Total_Orders
-- from customers c 
-- JOIN orders o 
-- using(customer_id)
-- JOIN restaurants r
-- using(restaurant_id)
-- group by c.customer_id, c.customer_name, r.city)

-- select * from 
-- (select *, 
-- dense_rank() over(partition by city order by total_orders desc) as city_rnk
-- from cte) ranked
-- where city_rnk <=3;

#Q23: Find the reorder rate for each customer (how many times they ordered the same dish again).

-- with cte as(
-- select c.customer_id, o.order_item, count(*) as order_count
-- from customers c 
-- join orders o 
-- using(customer_id)
-- group by c.customer_id, o.order_item
-- ),

-- cte1 as (
-- SELECT customer_id, COUNT(*) AS repeated_items
-- FROM cte
-- WHERE order_count > 1
-- GROUP BY customer_id
-- ),

-- cte2 as(
-- SELECT customer_id, COUNT(*) AS total_items
-- FROM cte1
-- GROUP BY customer_id
-- )

-- SELECT 
--     c.customer_name,
--     COALESCE(r.repeated_items, 0) / cte2.total_items AS reorder_rate
-- FROM cte2
-- JOIN customers c ON c.customer_id = cte2.customer_id
-- LEFT JOIN cte1 r ON r.customer_id = cte2.customer_id;

#Q24: Identify order patterns by comparing the number of weekend vs weekday orders per customer.

-- SELECT 
-- c.customer_name,
-- SUM(CASE WHEN WEEKDAY(order_date) <= 5 THEN 1 ELSE 0 END) AS weekday_orders,
-- SUM(CASE WHEN WEEKDAY(order_date) > 5 THEN 1 ELSE 0 END) AS weekend_orders,
-- ROUND(SUM(CASE WHEN WEEKDAY(order_date) > 5 THEN 1 ELSE 0 END) /
--           NULLIF(SUM(CASE WHEN WEEKDAY(order_date) <= 5 THEN 1 ELSE 0 END), 0), 2) AS ratio
-- FROM orders o
-- JOIN customers c ON o.customer_id = c.customer_id
-- GROUP BY c.customer_name;

#Q25: Find restaurants that experienced a 20% or more drop in revenue in the last 3 months compared to the 3 months before that.


#Q26: Calculate the 7-day moving average of daily order volume platform-wide.

-- select order_date, count(*) as total_orders,
-- round(avg(count(*)) over(order by order_date rows between 6 preceding and current row),2) as moving_avg_7_days
-- from orders
-- group by order_date
-- order by order_date;

#Q27: Determine which riders deliver orders the fastest on average during peak hours (e.g., 6 PM to 10 PM).

-- select 
-- r.rider_name,
-- ROUND(AVG(TIME_TO_SEC(d.delivery_time) / 60), 2) AS avg_delivery_time
-- from deliveries d
-- JOIN orders o ON o.order_id = d.order_id
-- JOIN riders r ON r.rider_id = d.rider_id
-- where HOUR(order_time) BETWEEN 18 AND 22 AND d.delivery_status = 'Delivered'
-- group by  r.rider_name
-- order by avg_delivery_time ASC
-- LIMIT 5;

#Q28: For each restaurant, find the percentage of total revenue that comes from its top 3 dishes.

-- with dish_revenue as(
-- select  restaurant_id, order_item, sum(total_amount) as item_revenue 
-- from orders
-- group by restaurant_id, order_item
-- ),

-- top_dishes as (
-- select *, 
-- rank() over(partition by restaurant_id order by item_revenue) as rnk
-- from dish_revenue
-- ),

-- top3_revenue as(
-- select restaurant_id, sum(item_revenue) as top3_total 
-- from top_dishes 
-- where rnk<=3 
-- group by restaurant_id
-- ),

-- total_revenue as (
-- select restaurant_id, sum(total_amount) as overall_total from orders 
-- group by restaurant_id
-- )

-- SELECT 
-- r.restaurant_name,
-- ROUND((t3.top3_total / tr.overall_total) * 100, 2) AS top3_revenue_percent
-- FROM top3_revenue t3
-- JOIN total_revenue tr ON t3.restaurant_id = tr.restaurant_id
-- JOIN restaurants r ON r.restaurant_id = tr.restaurant_id;

#Q29: Find the top 5 cities with the fastest average delivery times across all restaurants.

-- WITH delivery_times AS (
--     SELECT 
--         r.city,
--         TIME_TO_SEC(d.delivery_time) / 60 AS delivery_mins
--     FROM deliveries d
--     JOIN orders o ON d.order_id = o.order_id
--     JOIN restaurants r ON o.restaurant_id = r.restaurant_id
--     WHERE d.delivery_status = 'Delivered'
-- )
-- SELECT 
--     city,
--     ROUND(AVG(delivery_mins), 2) AS avg_delivery_time
-- FROM delivery_times
-- GROUP BY city
-- ORDER BY avg_delivery_time ASC
-- Limit 2;

#Q30: Identify restaurants with the highest delivery failure rate (undelivered orders vs total orders).

-- WITH total_orders AS (
--     SELECT 
--         restaurant_id,
--         COUNT(*) AS total_orders
--     FROM orders
--     GROUP BY restaurant_id
-- ),
-- undelivered AS (
--     SELECT 
--         o.restaurant_id,
--         COUNT(*) AS failed_deliveries
--     FROM deliveries d
--     JOIN orders o ON o.order_id = d.order_id
--     WHERE d.delivery_status != 'Delivered'
--     GROUP BY o.restaurant_id
-- )
-- SELECT 
--     r.restaurant_name,
--     r.city,
--     t.total_orders,
--     COALESCE(u.failed_deliveries, 0) AS failed_deliveries,
--     ROUND(COALESCE(u.failed_deliveries, 0) / t.total_orders * 100, 2) AS failure_rate_percent
-- FROM total_orders t
-- JOIN restaurants r ON r.restaurant_id = t.restaurant_id
-- LEFT JOIN undelivered u ON t.restaurant_id = u.restaurant_id
-- ORDER BY failure_rate_percent DESC
-- LIMIT 10;





