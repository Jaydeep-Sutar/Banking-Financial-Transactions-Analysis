use bank_analysis;
CREATE TABLE transactions (
    transaction_id VARCHAR(30),
    transaction_date DATE,
    account_id VARCHAR(30),
    customer_id VARCHAR(20),
    transaction_type VARCHAR(50),
    channel VARCHAR(50),
    merchant_category VARCHAR(50),
    amount DECIMAL(15,2),
    fee_amount DECIMAL(15,2),
    tax_amount DECIMAL(15,2),
    currency VARCHAR(10),
    transaction_status VARCHAR(30),
    is_fraud VARCHAR(10),
    risk_score INT,
    reference_no VARCHAR(50)
);


INSERT INTO transactions (
    transaction_id,
    transaction_date,
    account_id,
    customer_id,
    transaction_type,
    channel,
    merchant_category,
    amount,
    fee_amount,
    tax_amount,
    currency,
    transaction_status,
    is_fraud,
    risk_score,
    reference_no
)
SELECT
    transaction_id,
    STR_TO_DATE(transaction_date, '%d-%m-%y'),
    account_id,
    customer_id,
    transaction_type,
    channel,
    merchant_category,
    CAST(amount AS DECIMAL(15,2)),
    CAST(NULLIF(TRIM(fee_amount), '') AS DECIMAL(15,2)),
    CAST(tax_amount AS DECIMAL(15,2)),
    currency,
    transaction_status,
    is_fraud,
    CAST(risk_score AS UNSIGNED),
    reference_no
FROM trans_clean;

SELECT COUNT(*) AS total_records
FROM transactions;

#Validate missing fee amounts
SELECT
    COUNT(*) AS total_records,
    SUM(fee_amount IS NULL) AS missing_fee_values
FROM transactions;

#Verify the final table's data types
DESCRIBE transactions;

#Final data-quality check
SELECT
    COUNT(*) AS total_records,
    SUM(transaction_id IS NULL OR TRIM(transaction_id) = '') AS missing_transaction_ids,
    SUM(transaction_date IS NULL) AS missing_dates,
    SUM(customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_ids,
    SUM(amount IS NULL) AS missing_amounts,
    SUM(fee_amount IS NULL) AS missing_fees,
    SUM(tax_amount IS NULL) AS missing_taxes,
    SUM(reference_no IS NULL OR TRIM(reference_no) = '') AS missing_references
FROM transactions;

SELECT COUNT(*) AS duplicate_id_groups
FROM (
    SELECT transaction_id
    FROM transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
) AS duplicates;

SELECT COUNT(*) AS total_customers
FROM customers;

#Check customer ID uniqueness
SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids
FROM customers;


SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT t.customer_id) AS customers_with_transactions,
    COUNT(*) - COUNT(DISTINCT t.customer_id) AS customers_without_transactions
FROM customers c
LEFT JOIN transactions t
    ON c.customer_id = t.customer_id;
    
    
SELECT
    COUNT(*) AS total_customers,
    SUM(
        EXISTS (
            SELECT 1
            FROM transactions t
            WHERE t.customer_id = c.customer_id
        )
    ) AS customers_with_transactions,
    SUM(
        NOT EXISTS (
            SELECT 1
            FROM transactions t
            WHERE t.customer_id = c.customer_id
        )
    ) AS customers_without_transactions
FROM customers c;