-- =========================================================
-- LOAN APPROVAL & CREDIT MANAGEMENT MODULE
-- Extends: bank_management_system.sql
-- Reuses existing tables: customers, accounts, employees, loans
-- =========================================================

USE bank_management_system;

-- =========================================================
-- 1) NEW TABLES
-- =========================================================

-- ---------------------------------------------------------
-- Credit Scores: history of each customer's creditworthiness
-- ---------------------------------------------------------
CREATE TABLE credit_scores (
    score_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    credit_score INT NOT NULL,
    score_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    source VARCHAR(50) DEFAULT 'INTERNAL',        -- INTERNAL, CIBIL, EXPERIAN, etc.
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_score_range CHECK (credit_score BETWEEN 300 AND 900),
    CONSTRAINT fk_credit_scores_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Loan Applications: staging area BEFORE a row is created
-- in the existing `loans` table. Nothing touches `loans`
-- until an application is formally approved.
-- ---------------------------------------------------------
CREATE TABLE loan_applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_id INT NOT NULL,
    loan_type ENUM('Home','Personal','Education','Business','Car','Gold') NOT NULL,
    requested_amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    tenure_months INT NOT NULL,
    purpose VARCHAR(255),
    monthly_income DECIMAL(15,2),
    existing_emi DECIMAL(15,2) DEFAULT 0,
    application_status ENUM('Submitted','Under Review','Approved','Rejected') DEFAULT 'Submitted',
    applied_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    decided_on TIMESTAMP NULL,
    linked_loan_id INT NULL,                      -- filled in once moved to `loans`
    CONSTRAINT chk_requested_amount_positive CHECK (requested_amount > 0),
    CONSTRAINT fk_apps_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_apps_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_apps_loan
        FOREIGN KEY (linked_loan_id) REFERENCES loans(loan_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- ---------------------------------------------------------
-- Loan Eligibility Rules: per loan_type minimum requirements
-- (drives automatic checks instead of hardcoding thresholds)
-- ---------------------------------------------------------
CREATE TABLE loan_eligibility_rules (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_type ENUM('Home','Personal','Education','Business','Car','Gold') NOT NULL UNIQUE,
    min_credit_score INT NOT NULL DEFAULT 650,
    max_amount DECIMAL(15,2) NOT NULL,
    max_tenure_months INT NOT NULL,
    max_emi_to_income_ratio DECIMAL(4,2) NOT NULL DEFAULT 0.50   -- e.g. 0.50 = EMI can't exceed 50% of income
);

-- ---------------------------------------------------------
-- Loan Approvals: audit trail of who decided what, supports
-- multi-level approval (Clerk review -> Manager sign-off)
-- ---------------------------------------------------------
CREATE TABLE loan_approvals (
    approval_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    employee_id INT NOT NULL,
    approval_level INT NOT NULL DEFAULT 1,
    decision ENUM('Approved','Rejected','Escalated') NOT NULL,
    remarks VARCHAR(500),
    decided_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_approvals_application
        FOREIGN KEY (application_id) REFERENCES loan_applications(application_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_approvals_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ---------------------------------------------------------
-- Collateral / Guarantor details (optional, per application)
-- ---------------------------------------------------------
CREATE TABLE collaterals (
    collateral_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    asset_type VARCHAR(100) NOT NULL,             -- Property, Vehicle, Gold, FD, etc.
    description VARCHAR(255),
    estimated_value DECIMAL(15,2) NOT NULL,
    CONSTRAINT fk_collateral_application
        FOREIGN KEY (application_id) REFERENCES loan_applications(application_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Repayment Schedule: EMI-wise breakdown per approved loan
-- ---------------------------------------------------------
CREATE TABLE repayment_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    installment_no INT NOT NULL,
    due_date DATE NOT NULL,
    emi_amount DECIMAL(15,2) NOT NULL,
    principal_component DECIMAL(15,2) NOT NULL,
    interest_component DECIMAL(15,2) NOT NULL,
    status ENUM('Pending','Paid','Overdue') DEFAULT 'Pending',
    paid_on DATE NULL,
    CONSTRAINT fk_schedule_loan
        FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_loan_installment UNIQUE (loan_id, installment_no)
);

-- =========================================================
-- 2) INDEXES
-- =========================================================
CREATE INDEX idx_credit_scores_customer ON credit_scores(customer_id);
CREATE INDEX idx_apps_customer ON loan_applications(customer_id);
CREATE INDEX idx_apps_status ON loan_applications(application_status);
CREATE INDEX idx_approvals_application ON loan_approvals(application_id);
CREATE INDEX idx_schedule_loan ON repayment_schedule(loan_id);
CREATE INDEX idx_schedule_status ON repayment_schedule(status);

-- =========================================================
-- 3) SEED DATA: eligibility rules + sample credit scores
-- =========================================================
INSERT INTO loan_eligibility_rules (loan_type, min_credit_score, max_amount, max_tenure_months, max_emi_to_income_ratio)
VALUES
('Home', 700, 5000000.00, 240, 0.50),
('Personal', 650, 500000.00, 60, 0.40),
('Education', 600, 2000000.00, 120, 0.40),
('Business', 700, 3000000.00, 84, 0.50),
('Car', 650, 1500000.00, 84, 0.45),
('Gold', 600, 1000000.00, 36, 0.50);

INSERT INTO credit_scores (customer_id, credit_score, score_date, source)
VALUES
(1, 720, '2024-04-01', 'INTERNAL'),
(2, 610, '2024-05-01', 'INTERNAL'),
(3, 680, '2024-06-01', 'INTERNAL'),
(4, 750, '2024-07-01', 'INTERNAL');

-- =========================================================
-- 4) VIEWS
-- =========================================================

-- Latest credit score per customer
CREATE VIEW vw_latest_credit_score AS
SELECT cs.customer_id, cs.credit_score, cs.score_date
FROM credit_scores cs
INNER JOIN (
    SELECT customer_id, MAX(score_date) AS max_date
    FROM credit_scores
    GROUP BY customer_id
) latest ON cs.customer_id = latest.customer_id AND cs.score_date = latest.max_date;

-- Full application pipeline view
CREATE VIEW vw_application_pipeline AS
SELECT
    la.application_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    la.loan_type,
    la.requested_amount,
    la.tenure_months,
    la.application_status,
    lcs.credit_score,
    la.applied_on,
    la.decided_on
FROM loan_applications la
JOIN customers c ON la.customer_id = c.customer_id
LEFT JOIN vw_latest_credit_score lcs ON la.customer_id = lcs.customer_id;

-- Approval audit trail with employee names
CREATE VIEW vw_approval_trail AS
SELECT
    ap.approval_id,
    ap.application_id,
    e.full_name AS approved_by,
    e.designation,
    ap.approval_level,
    ap.decision,
    ap.remarks,
    ap.decided_on
FROM loan_approvals ap
JOIN employees e ON ap.employee_id = e.employee_id
ORDER BY ap.application_id, ap.approval_level;

-- Upcoming / overdue EMIs
CREATE VIEW vw_repayment_status AS
SELECT
    rs.schedule_id,
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    rs.installment_no,
    rs.due_date,
    rs.emi_amount,
    rs.status
FROM repayment_schedule rs
JOIN loans l ON rs.loan_id = l.loan_id
JOIN customers c ON l.customer_id = c.customer_id;

-- =========================================================
-- 5) STORED PROCEDURES
-- =========================================================
DELIMITER //

-- -----------------------------------------------------------
-- sp_apply_loan: customer submits a new loan application
-- -----------------------------------------------------------
CREATE PROCEDURE sp_apply_loan(
    IN p_customer_id INT,
    IN p_account_id INT,
    IN p_loan_type ENUM('Home','Personal','Education','Business','Car','Gold'),
    IN p_requested_amount DECIMAL(15,2),
    IN p_interest_rate DECIMAL(5,2),
    IN p_tenure_months INT,
    IN p_purpose VARCHAR(255),
    IN p_monthly_income DECIMAL(15,2),
    IN p_existing_emi DECIMAL(15,2)
)
BEGIN
    INSERT INTO loan_applications
        (customer_id, account_id, loan_type, requested_amount, interest_rate,
         tenure_months, purpose, monthly_income, existing_emi, application_status)
    VALUES
        (p_customer_id, p_account_id, p_loan_type, p_requested_amount, p_interest_rate,
         p_tenure_months, p_purpose, p_monthly_income, p_existing_emi, 'Submitted');

    SELECT LAST_INSERT_ID() AS new_application_id;
END//

-- -----------------------------------------------------------
-- sp_evaluate_application: automated eligibility pre-check.
-- Moves status to 'Under Review' if it passes basic rules,
-- or straight to 'Rejected' if it clearly fails.
-- Does NOT grant final approval - that always needs a human
-- decision recorded via sp_decide_application.
-- -----------------------------------------------------------
CREATE PROCEDURE sp_evaluate_application(
    IN p_application_id INT
)
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_loan_type VARCHAR(20);
    DECLARE v_requested_amount DECIMAL(15,2);
    DECLARE v_tenure_months INT;
    DECLARE v_monthly_income DECIMAL(15,2);
    DECLARE v_existing_emi DECIMAL(15,2);
    DECLARE v_interest_rate DECIMAL(5,2);
    DECLARE v_credit_score INT;
    DECLARE v_min_score INT;
    DECLARE v_max_amount DECIMAL(15,2);
    DECLARE v_max_tenure INT;
    DECLARE v_max_ratio DECIMAL(4,2);
    DECLARE v_emi DECIMAL(15,2);
    DECLARE v_reason VARCHAR(255) DEFAULT '';

    SELECT customer_id, loan_type, requested_amount, tenure_months,
           monthly_income, existing_emi, interest_rate
    INTO v_customer_id, v_loan_type, v_requested_amount, v_tenure_months,
         v_monthly_income, v_existing_emi, v_interest_rate
    FROM loan_applications
    WHERE application_id = p_application_id;

    SELECT credit_score INTO v_credit_score
    FROM vw_latest_credit_score
    WHERE customer_id = v_customer_id
    LIMIT 1;

    SELECT min_credit_score, max_amount, max_tenure_months, max_emi_to_income_ratio
    INTO v_min_score, v_max_amount, v_max_tenure, v_max_ratio
    FROM loan_eligibility_rules
    WHERE loan_type = v_loan_type;

    -- Approximate flat EMI just for the ratio check
    SET v_emi = (v_requested_amount + (v_requested_amount * v_interest_rate / 100 * v_tenure_months / 12)) / v_tenure_months;

    IF v_credit_score IS NULL THEN
        SET v_reason = 'No credit score on record';
    ELSEIF v_credit_score < v_min_score THEN
        SET v_reason = CONCAT('Credit score ', v_credit_score, ' below minimum ', v_min_score);
    ELSEIF v_requested_amount > v_max_amount THEN
        SET v_reason = CONCAT('Requested amount exceeds max limit of ', v_max_amount);
    ELSEIF v_tenure_months > v_max_tenure THEN
        SET v_reason = CONCAT('Tenure exceeds max allowed of ', v_max_tenure, ' months');
    ELSEIF v_monthly_income IS NULL OR v_monthly_income = 0 THEN
        SET v_reason = 'Monthly income not provided';
    ELSEIF (v_emi + v_existing_emi) / v_monthly_income > v_max_ratio THEN
        SET v_reason = 'EMI-to-income ratio exceeds allowed limit';
    END IF;

    IF v_reason = '' THEN
        UPDATE loan_applications
        SET application_status = 'Under Review'
        WHERE application_id = p_application_id;

        SELECT 'PASSED_PRECHECK' AS result, 'Eligible for manual review' AS message;
    ELSE
        UPDATE loan_applications
        SET application_status = 'Rejected', decided_on = CURRENT_TIMESTAMP
        WHERE application_id = p_application_id;

        INSERT INTO loan_approvals (application_id, employee_id, approval_level, decision, remarks)
        VALUES (p_application_id, 1, 0, 'Rejected', CONCAT('Auto-rejected: ', v_reason));

        SELECT 'FAILED_PRECHECK' AS result, v_reason AS message;
    END IF;
END//

-- -----------------------------------------------------------
-- sp_decide_application: an employee records Approve/Reject/
-- Escalate for an application that is 'Under Review'.
-- On final Approved decision, this creates the row in `loans`,
-- generates the full EMI repayment schedule, and links back.
-- -----------------------------------------------------------
CREATE PROCEDURE sp_decide_application(
    IN p_application_id INT,
    IN p_employee_id INT,
    IN p_approval_level INT,
    IN p_decision ENUM('Approved','Rejected','Escalated'),
    IN p_remarks VARCHAR(500)
)
BEGIN
    DECLARE v_customer_id INT;
    DECLARE v_account_id INT;
    DECLARE v_loan_type VARCHAR(20);
    DECLARE v_amount DECIMAL(15,2);
    DECLARE v_rate DECIMAL(5,2);
    DECLARE v_tenure INT;
    DECLARE v_new_loan_id INT;
    DECLARE v_i INT DEFAULT 1;
    DECLARE v_monthly_rate DECIMAL(10,6);
    DECLARE v_emi DECIMAL(15,2);
    DECLARE v_balance DECIMAL(15,2);
    DECLARE v_interest_part DECIMAL(15,2);
    DECLARE v_principal_part DECIMAL(15,2);
    DECLARE v_due_date DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO loan_approvals (application_id, employee_id, approval_level, decision, remarks)
    VALUES (p_application_id, p_employee_id, p_approval_level, p_decision, p_remarks);

    IF p_decision = 'Rejected' THEN
        UPDATE loan_applications
        SET application_status = 'Rejected', decided_on = CURRENT_TIMESTAMP
        WHERE application_id = p_application_id;

    ELSEIF p_decision = 'Escalated' THEN
        -- stays 'Under Review', just logged for next-level approver
        SELECT 'ESCALATED' AS result;

    ELSEIF p_decision = 'Approved' THEN
        SELECT customer_id, account_id, loan_type, requested_amount, interest_rate, tenure_months
        INTO v_customer_id, v_account_id, v_loan_type, v_amount, v_rate, v_tenure
        FROM loan_applications
        WHERE application_id = p_application_id
        FOR UPDATE;

        -- Create the actual loan record in the existing loans table
        INSERT INTO loans
            (customer_id, account_id, loan_type, principal_amount, interest_rate,
             tenure_months, start_date, status, outstanding_amount, remarks)
        VALUES
            (v_customer_id, v_account_id, v_loan_type, v_amount, v_rate,
             v_tenure, CURRENT_DATE, 'Approved', v_amount, CONCAT('Approved via application #', p_application_id));

        SET v_new_loan_id = LAST_INSERT_ID();

        UPDATE loan_applications
        SET application_status = 'Approved',
            decided_on = CURRENT_TIMESTAMP,
            linked_loan_id = v_new_loan_id
        WHERE application_id = p_application_id;

        -- Generate flat-rate EMI schedule
        SET v_monthly_rate = v_rate / 12 / 100;
        SET v_emi = ROUND((v_amount + (v_amount * v_rate / 100 * v_tenure / 12)) / v_tenure, 2);
        SET v_balance = v_amount;
        SET v_i = 1;

        WHILE v_i <= v_tenure DO
            SET v_interest_part = ROUND(v_balance * v_monthly_rate, 2);
            SET v_principal_part = v_emi - v_interest_part;
            SET v_due_date = DATE_ADD(CURRENT_DATE, INTERVAL v_i MONTH);

            INSERT INTO repayment_schedule
                (loan_id, installment_no, due_date, emi_amount, principal_component, interest_component, status)
            VALUES
                (v_new_loan_id, v_i, v_due_date, v_emi, v_principal_part, v_interest_part, 'Pending');

            SET v_balance = v_balance - v_principal_part;
            SET v_i = v_i + 1;
        END WHILE;

        SELECT 'APPROVED' AS result, v_new_loan_id AS loan_id, v_emi AS monthly_emi;
    END IF;

    COMMIT;
END//

-- -----------------------------------------------------------
-- sp_record_emi_payment: mark an EMI as paid and log it as
-- a transaction against the customer's account
-- -----------------------------------------------------------
CREATE PROCEDURE sp_record_emi_payment(
    IN p_schedule_id INT
)
BEGIN
    DECLARE v_loan_id INT;
    DECLARE v_account_id INT;
    DECLARE v_emi DECIMAL(15,2);
    DECLARE v_installment_no INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT rs.loan_id, l.account_id, rs.emi_amount, rs.installment_no
    INTO v_loan_id, v_account_id, v_emi, v_installment_no
    FROM repayment_schedule rs
    JOIN loans l ON rs.loan_id = l.loan_id
    WHERE rs.schedule_id = p_schedule_id
    FOR UPDATE;

    UPDATE repayment_schedule
    SET status = 'Paid', paid_on = CURRENT_DATE
    WHERE schedule_id = p_schedule_id;

    INSERT INTO transactions (account_id, related_account_id, transaction_type, amount, remarks)
    VALUES (v_account_id, NULL, 'Withdrawal', v_emi, CONCAT('EMI payment - loan #', v_loan_id, ' installment ', v_installment_no));

    UPDATE loans
    SET outstanding_amount = outstanding_amount - (v_emi -
        (SELECT interest_component FROM repayment_schedule WHERE schedule_id = p_schedule_id))
    WHERE loan_id = v_loan_id;

    -- Close the loan automatically once fully repaid
    UPDATE loans
    SET status = 'Closed'
    WHERE loan_id = v_loan_id
      AND NOT EXISTS (
          SELECT 1 FROM repayment_schedule
          WHERE loan_id = v_loan_id AND status <> 'Paid'
      );

    COMMIT;
END//

DELIMITER ;

-- =========================================================
-- 6) EVENT: mark overdue EMIs daily (optional, needs
--    event_scheduler = ON at the server level)
-- =========================================================
-- SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE EVENT IF NOT EXISTS ev_flag_overdue_emis
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE repayment_schedule
    SET status = 'Overdue'
    WHERE status = 'Pending' AND due_date < CURRENT_DATE;
END//
DELIMITER ;

-- =========================================================
-- 7) SAMPLE END-TO-END WALKTHROUGH
-- =========================================================
-- 1. Customer 3 (Rahul, credit score 680) applies for a Car loan
CALL sp_apply_loan(3, 3, 'Car', 400000.00, 9.50, 48, 'New car purchase', 45000.00, 5000.00);

-- 2. System runs the automated pre-check (assume application_id = 1)
CALL sp_evaluate_application(1);

-- 3. Manager (employee_id = 1) makes the final call
CALL sp_decide_application(1, 1, 1, 'Approved', 'Meets all criteria, approved');

-- 4. Check generated EMI schedule
SELECT * FROM repayment_schedule WHERE loan_id = (
    SELECT linked_loan_id FROM loan_applications WHERE application_id = 1
);

-- 5. Customer pays the first EMI
-- CALL sp_record_emi_payment(1);

-- =========================================================
-- END OF LOAN APPROVAL & CREDIT MANAGEMENT MODULE
-- =========================================================