/* customers_count */

SELECT COUNT(customer_id) AS customers_count
FROM customers;

/* top 10 total income */

SELECT
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	COUNT(s.sales_id) AS operations,
	ROUND(SUM(p.price * s.quantity), 0) AS income
FROM employees AS e
INNER JOIN sales AS s
	ON e.employee_id = s.sales_person_id
INNER JOIN products AS p
	ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

/* lowest average income */

SELECT
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	ROUND(SUM(p.price * s.quantity) / COUNT(s.sales_id), 0) AS average_income
FROM employees AS e
INNER JOIN sales AS s
	ON e.employee_id = s.sales_person_id
INNER JOIN products AS p
	ON s.product_id = p.product_id
GROUP BY seller
HAVING
	ROUND(SUM(p.price * s.quantity) / COUNT(s.sales_id), 0) < (
		SELECT ROUND(SUM(products.price * sales.quantity) / COUNT(sales.sales_id), 0)
		FROM sales
		INNER JOIN products
			ON s.product_id = products.product_id
		)
ORDER BY average_income;

/* day of the week income */

SELECT
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	TO_CHAR(s.sale_date, 'FMday') AS day_of_week,
	ROUND(SUM(p.price * s.quantity), 0) AS income
FROM employees AS e
INNER JOIN sales AS s
	ON e.employee_id = s.sales_person_id
INNER JOIN products AS p
	ON s.product_id = p.product_id
GROUP BY
	seller,
	day_of_week,
	(CAST(DATE_PART('dow', s.sale_date) AS INT) + 6) % 7
ORDER BY
	(CAST(DATE_PART('dow', s.sale_date) AS INT) + 6) % 7,
	seller;

/* age groups */

SELECT
	CASE
		WHEN age BETWEEN 16 AND 25 THEN '16-25'
		WHEN age BETWEEN 26 AND 40 THEN '26-40'
		WHEN age > 40 THEN '40+'
	END AS age_category,
	COUNT(age) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category;

/* customers by month */

SELECT
	TO_CHAR(s.sale_date, 'YYYY.MM') AS selling_month,
	COUNT(s.customer_id) AS total_customers,
	ROUND(SUM(s.quantity * p.price), 0) AS income
FROM sales AS s
INNER JOIN products AS p
	ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month;

/* special offer */

WITH first_sale AS (
	SELECT
		c.customer_id,
		CONCAT(c.first_name, ' ', c.last_name) AS customer,
		FIRST_VALUE(s.sale_date) OVER (
			PARTITION BY c.customer_id, e.employee_id
			ORDER BY s.sale_date
		) AS sale_date,
		CONCAT(e.first_name, ' ', e.last_name) AS seller,
		FIRST_VALUE(p.price) OVER (
			PARTITION BY c.customer_id, e.employee_id
			ORDER BY s.sale_date
		) AS first_price
	FROM customers AS c
	INNER JOIN sales AS s
		ON c.customer_id = s.customer_id
	INNER JOIN employees AS e
		ON s.sales_person_id = e.employee_id
	INNER JOIN products AS p
		ON s.product_id = p.product_id
)

SELECT
	customer,
	sale_date,
	seller
FROM first_sale
WHERE first_price = 0
GROUP BY
	customer_id,
	customer,
	sale_date,
	seller
ORDER BY customer_id;
