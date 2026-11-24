-- Pharmacy Sales SQL Analysis (MySQL 8 / MariaDB 10.6+)
-- Step 1: create the database and the raw table, then load data/pharmacy_sales_raw.csv

CREATE DATABASE IF NOT EXISTS pharmacy_sales;
USE pharmacy_sales;

DROP TABLE IF EXISTS pharmacy_sales_raw;
CREATE TABLE pharmacy_sales_raw (
    sale_id        INT,
    sale_date      VARCHAR(20),   -- text on purpose: the raw file has mixed and invalid date formats
    branch         VARCHAR(50),
    product_name   VARCHAR(100),
    category       VARCHAR(50),
    quantity       INT,
    unit_price     INT,
    total_amount   INT,
    payment_method VARCHAR(30),
    customer_age   INT NULL
);

-- Option A: command line (start the client with: mysql --local-infile=1 -u root -p)
-- Blank fields are loaded as NULL. Adjust the file path to where you cloned the repo.
-- If your file uses Unix line endings, change '\r\n' to '\n'.
LOAD DATA LOCAL INFILE 'data/pharmacy_sales_raw.csv'
INTO TABLE pharmacy_sales_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(sale_id, sale_date, branch, product_name, @category, quantity, unit_price, total_amount, @payment_method, @customer_age)
SET category = NULLIF(@category, ''),
    payment_method = NULLIF(@payment_method, ''),
    customer_age = NULLIF(@customer_age, '');

-- Option B: MySQL Workbench > right-click the table > Table Data Import Wizard.
-- Make sure sale_date stays text, otherwise bad dates will be rejected or altered.

SELECT COUNT(*) AS rows_loaded FROM pharmacy_sales_raw;  -- expected: 1525
