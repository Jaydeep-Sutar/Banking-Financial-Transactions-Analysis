USE bank_analysis;

CREATE TABLE transactions_staging (
    transaction_id VARCHAR(30),
    transaction_date VARCHAR(30),
    account_id VARCHAR(30),
    customer_id VARCHAR(20),
    transaction_type VARCHAR(50),
    channel VARCHAR(50),
    merchant_category VARCHAR(50),
    amount VARCHAR(30),
    fee_amount VARCHAR(30),
    tax_amount VARCHAR(30),
    currency VARCHAR(10),
    transaction_status VARCHAR(30),
    is_fraud VARCHAR(10),
    risk_score VARCHAR(30),	
    reference_no VARCHAR(50)
);

desc transactions_staging;
rename table transactions_staging to trans;
select *from trans limit 50;
select count(*) as total_trancation from trans;

SELECT
    transaction_date,
    amount,
    fee_amount,
    tax_amount,
    currency,
    transaction_status,
    is_fraud
FROM trans
LIMIT 10;


#Check the total transaction count
select count(*) as total_transactions from trans;

#Check missing values in transaction data
select count(*) as total_transaction,
sum(transaction_id is null) as missing_transactionid,
sum(transaction_date is null) as missing_trans_date,
sum(account_id is null) as missing_accountid,
sum(customer_id is null) as missing_customerid,
sum(amount is null) as missing_amount,
sum(fee_amount is null) as missing_feeamount,
sum(tax_amount is null) as missing_tax_amount,
sum(currency is null) as missing_currency,
sum(transaction_status is null) as missing_trans_status
from trans;

#Check blank fee amounts
select count(*) as blank_fee_amt
from trans where trim(fee_amount)='';

#Check duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM trans
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

#Check missing and blank values in all columns
SELECT
    transaction_id,
    transaction_date,
    transaction_type,
    amount,
    fee_amount,
    tax_amount,
    transaction_status
FROM trans
WHERE TRIM(fee_amount) = '';


#Identify exact duplicate transactions
SELECT
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
    reference_no,
    COUNT(*) AS duplicate_count
FROM trans
GROUP BY
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
HAVING COUNT(*) > 1;


#Check negative transaction amounts
SELECT
    transaction_id,
    transaction_date,
    transaction_type,
    amount,
    transaction_status,
    reference_no
FROM trans
WHERE CAST(amount AS DECIMAL(12,2)) < 0;

#Check inconsistent currency values
select distinct currency from trans order by currency;

#Check inconsistent transaction channels
SELECT DISTINCT
    channel
FROM trans
ORDER BY channel;

#Check transaction types
SELECT DISTINCT transaction_type
FROM trans
ORDER BY transaction_type;

#Check merchant categories
select distinct merchant_category from trans order by merchant_category;

#Check transaction status values
select distinct transaction_status from trans order by transaction_status;

#Check fraud indicator values
select distinct is_fraud from trans order by is_fraud;

#Check risk score values
SELECT DISTINCT
    risk_score
FROM trans
ORDER BY risk_score;

#Check tax amounts
SELECT
    COUNT(*) AS total_records,
    SUM(CAST(tax_amount AS DECIMAL(12,2)) < 0) AS negative_tax,
    MIN(CAST(tax_amount AS DECIMAL(12,2))) AS minimum_tax,
    MAX(CAST(tax_amount AS DECIMAL(12,2))) AS maximum_tax
FROM trans;

#Check transaction status values
SELECT
    transaction_status,
    COUNT(*) AS total_transactions
FROM trans
GROUP BY transaction_status
ORDER BY total_transactions DESC;

#Check fraud indicator distribution
SELECT
    is_fraud,
    COUNT(*) AS total_transactions
FROM trans
GROUP BY is_fraud
ORDER BY total_transactions DESC;

#Check risk score distribution
SELECT
    risk_score,
    COUNT(*) AS total_transactions
FROM trans
GROUP BY risk_score
ORDER BY risk_score;

#Check reference number quality
SELECT
    COUNT(*) AS total_transactions,
    SUM(reference_no IS NULL OR TRIM(reference_no) = '') AS missing_reference_no
FROM trans;

SELECT
    reference_no,
    COUNT(*) AS reference_count
FROM trans
WHERE TRIM(reference_no) <> ''
GROUP BY reference_no
HAVING COUNT(*) > 1
ORDER BY reference_count DESC;

SELECT
    transaction_id,
    transaction_date
FROM trans
WHERE STR_TO_DATE(transaction_date, '%d-%m-%y') > CURDATE();