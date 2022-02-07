DELIMITER $$
create procedure usp_get_employees_salary_above_35000()
begin
	select e.`first_name`, e.`last_name` 
	from `employees` as e 
	where e.`salary` > 35000
	order by e.`first_name`, e.`last_name`, e.`employee_id`;
end $$
DELIMITER ;

call usp_get_employees_salary_above_35000();

-----------------------------------------------------------------------------------------------------------

delimiter $$
create procedure usp_get_employees_salary_above(`salary_level` decimal(18,4))
begin
	select e.`first_name`, e.`last_name`
    from `employees` as e
    where e.`salary` >= `salary_level`
    order by e.`first_name`, e.`last_name`, e.`employee_id`;
end $$
delimiter ;

call usp_get_employees_salary_above(45000);

-------------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with(start_with VARCHAR(20))
BEGIN
	SELECT name AS 'town_name' 
    FROM `towns`
    WHERE left(LOWER(name), char_length(start_with)) = lower(start_with)
	ORDER BY `town_name`;
END $$
DELIMITER ;

CALL usp_get_towns_starting_with('b');

----------------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town(employees_in_town VARCHAR(50))
BEGIN
	SELECT e.first_name, e.last_name
		FROM employees AS e
        JOIN addresses as a USING (address_id)
        JOIN towns  as t USING (town_id)
        WHERE t.name = employees_in_town
        ORDER BY e.first_name, e.last_name, e.employee_id;
END $$
DELIMITER ;

CALL usp_get_employees_from_town('Sofia');

------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE FUNCTION ufn_get_salary_level(employee_salary DECIMAL)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
	DECLARE level_of_salary VARCHAR(10);
    SET level_of_salary := (
		SELECT
			CASE 
				WHEN employee_salary < 30000 THEN 'Low'
                WHEN employee_salary BETWEEN 30000 AND 50000 THEN 'Average'
                ELSE 'High'
			END
	);
	RETURN level_of_salary;	
END $$
DELIMITER ;

SELECT ufn_get_salary_level(60000);
------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(7))
BEGIN
    SELECT e.first_name, e.last_name
    FROM `employees` AS e
    WHERE e.salary < 30000 AND salary_level = 'low'
        OR e.salary >= 30000 AND e.salary <= 50000 AND salary_level = 'average'
        OR e.salary > 50000 AND salary_level = 'high'
    ORDER BY e.first_name DESC, e.last_name DESC;
END $$
DELIMITER ;

CALL usp_get_employees_by_salary_level('high');
------------------------------------------------------------------------------------------------------------
DELIMITER $$
CREATE FUNCTION ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS bit
DETERMINISTIC
BEGIN
	RETURN word REGEXP (concat('^[',set_of_letters,']*$'));
END $$
DELIMITER ;

SELECT ufn_is_word_comprised('asdf', 'safd');
SELECT ufn_is_word_comprised('asdf', 'csafd');
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------