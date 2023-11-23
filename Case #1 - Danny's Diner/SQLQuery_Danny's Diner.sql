
------------------------------------------------------------------------------------------------------------------
-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, 
	   SUM(price) as [Total_Spend]
FROM [dbo].[menu] as m
INNER JOIN [dbo].[sales] as s
ON m.product_id = s.product_id
GROUP BY s.customer_id;

------------------------------------------------------------------------------------------------------------------
-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, 
       COUNT(DISTINCT order_date) as [Number_Of_Days]
FROM [dbo].[sales]
GROUP BY customer_id;

------------------------------------------------------------------------------------------------------------------
-- 3. What was the first item from the menu purchased by each customer?
WITH CTE_table
AS(
SELECT s.customer_id, 
       m.product_name, 
	   s.order_date, 
       RANK() OVER ( PARTITION BY s.customer_id ORDER BY s.order_date ASC) as [ranking]
FROM [dbo].[menu] as m
INNER JOIN [dbo].[sales] as s
ON m.product_id = s.product_id)

SELECT customer_id, product_name
FROM CTE_table
WHERE ranking = 1;

------------------------------------------------------------------------------------------------------------------
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1 m.product_name, 
       COUNT(s.product_id) as [Number_Order]
FROM [dbo].[sales] as s
INNER JOIN [dbo].[menu] as m
ON s.product_id = m.product_id
GROUP BY  m.product_name
ORDER BY COUNT(s.product_id) DESC;

------------------------------------------------------------------------------------------------------------------
-- 5. Which item was the most popular for each customer?
WITH CTE_table
AS (
SELECT s.customer_id, 
       s.product_id, 
	   m.product_name, 
	   COUNT(s.product_id) AS [Number_Order],
       RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS [Rank]
FROM [dbo].[sales] as s
INNER JOIN [dbo].[menu] as m
ON s.product_id = m.product_id
GROUP BY  s.customer_id, s.product_id, m.product_name)

SELECT customer_id, 
       product_name, 
	   Number_Order
FROM CTE_table
WHERE Rank = 1;

------------------------------------------------------------------------------------------------------------------
-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE_table
AS (
SELECT s.customer_id, 
       m.join_date, 
	   s.order_date, 
	   me.product_name,
       RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) as [ranking]
FROM [dbo].[sales] as s
INNER JOIN [dbo].[members] as m
ON s.customer_id = m.customer_id
INNER JOIN [dbo].[menu] as me
ON s.product_id = me.product_id
WHERE m.join_date <= s.order_date)

SELECT customer_id, join_date, order_date, product_name
FROM CTE_table
WHERE ranking = 1;

------------------------------------------------------------------------------------------------------------------
-- 7. Which item was purchased just before the customer became a member?
SELECT DISTINCT s.customer_id, 
                me.product_name
FROM [dbo].[sales] as s
INNER JOIN [dbo].[members] as m
ON s.customer_id = m.customer_id
INNER JOIN [dbo].[menu] as me
ON s.product_id = me.product_id
WHERE m.join_date > s.order_date;

------------------------------------------------------------------------------------------------------------------
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id,  
       COUNT(me.product_name) AS [total_items],
	   SUM(me.price) AS [total_amount_spent]
FROM [dbo].[sales] as s
INNER JOIN [dbo].[members] as m
ON s.customer_id = m.customer_id
INNER JOIN [dbo].[menu] as me
ON s.product_id = me.product_id
WHERE m.join_date > s.order_date
GROUP BY s.customer_id;
------------------------------------------------------------------------------------------------------------------
/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier
      How many points would each customer have? 
*/
SELECT s.customer_id,
       SUM(CASE 
				WHEN me.product_name LIKE 'sushi' THEN (me.price * 20) 
				ELSE ( me.price * 10)
		   END) as [total_point]
FROM [dbo].[sales] as s
INNER JOIN [dbo].[menu] as me
ON s.product_id = me.product_id
GROUP BY s.customer_id;

------------------------------------------------------------------------------------------------------------------
/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
       How many points do customer A and B have at the end of January? 
*/
SELECT s.customer_id,
	   SUM(CASE 
				WHEN s.order_date BETWEEN m.join_date AND DATEADD(day, 6, m.join_date) THEN (me.price * 10 * 2) 
				WHEN me.product_name LIKE 'sushi' THEN (me.price * 10 * 2)
				ELSE (me.price * 10)
		   END) as [total_point]
FROM [dbo].[sales] as s
INNER JOIN [dbo].[menu] as me
ON s.product_id = me.product_id
INNER JOIN [dbo].[members] as m
ON s.customer_id = m.customer_id
WHERE DATETRUNC(month, s.order_date) = '2021-01-01'
GROUP BY s.customer_id;

------------------------------------------------------------------------------------------------------------------
/* BONUS QUESTIONS
1. Join All The Things
*/
SELECT s.customer_id, 
       s.order_date, 
	   me.product_name, 
	   me.price,
	   CASE 
			WHEN s.order_date >= m.join_date THEN 'Y'
			ELSE 'N'
	   END as [member]
FROM [dbo].[sales] as s
INNER JOIN [dbo].menu as me
ON s.product_id = me.product_id
LEFT JOIN [dbo].members as m
ON s.customer_id = m.customer_id
ORDER BY s.customer_id ASC, s.order_date ASC;

-- 2. Rank All The Things
WITH CTE_table
AS (
SELECT s.customer_id, 
       s.order_date, 
	   me.product_name, 
	   me.price, 
	   CASE 
			WHEN s.order_date >= m.join_date THEN 'Y'
			ELSE 'N'
	   END as [member]
FROM [dbo].[sales] as s
INNER JOIN [dbo].menu as me
ON s.product_id = me.product_id
LEFT JOIN [dbo].members as m
ON s.customer_id = m.customer_id)

SELECT *,
CASE 
	WHEN member LIKE 'N' THEN NULL
	ELSE RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
END as [ranking]
FROM CTE_table
 




 


