-- =========================================================
-- BANK MANAGEMENT SYSTEM
-- MySQL Only DBMS Project
-- Complete Single-Flow Script
-- =========================================================

-- 1) Create database
CREATE DATABASE IF NOT EXISTS bank_management_system;
USE bank_management_system;

-- =========================================================
-- 2) TABLE CREATION
-- =========================================================

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL,
    dob DATE NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees/Admin table
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    designation VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(12,2) DEFAULT 0,
    status ENUM('Active','Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Accounts table
CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type ENUM('Savings','Current') NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    ifsc_code VARCHAR(20) NOT NULL,
    opening_date DATE NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    status ENUM('Active','Closed','Frozen') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- Transactions table
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    related_account_id INT NULL,
    transaction_type ENUM('Deposit','Withdrawal','TransferIn','TransferOut') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    remarks VARCHAR(255),
    CONSTRAINT chk_amount_positive CHECK (amount > 0),
    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_transactions_related_account
        FOREIGN KEY (related_account_id) REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    loan_type ENUM('Home','Personal','Education','Business','Car','Gold') NOT NULL,
    principal_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    start_date DATE NOT NULL,
    status ENUM('Applied','Approved','Rejected','Closed') DEFAULT 'Applied',
    outstanding_amount DECIMAL(15,2) NOT NULL,
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_principal_positive CHECK (principal_amount > 0),
    CONSTRAINT chk_interest_positive CHECK (interest_rate >= 0),
    CONSTRAINT fk_loans_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_loans_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================================
-- 3) INDEXES
-- =========================================================

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_accounts_account_number ON accounts(account_number);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_loans_account_id ON loans(account_id);
CREATE INDEX idx_employees_username ON employees(username);

-- =========================================================
-- 4) SAMPLE DATA
-- =========================================================

INSERT INTO customers (first_name, last_name, gender, dob, phone, email, address, city, state, pincode)
VALUES
('Amit', 'Sharma', 'Male', '1998-04-12', '9876543210', 'amit.sharma@gmail.com', '12 MG Road', 'Delhi', 'Delhi', '110001'),
('Priya', 'Verma', 'Female', '2000-08-25', '9876543211', 'priya.verma@gmail.com', '45 Park Street', 'Kolkata', 'West Bengal', '700016'),
('Rahul', 'Singh', 'Male', '1997-11-18', '9876543212', 'rahul.singh@gmail.com', '77 Civil Lines', 'Lucknow', 'Uttar Pradesh', '226001'),
('Suresh', 'Yadav', 'Male', '1999-02-14', '9876543213', 'suresh.yadav@gmail.com', '21 Station Road', 'Pune', 'Maharashtra', '411001');

INSERT INTO employees (full_name, designation, phone, email, username, password_hash, hire_date, salary)
VALUES
('Neha Kapoor', 'Manager', '9000000001', 'neha.kapoor@bank.com', 'neha_admin', 'hashed_pwd_1', '2022-01-15', 75000),
('Rohit Mehra', 'Clerk', '9000000002', 'rohit.mehra@bank.com', 'rohit_clerk', 'hashed_pwd_2', '2023-06-10', 35000);

INSERT INTO accounts (customer_id, account_number, account_type, branch_name, ifsc_code, opening_date, balance, status)
VALUES
(1, 'SBIN0001001', 'Savings', 'Delhi Main Branch', 'SBIN0001234', '2024-01-10', 5000.00, 'Active'),
(2, 'SBIN0001002', 'Current', 'Kolkata Branch', 'SBIN0001235', '2024-02-05', 12000.00, 'Active'),
(3, 'SBIN0001003', 'Savings', 'Lucknow Branch', 'SBIN0001236', '2024-03-20', 8000.00, 'Active'),
(4, 'SBIN0001004', 'Savings', 'Pune Branch', 'SBIN0001237', '2024-07-01', 3000.00, 'Active');

INSERT INTO loans (customer_id, account_id, loan_type, principal_amount, interest_rate, tenure_months, start_date, status, outstanding_amount, remarks)
VALUES
(1, 1, 'Personal', 100000.00, 10.50, 24, '2024-05-01', 'Approved', 98000.00, 'First disbursement done'),
(2, 2, 'Business', 250000.00, 11.25, 36, '2024-06-15', 'Applied', 250000.00, 'Under verification');

-- =========================================================
-- 5) CRUD: SELECT / UPDATE / DELETE
-- =========================================================

-- View records
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM accounts;
SELECT * FROM transactions;
SELECT * FROM loans;

-- Update records
UPDATE customers
SET phone = '9999999999', city = 'Noida'
WHERE customer_id = 1;

UPDATE accounts
SET account_type = 'Savings', status = 'Active'
WHERE account_id = 2;

UPDATE loans
SET status = 'Approved', remarks = 'Loan approved by manager'
WHERE loan_id = 2;

UPDATE employees
SET salary = 40000, status = 'Active'
WHERE employee_id = 2;

-- Delete records
DELETE FROM employees WHERE employee_id = 2;
DELETE FROM loans WHERE loan_id = 2;

-- =========================================================
-- 6) TRIGGERS
-- Automatically update account balance after deposit/withdrawal/transfer
-- =========================================================

DELIMITER //

CREATE TRIGGER trg_after_deposit
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type IN ('Deposit', 'TransferIn') THEN
        UPDATE accounts
        SET balance = balance + NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END//

CREATE TRIGGER trg_after_withdrawal
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type IN ('Withdrawal', 'TransferOut') THEN
        UPDATE accounts
        SET balance = balance - NEW.amount
        WHERE account_id = NEW.account_id;
    END IF;
END//

DELIMITER ;

-- =========================================================
-- 7) STORED PROCEDURES
-- =========================================================

DELIMITER //

-- Add new customer
CREATE PROCEDURE sp_add_customer(
    IN p_first_name VARCHAR(50),
    IN p_last_name VARCHAR(50),
    IN p_gender ENUM('Male','Female','Other'),
    IN p_dob DATE,
    IN p_phone VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_address VARCHAR(255),
    IN p_city VARCHAR(50),
    IN p_state VARCHAR(50),
    IN p_pincode VARCHAR(10)
)
BEGIN
    INSERT INTO customers(first_name, last_name, gender, dob, phone, email, address, city, state, pincode)
    VALUES (p_first_name, p_last_name, p_gender, p_dob, p_phone, p_email, p_address, p_city, p_state, p_pincode);
END//

-- Create account
CREATE PROCEDURE sp_create_account(
    IN p_customer_id INT,
    IN p_account_number VARCHAR(20),
    IN p_account_type ENUM('Savings','Current'),
    IN p_branch_name VARCHAR(100),
    IN p_ifsc_code VARCHAR(20),
    IN p_opening_date DATE,
    IN p_initial_balance DECIMAL(15,2)
)
BEGIN
    INSERT INTO accounts(customer_id, account_number, account_type, branch_name, ifsc_code, opening_date, balance, status)
    VALUES (p_customer_id, p_account_number, p_account_type, p_branch_name, p_ifsc_code, p_opening_date, p_initial_balance, 'Active');
END//

-- Deposit money
CREATE PROCEDURE sp_deposit_money(
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_remarks VARCHAR(255)
)
BEGIN
    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit amount must be greater than zero';
    END IF;

    INSERT INTO transactions(account_id, related_account_id, transaction_type, amount, remarks)
    VALUES (p_account_id, NULL, 'Deposit', p_amount, p_remarks);
END//

-- Withdraw money
CREATE PROCEDURE sp_withdraw_money(
    IN p_account_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_remarks VARCHAR(255)
)
BEGIN
    DECLARE current_balance DECIMAL(15,2);

    SELECT balance INTO current_balance
    FROM accounts
    WHERE account_id = p_account_id;

    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Withdrawal amount must be greater than zero';
    END IF;

    IF current_balance < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;

    INSERT INTO transactions(account_id, related_account_id, transaction_type, amount, remarks)
    VALUES (p_account_id, NULL, 'Withdrawal', p_amount, p_remarks);
END//

-- Transfer funds safely
CREATE PROCEDURE sp_transfer_funds(
    IN p_from_account_id INT,
    IN p_to_account_id INT,
    IN p_amount DECIMAL(15,2),
    IN p_remarks VARCHAR(255)
)
BEGIN
    DECLARE from_balance DECIMAL(15,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = p_from_account_id
    FOR UPDATE;

    IF p_amount <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer amount must be greater than zero';
    END IF;

    IF from_balance < p_amount THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance for transfer';
    END IF;

    INSERT INTO transactions(account_id, related_account_id, transaction_type, amount, remarks)
    VALUES (p_from_account_id, p_to_account_id, 'TransferOut', p_amount, p_remarks);

    INSERT INTO transactions(account_id, related_account_id, transaction_type, amount, remarks)
    VALUES (p_to_account_id, p_from_account_id, 'TransferIn', p_amount, p_remarks);

    COMMIT;
END//

-- Check balance
CREATE PROCEDURE sp_check_balance(
    IN p_account_id INT
)
BEGIN
    SELECT a.account_id, a.account_number, c.first_name, c.last_name, a.balance
    FROM accounts a
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE a.account_id = p_account_id;
END//

DELIMITER ;

-- =========================================================
-- 8) SAMPLE PROCEDURE CALLS
-- =========================================================

CALL sp_add_customer('Nitin', 'Patil', 'Male', '2001-09-10', '9876543214', 'nitin.patil@gmail.com', '88 Temple Road', 'Nashik', 'Maharashtra', '422001');
CALL sp_create_account(5, 'SBIN0001005', 'Current', 'Nashik Branch', 'SBIN0001238', '2024-08-01', 7000.00);
CALL sp_deposit_money(1, 2000.00, 'Cash deposit');
CALL sp_withdraw_money(2, 1500.00, 'ATM withdrawal');
CALL sp_transfer_funds(1, 3, 1000.00, 'Rent transfer');
CALL sp_check_balance(1);

-- =========================================================
-- 9) VIEWS
-- =========================================================

CREATE VIEW vw_customer_account_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone,
    c.email,
    a.account_id,
    a.account_number,
    a.account_type,
    a.balance,
    a.status
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id;

CREATE VIEW vw_transaction_report AS
SELECT
    t.transaction_id,
    t.account_id,
    a.account_number,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    t.remarks
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id;

-- =========================================================
-- 10) REPORT QUERIES
-- =========================================================

-- Total customers
SELECT COUNT(*) AS total_customers FROM customers;

-- Total accounts
SELECT COUNT(*) AS total_accounts FROM accounts;

-- Total deposits
SELECT COALESCE(SUM(amount), 0) AS total_deposits
FROM transactions
WHERE transaction_type = 'Deposit';

-- Total withdrawals
SELECT COALESCE(SUM(amount), 0) AS total_withdrawals
FROM transactions
WHERE transaction_type = 'Withdrawal';

-- Account balances
SELECT account_id, account_number, balance, status
FROM accounts;

-- Customer-wise account summary
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(a.account_id) AS total_accounts,
    COALESCE(SUM(a.balance), 0) AS total_balance
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- Transaction history for an account
SELECT *
FROM transactions
WHERE account_id = 1
ORDER BY transaction_date DESC;

-- Loan summary
SELECT
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.loan_type,
    l.principal_amount,
    l.interest_rate,
    l.tenure_months,
    l.status,
    l.outstanding_amount
FROM loans l
JOIN customers c ON l.customer_id = c.customer_id;

-- =========================================================
-- 11) TRANSACTION EXAMPLE
-- =========================================================

START TRANSACTION;

-- Example manual fund transfer logic
INSERT INTO transactions(account_id, related_account_id, transaction_type, amount, remarks)
VALUES (1, 3, 'TransferOut', 500.00, 'Manual transfer debit');

INSERT INTO transactions(account_id, related_account_id, transaction_type, amount, remarks)
VALUES (3, 1, 'TransferIn', 500.00, 'Manual transfer credit');

COMMIT;

-- If any step fails, use:
-- ROLLBACK;

-- =========================================================
-- END OF PROJECT
-- =========================================================
