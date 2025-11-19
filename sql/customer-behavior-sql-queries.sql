USE customer_behav;

-- Q1. Total revenue by gender
SELECT Gender,
       SUM(`Purchase Amount (USD)`) AS revenue
FROM customer_shopping_behavior
GROUP BY Gender;


-- Q2. Discount users who spent more than average amount
SELECT `Customer ID`, `Purchase Amount (USD)`
FROM customer_shopping_behavior
WHERE `Discount Applied` = 'Yes'
  AND `Purchase Amount (USD)` >= (
        SELECT AVG(`Purchase Amount (USD)`)
        FROM customer_shopping_behavior
  );


-- Q3. Top 5 highest-rated products
SELECT `Item Purchased`,
       ROUND(AVG(`Review Rating`), 2) AS Average_Product_Rating
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY AVG(`Review Rating`) DESC
LIMIT 5;


-- Q4. Average Spending by Shipping Type
SELECT `Shipping Type`,
       ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_purchase_amount
FROM customer_shopping_behavior
WHERE `Shipping Type` IN ('Standard','Express')
GROUP BY `Shipping Type`;


-- Q5. Do subscribed customers spend more?
SELECT `Subscription Status`,
       COUNT(`Customer ID`) AS total_customers,
       ROUND(AVG(`Purchase Amount (USD)`), 2) AS avg_spend,
       ROUND(SUM(`Purchase Amount (USD)`), 2) AS total_revenue
FROM customer_shopping_behavior
GROUP BY `Subscription Status`
ORDER BY total_revenue DESC, avg_spend DESC;


-- Q6. Top 5 products with highest discount usage rate
SELECT `Item Purchased`,
       ROUND(
            100.0 * SUM(CASE WHEN `Discount Applied` = 'Yes' THEN 1 ELSE 0 END) 
            / COUNT(*)
       , 2) AS discount_rate
FROM customer_shopping_behavior
GROUP BY `Item Purchased`
ORDER BY discount_rate DESC
LIMIT 5;


-- Q7. Segment customers (New, Returning, Loyal)
WITH customer_type AS (
    SELECT 
        `Customer ID`,
        `Previous Purchases`,
        CASE 
            WHEN `Previous Purchases` = 1 THEN 'New'
            WHEN `Previous Purchases` BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customer_shopping_behavior
)
SELECT customer_segment,
       COUNT(*) AS Number_of_Customers
FROM customer_type
GROUP BY customer_segment;


-- Q8. Top 3 most purchased products in each category
WITH item_counts AS (
    SELECT 
        Category,
        `Item Purchased`,
        COUNT(`Customer ID`) AS total_orders,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY COUNT(`Customer ID`) DESC) AS item_rank
    FROM customer_shopping_behavior
    GROUP BY Category, `Item Purchased`
)
SELECT item_rank, Category, `Item Purchased`, total_orders
FROM item_counts
WHERE item_rank <= 3;


-- Q9. Repeat buyers (>5 purchases) & subscription status
SELECT `Subscription Status`,
       COUNT(`Customer ID`) AS repeat_buyers
FROM customer_shopping_behavior
WHERE `Previous Purchases` > 5
GROUP BY `Subscription Status`;


-- Q10. Revenue contribution by age group
SELECT 
    CASE  
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '55+'
    END AS age_group,
    SUM(`Purchase Amount (USD)`) AS total_revenue
FROM customer_shopping_behavior
GROUP BY age_group
ORDER BY total_revenue DESC;
