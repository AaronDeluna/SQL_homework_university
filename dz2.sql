--Количество заказов за все время
select count(*) as "Количество заказов"
from orders;

--Расчет суммы денег за все заказы
select
    order_details.order_id,
    sum((unit_price - (unit_price * discount / 100)) * quantity) AS "Итоговый чек"
from order_details
group by order_details.order_id;

--Расчет количество сотрудников по городу
select city, count(*) "Количество сотрудников"
from employees
group by employees.city;

--Сумма всех заказов сотрудника выод: (фио, сумма)
select 
	concat(employees.first_name, ' ', employees.last_name) "Фио",
	sum(unit_price * quantity) "Сумма всех заказов"
from orders 
inner join employees on orders.employee_id = employees.employee_id
inner join order_details on orders.order_id = order_details.order_id
group by employees.first_name, employees.last_name;

--Перечень товаров от самых продаваемых до самых непродаваемых
"Количество штук"
select
    products.product_name "Наименование товара",
    sum(order_details.quantity) total_sold
FROM order_details
INNER JOIN products ON order_details.product_id = products.product_id
GROUP BY products.product_name
ORDER BY total_sold DESC;



select * from products
