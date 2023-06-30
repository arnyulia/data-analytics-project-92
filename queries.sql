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

/*запрос выводит количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+*/
with tab as(select first_name, last_name, age,
case 
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
when age > 40 then '40+'
end as age_category
from customers)
select age_category, count(last_name) from tab group by age_category order by 1;

/*запрос выводит данные по количеству уникальных покупателей и выручке, которую они принесли по месяцам*/
select to_char(sale_date, 'YYYY-MM') as date,
count(distinct  concat(first_name,' ', last_name))as total_customers, 
sum(quantity*price) as income from customers
join sales on customers.customer_id=sales.customer_id
join products on sales.product_id=products.product_id 
group by 1 order by 1;

/*запрос выводит данные о покупателях, первая покупка которых была в ходе проведения акций*/
with tab as(
select distinct on (c.customer_id) c.customer_id, 
concat(c.first_name,' ', c.last_name) as customer, sale_date,sales_id, 
concat(e.first_name,' ', e.last_name) as seller, p.price from sales s
join customers c on c.customer_id=s.customer_id
join products p on s.product_id=p.product_id
join employees e on s.sales_person_id=e.employee_id
group by 1,2,3,4,5,6
having price=0
order by 1,3
)
select customer, sale_date, seller from tab;
