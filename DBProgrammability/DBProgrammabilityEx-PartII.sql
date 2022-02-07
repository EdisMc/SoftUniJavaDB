DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT concat_ws(' ', first_name, last_name) as 'full_name' FROM account_holders ORDER BY `full_name`, id;
END
$$
DELIMITER ;

--------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_get_holders_with_balance_higher_than (money DECIMAL(19,4))
BEGIN
SELECT first_name, last_name FROM account_holders as ah
	RIGHT JOIN accounts as ac ON ac.account_holder_id = ah.id
    GROUP BY ah.id
    HAVING sum(balance) > money
    ORDER BY ah.id;
END
$$
DELIMITER ;

CALL usp_get_holders_with_balance_higher_than (7000);

----------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value (sum DECIMAL(19,4), interest DECIMAL(19,4), num_years INT)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
	RETURN sum * (pow((1 + interest), num_years));
END
$$
DELIMITER ;
SELECT ufn_calculate_future_value(1000, 0.5, 5);

----------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_calculate_future_value_for_account(acc_id INT, interest DECIMAL(19,4))
BEGIN
	SELECT ac.id AS 'account_id', ah.first_name, ah.last_name, ac.balance AS 'current_balance', 
			ufn_calculate_future_value(ac.balance, interest, 5)
		FROM accounts AS ac
		JOIN account_holders AS ah ON ah.id = ac.account_holder_id
		WHERE ac.id = acc_id;
END
$$
DELIMITER ;

CALL usp_calculate_future_value_for_account(1, 0.1);

--------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF ((SELECT count(a.id) FROM accounts as a WHERE a.id = account_id) != 1 OR money_amount < 0)
		THEN ROLLBACK;
		ELSE
			UPDATE accounts set balance = balance + money_amount WHERE id = account_id;
			COMMIT;
	END IF;
END
$$
DELIMITER ;

------------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF((SELECT count(a.id) FROM accounts as a WHERE a.id = account_id) != 1 OR
		money_amount < 0 OR
        (SELECT balance FROM accounts WHERE id = account_id) < money_amount)
        THEN ROLLBACK;
        ELSE
			UPDATE accounts SET balance = balance - money_amount WHERE id = account_id;
            COMMIT;
		END IF;
END
$$
DELIMITER ;

----------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE usp_transfer_money(from_account_id INT, to_account_id INT, amount DECIMAL(19,4))
BEGIN
	START TRANSACTION;
    IF (
		(SELECT count(a.id) FROM accounts as a WHERE a.id = from_account_id) != 1 OR
        (SELECT count(a.id) FROM accounts as a WHERE a.id = to_account_id) != 1 OR
        amount < 0 OR from_account_id = to_account_id OR
        (SELECT balance FROM accounts WHERE id = from_account_id) < amount
	)	THEN ROLLBACK;
		ELSE
			UPDATE accounts SET balance = balance - amount WHERE id = from_account_id;
			UPDATE accounts SET balance = balance + amount WHERE id = to_account_id;
            COMMIT;
	END IF;
END
$$
DELIMITER ;

------------------------------------------------------------------------------------------------------

CREATE TABLE logs (
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    old_sum DECIMAL(19,4) NOT NULL,
    new_sum DECIMAL(19,4) NOT NULL
);

DELIMITER $$
CREATE TRIGGER tr_transaction_log
AFTER UPDATE
ON accounts
FOR EACH ROW
BEGIN
	INSERT INTO logs SET account_id = old.id, old_sum = old.balance, 
		new_sum = (SELECT balance FROM accounts WHERE id = old.id);
END
$$
 DELIMITER ;
 
DROP TRIGGER tr_transaction_log;
call usp_transfer_money(1,2,10);
SELECT * FROM logs;

----------------------------------------------------------------------------------------------------

SELECT date_format(current_timestamp(), '%b %e %Y at %l:%i:%s %p');

CREATE TABLE notification_emails (
	id INT PRIMARY KEY AUTO_INCREMENT,
    recipient INT NOT NULL,
    subject VARCHAR(100),
    body TEXT
);

DELIMITER $$
CREATE TRIGGER tr_notification_emails
BEFORE INSERT
ON logs
FOR EACH ROW
BEGIN
	INSERT INTO notification_emails SET
			recipient = new.account_id,
            subject = concat('Balance change for account: ', new.account_id),
            body = concat('On ', date_format(current_timestamp(), '%b %e %Y at %l:%i:%s %p'),
					'AM your balance was changed from ', new.old_sum,
                    ' to ', new.new_sum, '.');
			
END
$$
DELIMITER ;

SELECT * FROM notification_emails;