CREATE TABLE trans_clean AS
SELECT *
FROM trans;

SELECT COUNT(*) AS total_records
FROM trans_clean;

SELECT DISTINCT currency
FROM trans_clean
ORDER BY currency;

#Standardize currency values
update trans_clean 
set currency= upper(trim(currency));

SET SQL_SAFE_UPDATES = 1;

#Standardize the channel column
SET SQL_SAFE_UPDATES = 0;

UPDATE trans_clean
SET channel = UPPER(TRIM(channel));
SELECT DISTINCT channel
FROM trans_clean
ORDER BY channel;

UPDATE trans_clean
SET channel = 'MOBILE APP'
WHERE channel = 'M@BILE APP';


#Clean the transaction_type column
select distinct transaction_type from trans_clean;

UPDATE trans_clean
SET transaction_type = UPPER(TRIM(transaction_type));

#Clean the merchant_category column
select distinct merchant_category from trans_clean;

update trans_clean set merchant_category=upper(trim(merchant_category));

#Clean the transaction_status column
select distinct transaction_status from trans_clean;

update trans_clean set transaction_status=upper(trim(transaction_status));

#Clean the is_fraud column
UPDATE trans_clean
SET is_fraud = UPPER(TRIM(is_fraud));

#Check and clean the reference_no column
UPDATE trans_clean
SET reference_no = TRIM(reference_no);

SELECT DISTINCT reference_no
FROM trans_clean
LIMIT 20;

#Investigate the 24 blank fee amounts
SELECT
    transaction_id,
    transaction_type,
    channel,
    amount,
    fee_amount,
    tax_amount,
    transaction_status
FROM trans_clean
WHERE TRIM(fee_amount) = '';

SELECT
    transaction_type,
    channel,
    COUNT(*) AS total_transactions,
    SUM(TRIM(fee_amount) = '') AS missing_fees,
    ROUND(
        AVG(
            CASE
                WHEN TRIM(fee_amount) <> ''
                THEN CAST(fee_amount AS DECIMAL(12,2))
            END
        ), 2
    ) AS average_fee
FROM trans_clean
GROUP BY transaction_type, channel
HAVING missing_fees > 0
ORDER BY missing_fees DESC;

SELECT
    transaction_status,
    COUNT(*) AS total_transactions,
    SUM(TRIM(fee_amount) = '') AS missing_fees,
    ROUND(
        SUM(TRIM(fee_amount) = '') * 100.0 / COUNT(*), 2
    ) AS missing_fee_percentage
FROM trans_clean
GROUP BY transaction_status
ORDER BY missing_fees DESC;

SELECT COUNT(*) AS exact_duplicate_groups
FROM (
    SELECT transaction_id
    FROM trans_clean
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
    HAVING COUNT(*) > 1
) AS duplicates;

#Find the total number of extra duplicate rows
SELECT
    SUM(duplicate_count - 1) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM trans_clean
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
    HAVING COUNT(*) > 1
) AS duplicates;

#Investigate duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS occurrences,
    COUNT(DISTINCT amount) AS different_amounts,
    COUNT(DISTINCT transaction_date) AS different_dates,
    COUNT(DISTINCT customer_id) AS different_customers
FROM trans_clean
GROUP BY transaction_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

#Remove confirmed exact duplicates
ALTER TABLE trans_clean
ADD COLUMN row_id BIGINT AUTO_INCREMENT PRIMARY KEY;

SELECT COUNT(*) AS total_records
FROM trans_clean;



#Delete extra duplicate records
SET SQL_SAFE_UPDATES = 0;
DELETE t1
FROM trans_clean t1
JOIN trans_clean t2
    ON t1.transaction_id = t2.transaction_id
    AND t1.row_id > t2.row_id;
 use bank_analysis;   
SELECT COUNT(*) AS total_records
FROM trans_clean;