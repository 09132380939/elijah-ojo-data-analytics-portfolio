-- Pharmacy Sales SQL Analysis (MySQL 8 / MariaDB 10.6+)
-- Run after 02_cleaning_pipeline.sql

-- ---------------------------------------------------------------------
-- 3. Reconciliation: every raw row must be accounted for
-- ---------------------------------------------------------------------
SELECT
    (SELECT COUNT(*) FROM pharmacy_sales.pharmacy_sales_raw)                AS raw_rows,
    (SELECT COUNT(DISTINCT sale_id) FROM pharmacy_sales.pharmacy_sales_raw) AS raw_unique_ids,
    (SELECT COUNT(*) FROM pharmacy_sales.pharmacy_sales_rejected)           AS rejected_rows,
    (SELECT COUNT(*) FROM pharmacy_sales.pharmacy_sales_clean)              AS clean_rows;

-- Any sale_id that is neither in the clean table nor the rejected table
SELECT DISTINCT r.sale_id
FROM pharmacy_sales.pharmacy_sales_raw r
LEFT JOIN pharmacy_sales.pharmacy_sales_clean c ON c.sale_id = r.sale_id
LEFT JOIN pharmacy_sales.pharmacy_sales_rejected x ON x.sale_id = r.sale_id
WHERE c.sale_id IS NULL AND x.sale_id IS NULL;

-- Quality checks on the clean table (expected: 14, 0, 0, 0)
SELECT
    COUNT(DISTINCT product_name)                             AS distinct_products,
    SUM(category IS NULL)                                    AS null_categories,
    SUM(total_amount <> quantity * unit_price)               AS total_mismatches,
    SUM(sale_date IS NULL)                                   AS null_dates
FROM pharmacy_sales.pharmacy_sales_clean;

-- Correction counts for the report
SELECT SUM(date_corrected) AS dates_remapped,
       SUM(price_corrected) AS prices_corrected,
       SUM(age_invalid) AS invalid_ages
FROM pharmacy_sales.pharmacy_sales_clean;
