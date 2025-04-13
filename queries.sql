/* customers_count */

SELECT COUNT(customer_id) AS customers_count
FROM customers;

/* top 10 total income */

SELECT
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	COUNT(s.sales_id) AS operations,
	FLOOR(SUM(p.price * s.quantity)) AS income
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
	FLOOR(SUM(p.price * s.quantity) / COUNT(s.sales_id)) AS average_income
FROM employees AS e
INNER JOIN sales AS s
	ON e.employee_id = s.sales_person_id
INNER JOIN products AS p
	ON s.product_id = p.product_id
GROUP BY seller
HAVING
	FLOOR(SUM(p.price * s.quantity) / COUNT(s.sales_id)) < (
		SELECT FLOOR(SUM(products.price * sales.quantity) / COUNT(sales.sales_id))
		FROM sales
		INNER JOIN products
			ON sales.product_id = products.product_id
		)
ORDER BY average_income;

/* day of the week income */

SELECT
	CONCAT(e.first_name, ' ', e.last_name) AS seller,
	TO_CHAR(s.sale_date, 'FMday') AS day_of_week,
	FLOOR(SUM(p.price * s.quantity)) AS income
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
	FLOOR(SUM(s.quantity * p.price)) AS income
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
        s.sale_date,
        CONCAT(e.first_name, ' ', e.last_name) AS seller,
        p.price,
        ROW_NUMBER() OVER (
			PARTITION BY c.customer_id ORDER BY s.sale_date
		) AS rn
    FROM customers AS c
    JOIN sales AS s ON c.customer_id = s.customer_id
    JOIN employees AS e ON s.sales_person_id = e.employee_id
    JOIN products AS p ON s.product_id = p.product_id
)

SELECT
    customer,
    sale_date,
    seller
FROM first_sale
WHERE rn = 1 AND price = 0
ORDER BY customer;
