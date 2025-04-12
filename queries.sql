/* customers_count */

select COUNT(customer_id) as customers_count
from customers;

/* top 10 total income */

select
	CONCAT(e.first_name, ' ', e.last_name) as seller,
	COUNT(s.sales_id) as operations,
	SUM(p.price * s.quantity) as income
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
	ROUND(SUM(p.price * s.quantity), 2) as income
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
