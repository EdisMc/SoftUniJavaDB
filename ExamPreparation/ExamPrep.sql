CREATE DATABASE exercise_exam_prep;
USE exercise_exam_prep;

-- 01
-- --------------------------------
CREATE TABLE users (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`username` VARCHAR(30) NOT NULL UNIQUE, 
`password` VARCHAR(30) NOT NULL, 
`email` VARCHAR(50) NOT NULL, 
`gender` CHAR NOT NULL, 
`age` INT NOT NULL, 
`job_title` VARCHAR(50) NOT NULL,
`ip` VARCHAR(30) NOT NULL
);

CREATE TABLE addresses (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`address` VARCHAR(30) NOT NULL, 
`town` VARCHAR(30) NOT NULL, 
`country` VARCHAR(30) NOT NULL,
`user_id` INT NOT NULL,
CONSTRAINT fk_addresses_users 
FOREIGN KEY (user_id)
REFERENCES users(id)
); 

CREATE TABLE photos (
`id`INT PRIMARY KEY AUTO_INCREMENT, 
`description` TEXT NOT NULL, 
`date` DATETIME NOT NULL,
`views` INT NOT NULL DEFAULT 0
);

CREATE TABLE comments (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`comment` VARCHAR(255) NOT NULL, 
`date` DATETIME NOT NULL,
`photo_id` INT NOT NULL, 
CONSTRAINT fk_comments_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);

CREATE TABLE users_photos (
`user_id` INT NOT NULL,
`photo_id` INT NOT NULL,
CONSTRAINT fk_users_photos
FOREIGN KEY (user_id)
REFERENCES users(id),
CONSTRAINT fk_photos_users
FOREIGN KEY (photo_id)
REFERENCES photos(id)
);

CREATE TABLE likes (
`id` INT PRIMARY KEY AUTO_INCREMENT,
`photo_id` INT,
`user_id` INT,
CONSTRAINT fk_likes_photos
FOREIGN KEY (photo_id)
REFERENCES photos(id),
CONSTRAINT fk_likes_users
FOREIGN KEY (user_id)
REFERENCES users(id)
);

-- 02 
-- ------------------------
INSERT INTO addresses (address, town, country, user_id)
SELECT u.username, u.password, u.ip, u.age
FROM users AS u
WHERE u.gender = 'M';

-- 03
-- ------------------------
UPDATE addresses as a 
SET country = (
	CASE 
		WHEN a.country LIKE 'B%' THEN 'Blocked'
		WHEN a.country LIKE 'T%' THEN 'Test'
		WHEN a.country LIKE 'P%' THEN 'In Progress'
        ELSE a.country
    END
);

-- 04 
-- ------------------------
DELETE FROM addresses as a
where a.id % 3 = 0;

-- 05 
-- ------------------------
SELECT 
    username, gender, age
FROM
    users
ORDER BY age DESC , username ASC;

-- 06 
-- ------------------------
SELECT 
    p.id, p.date, p.description, COUNT(c.id) AS 'comments_count'
FROM
    photos AS p
        JOIN
    comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY comments_count DESC , p.id ASC
LIMIT 5;

-- 07 
-- -------------------------------------
SELECT 
    CONCAT_WS(' ', u.id, u.username), u.email
FROM
    users AS u
        JOIN
    users_photos AS up ON u.id = up.user_id AND u.id = up.photo_id
ORDER BY u.id;

-- 08 
-- ---------------------------------------
SELECT 
    p.id,
    COUNT(DISTINCT l.id) AS 'likes_count',
    COUNT(DISTINCT c.id) AS 'comments_count'
FROM
    photos AS p
        LEFT JOIN
    likes AS l ON p.id = l.photo_id
        LEFT JOIN
    comments AS c ON p.id = c.photo_id
GROUP BY p.id
ORDER BY likes_count DESC , comments_count DESC , p.id ASC;

-- 09 
-- ----------------------------------
SELECT 
    CONCAT(LEFT(p.description, 30), '...') AS 'summary', p.date
FROM
    photos AS p
        LEFT JOIN
    comments AS c ON p.id = c.photo_id
WHERE
    DAY(p.date) = 10
GROUP BY p.id , p.date
ORDER BY p.date DESC;

-- 10 
-- -----------------------------------
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30)) 
RETURNS INT
        RETURN (SELECT COUNT(up.photo_id) 
				FROM users_photos up
						RIGHT JOIN 
					photos AS p ON up.photo_id = p.id
						RIGHT JOIN 
					users AS u ON up.user_id = u.id
        WHERE u.username = username);
        
SELECT udf_users_photos_count('ssantryd') AS photosCount;

DROP FUNCTION IF EXISTS udf_users_photos_count;

-- 11
-- ------------------------------------------------
DELIMITER $$
CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30))
BEGIN
    IF ((SELECT a.address 
		 FROM addresses AS a 
         WHERE a.address = address) IS NOT NULL)
	THEN UPDATE users u
				  JOIN
				addresses a ON u.id = a.user_id 
	SET u.age = u.age + 10
		WHERE a.address = address And a.town = town;
	END IF;
END $$
DELIMITER ;

CALL udp_modify_user ('97 Valley Edge Parkway', 'DivinГіpolis');
SELECT 
    u.username, u.email, u.gender, u.age, u.job_title
FROM
    users AS u
    LEFT JOIN addresses as a on u.id = a.user_id
WHERE
    u.username = 'eblagden21'