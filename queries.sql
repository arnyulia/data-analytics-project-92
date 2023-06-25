/*запрос считает общее кол-во покупателей*/
select count(id) as customers_count from customers;

/*запрос на вывод топ-10 продавцов с наибольшими продажами*/
select concat(first_name,' ', last_name) as name, count(sales_id) as operations, sum(quantity*price) as income
from employees
join sales on employee_id=sales_person_id
join products on sales.product_id=products.product_id 
group by 1 order by 3 
limit 10;

/*отчет выводит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам*/
with tab as (
select sum(quantity*price)/count(sales_id) as avg_sum from sales
join products on sales.product_id=products.product_id
)
select concat(first_name,' ', last_name) as name, round(avg(quantity*price),0)as average_income 
from employees 
join sales on employee_id=sales_person_id
join products on sales.product_id=products.product_id group by 1
having(avg(quantity*price)<(select avg_sum from tab))
order by 2;

/*запрос выводит информацию о выручке по дням недели*/
select * from (select concat(first_name,' ', last_name) as name, to_char(sale_date, 'Day') as weekday, 
round(sum(quantity*price),0) as income from employees 
join sales on employee_id=sales_person_id
join products on sales.product_id=products.product_id
group by 1, 2 ) a
order by  
	CASE
          WHEN weekday = 'Sunday   ' THEN 8
          WHEN weekday = 'Monday   ' THEN 2
          WHEN weekday = 'Tuesday  ' THEN 3
          WHEN weekday = 'Wednesday' THEN 4
          WHEN weekday = 'Thursday ' THEN 5
          WHEN weekday = 'Friday   ' THEN 6
          WHEN weekday = 'Saturday ' THEN 7
     end, name;

