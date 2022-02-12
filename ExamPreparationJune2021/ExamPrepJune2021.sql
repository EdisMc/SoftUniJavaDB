create table `cars` (
`id` int primary key auto_increment,
`make` varchar(20) not null, 
`model` varchar(20), 
`year` int not null default 0,
`mileage` int default 0,
`condition` char not null,
`category_id` int not null,
constraint fk_cars_categories
foreign key (`category_id`)
references categories(id)
);

create table `courses` (
`id` int primary key auto_increment,
`from_address_id` int not null,
constraint fk_courses_addresses
foreign key (`from_address_id`)
references addresses(id),
`start` datetime not null, 
`car_id` int not null,
constraint fk_courses_cars
foreign key (`car_id`)
references cars(`id`),
`client_id` int not null,
constraint fk_courses_clients
foreign key (`client_id`)
references clients(`id`),
`bill` decimal(10,2) default 10
);

create table `drivers` (
`id` int primary key auto_increment,
`first_name` varchar(30) not null,
`last_name` varchar(30) not null, 
`age` int not null,
 `rating` float default 5.5
);

create table `clients` (
`id` int primary key auto_increment,
`full_name` varchar(50) not null,
`phone_number` varchar(20) not null
);

create table `addresses` (
`id` int primary key auto_increment,
`name` varchar(100) not null
);

create table `categories` (
`id` int primary key auto_increment,
`name` varchar(10) not null
);

create table `cars_drivers` (
`car_id` int not null,
`driver_id` int not null,
constraint pk_cars_drivers
primary key (`car_id`, `driver_id`),
constraint fk_cars_drivers_car
foreign key (`car_id`)
references cars(`id`),
constraint fk_cars_drivers_driver
foreign key (`driver_id`)
references drivers(`id`)
);

-----------------------------------------------------------------------------------------------------------

insert into clients(full_name, phone_number)
	select concat_ws('', d.first_name, d.last_name) as full_name,
		concat('(088) 9999', d.id * 2)
	from drivers as d
    where d.id between 10 and 20;

------------------------------------------------------------------------------------------------------------

UPDATE cars 
SET 
    `condition` = 'C'
WHERE
    (mileage >= 800000 OR mileage IS NULL)
        AND `year` <= 2010
        AND make != 'Mercedes-Benz';

------------------------------------------------------------------------------------------------------------

DELETE FROM clients 
WHERE
    id NOT IN (SELECT 
        client_id
    FROM
        courses)
    AND CHAR_LENGTH(full_name) > 3;

-----------------------------------------------------------------------------------------------------------

select c.make, c.model, c.condition
from cars as c
order by c.id;

------------------------------------------------------------------------------------------------------------

SELECT 
    d.first_name, d.last_name, c.make, c.model, c.mileage
FROM
    drivers AS d
        JOIN
    cars_drivers AS cd ON d.id = cd.driver_id
        JOIN
    cars AS c ON c.id = cd.car_id
    WHERE c.mileage Is NOT NULL
ORDER BY c.mileage DESC , d.first_name;

------------------------------------------------------------------------------------------------------------

SELECT 
    c.id, c.make, c.mileage,
    COUNT(co.id) AS count_of_courses,
    ROUND(AVG(co.bill), 2) AS avg_bill
FROM
    cars AS c
        LEFT JOIN
    courses AS co ON c.id = co.car_id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC , c.id;

------------------------------------------------------------------------------------------------------------

SELECT 
    cl.full_name, COUNT(c.id) AS count_car, SUM(co.bill)
FROM
    clients AS cl
        JOIN
    courses AS co ON cl.id = co.client_id
        JOIN
    cars AS c ON c.id = co.car_id
WHERE
    cl.full_name LIKE '_a%'
GROUP BY cl.full_name
HAVING count_car > 1
ORDER BY cl.full_name;

-----------------------------------------------------------------------------------------------------

SELECT 
    a.`name`,
    (IF(HOUR(co.`start`) BETWEEN 6 AND 20,
        'Day',
        'Night')) AS day_time,
    co.bill,
    cl.full_name,
    c.make,
    c.model,
    ca.`name`
FROM
    clients AS cl
        JOIN
    courses AS co ON cl.id = co.client_id
        JOIN
    addresses AS a ON a.id = co.from_address_id
        JOIN
    cars AS c ON c.id = co.car_id
        JOIN
    categories AS ca ON ca.id = c.category_id
ORDER BY co.id;

-----------------------------------------------------------------------------------------------------------

DELIMITER %%

CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20)) 
RETURNS INTEGER
DETERMINISTIC 
	BEGIN
    RETURN (SELECT COUNT(client_id) FROM courses
			WHERE client_id = (SELECT id FROM clients
			WHERE phone_number = phone_num) );
    END %%

SELECT udf_courses_by_client ('(704) 2502909') as `count`;
SELECT udf_courses_by_client ('(831) 1391236') as `count`;

--------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE udp_courses_by_address (address_name VARCHAR (100))
		BEGIN
				SELECT a.`name`, cl.full_name, 
			(CASE
				WHEN co.bill <= 20 THEN 'Low'
				WHEN co.bill <= 30 THEN 'Medium'
				ELSE 'High'
			END) AS level_of_bill,
			c.make, c.`condition`, ca.`name` AS cat_name
				FROM  clients AS cl
					JOIN
				courses AS co ON cl.id = co.client_id
					JOIN
				addresses AS a ON a.id = co.from_address_id
					JOIN
				cars AS c ON c.id = co.car_id
					JOIN
				categories AS ca ON ca.id = c.category_id
				WHERE a.`name` = address_name
				ORDER BY c.make, cl.full_name;
        END %%