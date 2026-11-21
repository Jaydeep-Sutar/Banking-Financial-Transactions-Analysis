
USE bank_analysis;

CREATE TABLE customers_staging (
    customer_id VARCHAR(20),
    fisrt_name VARCHAR(50),
    second_name VARCHAR(50),
    gender VARCHAR(20),
    date_of_birth VARCHAR(30),
    city VARCHAR(50),
    state VARCHAR(50),
    occupation VARCHAR(50),
    customer_segment VARCHAR(30),
    annual_income VARCHAR(30),
    join_date VARCHAR(30)
);
show tables;

select count(*) as Total_customers from customers_staging;
select *from customers_staging;
select *from customers_staging limit 10;
select max(annual_income) from customers_staging;

select date_of_birth, join_date from customers_staging;

INSERT INTO customers (
    customer_id,
    fisrt_name,
    second_name,
    gender,
    date_of_birth,
    city,
    state,
    occupation,
    customer_segment,
    annual_income,
    join_date
)
SELECT
    customer_id,
    fisrt_name,
    second_name,
    gender,
    STR_TO_DATE(date_of_birth, '%d-%m-%Y'),
    city,
    state,
    occupation,
    customer_segment,
    CAST(annual_income AS DECIMAL(12,2)),
    STR_TO_DATE(join_date, '%d-%m-%Y')
FROM customers_staging;

select *from customers;
select count(*) from customers;

select count(*) as total_cust,
sum(customer_id is null) as missing_cust,
sum(gender is null) as missing_gender,
sum(city is null) as missing_city,
sum(annual_income is null) as missing_income,
sum(date_of_birth is null) as missing_dob,
sum(join_date is null) as missing_join_date
from customers;

select customer_id, count(*)as duplicate_cust from customers group by customer_id having count(*)>1; 

select *from customers limit 1;
select distinct gender from customers order by gender;

SELECT
    COUNT(*) AS total_customers,
    SUM(annual_income = 0) AS zero_income,
    SUM(annual_income < 0) AS negative_income
FROM customers;

select annual_income from customers;
select annual_income from customers where annual_income=0 and annual_income < 0 ;

SELECT *
FROM customers
WHERE date_of_birth > CURDATE();

SELECT *
FROM customers
WHERE join_date > CURDATE();

SELECT
    customer_id,
    fisrt_name,
    date_of_birth,
    TIMESTAMPDIFF(year, date_of_birth, CURDATE()) AS age
FROM customers ;

SELECT
    MIN(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS youngest_age,
    MAX(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS oldest_age,
    AVG(TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE())) AS average_age
FROM customers;

SELECT
    gender,
    COUNT(*) AS total_customers
FROM customers
GROUP BY gender
ORDER BY total_customers DESC;

select 
customer_segment,
count(*) from customers group by customer_segment order by customer_segment;

#Analyze customers by state
select state , count(*) from customers group by state order by state;

select count(distinct(state)) from customers;

#Analyze customers by occupation
select occupation ,count(*)as count from customers group by occupation order by occupation;

#Analyze average annual income by customer segment 
SELECT
    customer_segment,
    COUNT(*) AS total_customers,
    ROUND(AVG(annual_income), 2) AS average_income
FROM customers
GROUP BY customer_segment
ORDER BY average_income DESC;

#Analyze average annual income by occupation
select occupation,count(*), 
round(avg(annual_income),2) as avg_income ,
max(annual_income) as maximum_income,
min(annual_income) as minimum_income 
from customers
group by occupation 
order by avg_income desc;

#Analyze customer registrations by year
select year(join_date) , count(*) as total_customers
from customers group by year(join_date) order by total_customers desc;

#analyse customers by city
select city, count(*) as total_customers from customers group by city order by total_customers desc;

#Analyze average annual income by state
select state, count(*) as total_cust,
round(avg(annual_income),2) as avg_income 
from customers 
group by state order by avg_income desc;

#Analyze customer distribution by gender and segment
select customer_segment,gender,count(*) as total_cust 
from customers 
group by  customer_segment,gender 
order by  customer_segment,total_cust desc;

#Analyze customer income by gender
select gender , count(*) as total_cust, 
avg(annual_income) as avg_income, 
max(annual_income) as maximum_income,
min(annual_income) as minimum_income 
from customers group by gender order by avg_income desc; 





