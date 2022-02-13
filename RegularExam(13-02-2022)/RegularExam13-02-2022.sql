create table `brands` (
`id` int primary key auto_increment,
`name` varchar(40) not null unique
);

create table `categories` (
`id` int primary key auto_increment,
`name` varchar(40) not null unique
);

create table `reviews` (
`id` int primary key auto_increment,
`content` text,
`rating` decimal(10,2) not null,
`picture_url` varchar(80) not null,
`published_at` datetime not null
);

create table `products` (
`id` int primary key auto_increment,
`name` varchar(40) not null,
`price` decimal(19,2) not null,
`quantity_in_stock` int,
`description` text,
`brand_id` int not null,
`category_id` int not null,
`review_id` int,
constraint fk_products_brands
foreign key (`brand_id`)
references brands(`id`),
constraint fk_products_categories
foreign key (`category_id`)
references categories(`id`),
constraint fk_products_reviews
foreign key (`review_id`)
references reviews(`id`)
);

create table `customers` (
`id` int primary key auto_increment,
`first_name` varchar(20) not null,
`last_name`	varchar(20) not null,
`phone`	varchar(30) not null unique,
`address` varchar(60) not null,
`discount_card` bit not null default 0
);

create table `orders` (
`id` int primary key auto_increment,
`order_datetime` datetime not null,
`customer_id` int not null,
constraint fk_orders_customers
foreign key (`customer_id`)
references customers(`id`)
);

create table `orders_products` (
`order_id` int,
`product_id` int,
constraint fk_orders_products_orders
foreign key (`order_id`)
references orders(`id`),
constraint fk_orders_products_product
foreign key (`product_id`)
references products(`id`)
);