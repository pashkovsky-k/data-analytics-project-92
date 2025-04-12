/* customers_count */

select COUNT(customer_id) as customers_count
from customers;

/* top 10 total income */

select
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	COUNT(s.sales_id) as operations,
	ROUND(SUM(p.price * s.quantity), 0) as income
from employees as e
inner join sales as s
	on s.sales_person_id = e.employee_id
inner join products as p
	on p.product_id = s.product_id
group by seller
order by income DESC
limit 10;

/* lowest average income */

select
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	ROUND(SUM(p.price * s.quantity) / COUNT(s.sales_id), 0) as average_income
from employees as e
inner join sales as s
	on s.sales_person_id = e.employee_id
inner join products as p
	on p.product_id = s.product_id
group by seller
having ROUND(SUM(p.price * s.quantity) / COUNT(s.sales_id), 0) < (
	select ROUND(SUM(p.price * s.quantity) / COUNT(s.sales_id), 0)
	from sales as s
	inner join products as p
		on p.product_id = s.product_id
)
order by average_income;

/* day of the week income */

select
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	TO_CHAR(s.sale_date, 'FMday') as day_of_week,
	ROUND(SUM(p.price * s.quantity), 0) as income
from employees as e
inner join sales as s
	on s.sales_person_id = e.employee_id
inner join products as p
	on p.product_id = s.product_id
group by
	seller,
	day_of_week,
	(CAST(DATE_PART('dow', s.sale_date) AS INT) + 6) % 7
ORDER by
	(CAST(DATE_PART('dow', s.sale_date) AS INT) + 6) % 7,
	seller;

/* age groups */

select
	case
		when age between 16 and 25 then '16-25'
		when age between 26 and 40 then '26-40'
		when age > 40 then '40+'
	end as age_category,
	COUNT(age) as age_count
from customers
group by age_category
order by age_category;

/* customers by month */

select
	TO_CHAR(s.sale_date, 'YYYY.MM') as selling_month,
	COUNT(s.customer_id) as total_customers,
	ROUND(SUM(s.quantity * p.price), 0) as income
from sales as s
inner join products as p
	on p.product_id = s.product_id
group by selling_month
order by selling_month;

/* special offer */

with first_sale as (
	select
		c.customer_id,
		CONCAT(c.first_name, ' ', c.last_name) as customer,
		FIRST_VALUE(s.sale_date) over (
			partition by c.customer_id, e.employee_id
			order by s.sale_date
		) as sale_date,
		CONCAT(e.first_name, ' ', e.last_name) as seller,
		FIRST_VALUE(p.price) over (
			partition by c.customer_id, e.employee_id
			order by s.sale_date
		) as first_price
	from customers as c
	inner join sales as s
		on c.customer_id = s.customer_id
	inner join employees as e
		on e.employee_id = s.sales_person_id
	inner join products as p
		on p.product_id = s.product_id
)

select
	customer,
	sale_date,
	seller
from first_sale
where first_price = 0
group by
	customer_id,
	customer,
	sale_date,
	seller
order by customer_id;
