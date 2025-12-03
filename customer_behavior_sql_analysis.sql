/*
Author: Nick Skaleski
RDMS: SQL Server
Database Name: customer_behavior
Table Name: customer_shopping_behavior

Below are 10 queries used to analyze customer behavior
*/

-- 1.) Total revenue generated male vs female customer
SELECT gender, SUM(purchase_amount) AS revenue
FROM customer_shopping_behavior
GROUP BY gender


-- 2.) customer that used a discount but still spent more than the average purchase amount
SELECT customer_id
FROM customer_shopping_behavior
WHERE purchase_amount > 
	(SELECT AVG(purchase_amount)
	FROM customer_shopping_behavior)


-- 3.) 5 products with highest average review rating
SELECT TOP 5 customer_id, AVG(review_rating)
FROM customer_shopping_behavior
GROUP BY customer_id
ORDER BY AVG(review_rating) DESC


-- 4.) Comparing average purchase amounts between standard and express shipping
SELECT shipping_type, AVG(purchase_amount)
FROM customer_shopping_behavior
GROUP BY shipping_type
HAVING shipping_type IN ('Standard','Express')
ORDER BY AVG(purchase_amount)


-- 5.) Do subscribed customers spend more? Compare average spend and total revenue between subscribers and non-subscribers
SELECT subscription_status, AVG(purchase_amount), SUM(purchase_amount)
FROM customer_shopping_behavior
GROUP BY subscription_status


-- 6.) Which 5 products have the highest percentage of purchases with discounts applied
SELECT TOP 5 item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*),2) AS discount_rate
FROM customer_shopping_behavior
GROUP BY item_purchased
ORDER BY discount_rate DESC;


-- 7.) segment customer into New, Returning, and Loyal based on their total
-- number of previous purchases. Show the count of each segment
WITH customer_type AS (
SELECT customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
FROM customer_shopping_behavior
)

select customer_segment, COUNT(*) AS "Number of Customers"
from customer_type
GROUP BY customer_segment


-- 8.) what are the top 3 most purchased products within each category?
WITH item_counts AS (
SELECT category,
item_purchased,
COUNT(customer_id) AS total_orders,
ROW_Number() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
from [customer_shopping_behavior]
GROUP BY category, item_purchased
)

Select item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;


-- 9.) Are customers who are repeart buyers (more than 5 previous purchases) also likely to subscribe?
SELECT subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM [customer_shopping_behavior]
WHERE previous_purchases > 5
GROUP BY subscription_status


-- 10.) What is the revenue contribution of each age group?
SELECT age_group,
SUM(purchase_amount) AS total_revenue
from [customer_shopping_behavior]
GROUP BY age_group
ORDER BY total_revenue DESC