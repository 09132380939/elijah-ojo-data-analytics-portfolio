-- Pharmacy Sales SQL Analysis (MySQL 8 / MariaDB 10.6+)
-- ---------------------------------------------------------------------
-- 5. Clinical plausibility audit (product-level rules, valid ages only)
-- ---------------------------------------------------------------------
WITH flagged AS (
    SELECT sale_id, branch, product_name, customer_age, total_amount,
        CASE
            WHEN product_name IN ('Lisinopril 10mg', 'Amlodipine 5mg') AND customer_age < 18
                THEN 'Antihypertensive for a minor (<18)'
            WHEN product_name = 'Metformin 500mg' AND customer_age < 10
                THEN 'Metformin for a child (<10)'
            WHEN product_name = 'Ciprofloxacin 500mg' AND customer_age < 18
                THEN 'Fluoroquinolone for a minor (<18)'
            WHEN product_name = 'Loratadine 10mg' AND customer_age < 2
                THEN 'Loratadine under 2 years'
        END AS clinical_flag
    FROM pharmacy_sales.pharmacy_sales_clean
    WHERE age_invalid = 0
)
SELECT clinical_flag, product_name,
       COUNT(*) AS violation_count,
       SUM(total_amount) AS flagged_revenue
FROM flagged
WHERE clinical_flag IS NOT NULL
GROUP BY clinical_flag, product_name
ORDER BY violation_count DESC;
