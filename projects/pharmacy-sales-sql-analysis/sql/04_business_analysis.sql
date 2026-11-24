-- Pharmacy Sales SQL Analysis (MySQL 8 / MariaDB 10.6+)
-- ---------------------------------------------------------------------
-- 4. Business analysis
-- ---------------------------------------------------------------------
-- 4.1 Branch performance
SELECT branch,
       COUNT(*) AS total_transactions,
       SUM(total_amount) AS total_revenue,
       ROUND(AVG(total_amount), 2) AS average_order_value
FROM pharmacy_sales.pharmacy_sales_clean
GROUP BY branch
ORDER BY total_revenue DESC;

-- 4.2 Payment mix
SELECT payment_method,
       COUNT(*) AS transaction_count,
       SUM(total_amount) AS total_revenue,
       ROUND(SUM(total_amount) * 100.0 / SUM(SUM(total_amount)) OVER (), 2) AS revenue_share_pct
FROM pharmacy_sales.pharmacy_sales_clean
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 4.3 Top category per month
WITH monthly AS (
    SELECT DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
           category,
           SUM(total_amount) AS total_revenue,
           ROW_NUMBER() OVER (PARTITION BY DATE_FORMAT(sale_date, '%Y-%m')
                              ORDER BY SUM(total_amount) DESC) AS rnk
    FROM pharmacy_sales.pharmacy_sales_clean
    GROUP BY sale_month, category
)
SELECT sale_month, category, total_revenue
FROM monthly
WHERE rnk = 1
ORDER BY sale_month;
