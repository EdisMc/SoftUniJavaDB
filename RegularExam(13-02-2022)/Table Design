#02 INSERT--------------------------------------------------------------------------------------------------------
insert into reviews(content, picture_url, published_at, rating) 
 (select
	 left(p.`description`, 15),
	 reverse(p.`name`),'2010-10-10', p.`price` / 8
 from products as p
 where id >= 5
 );

#03 UPDATE---------------------------------------------------------------------------------------------------------
update products as p
set p.quantity_in_stock = p.quantity_in_stock - 5
where p.quantity_in_stock >= 60 and p.quantity_in_stock <=70;

#04 DELETE--------------------------------------------------------------------------------------------------------
delete from `customers`
where `id` not in (select `customer_id` from `orders`);

#05---------------------------------------------------------------------------------------------------------------
select c.id, c.name
from categories as c
order by c.name desc;

#06---------------------------------------------------------------------------------------------------------------
select p.id, p.brand_id, p.name, p.quantity_in_stock
from products as p
where p.price >1000 and p.quantity_in_stock < 30
order by p.quantity_in_stock, p.id;

#07---------------------------------------------------------------------------------------------------------------
select r.id, r.content, r.rating, r.picture_url, r.published_at
from reviews as r
where r.content like 'My%' and char_length(r.content) > 61
order by r.rating desc;

#08--------------------------------------------------------------------------------------------------------------
select concat(c.first_name,'',c.last_name) as full_name, c.address, o.order_datetime as order_date
from customers as c
join orders as o
on c.id = o.customer_id
where o.order_datetime <= date('2018-01-01')
order by full_name desc;

#09---------------------------------------------------------------------------------------------------------------
select count(*) as 'items_count', c.name, sum(p.quantity_in_stock) as 'total_quantity'
from products p 
join categories c on p.category_id = c.id
group by c.id
order by items_count desc, total_quantity
limit 5;

#10---------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE FUNCTION udf_customer_products_count(customer_name VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
 RETURN (SELECT COUNT(o.id) AS total_products
 FROM orders o LEFT JOIN orders_products op 
 ON o.id = op.order_id WHERE o.customer_id = (SELECT id FROM customers WHERE first_name = customer_name));
 END $$

SELECT c.first_name,c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';


#11---------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE udp_reduce_price (`category_name` VARCHAR(50))
BEGIN
  UPDATE `products` AS p
  JOIN `reviews` AS r
  ON p.`review_id` = r.`id`
  JOIN `categories` AS c
  ON p.`category_id` = c.`id`
  SET `price` = `price` - (`price` * 0.3)
  WHERE r.`rating` < 4
  AND c.`name` = category_name;
END $$


SELECT c.first_name,c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';




