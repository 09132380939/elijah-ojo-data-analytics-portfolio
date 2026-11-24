-- Pharmacy Sales SQL Analysis (MySQL 8 / MariaDB 10.6+)
-- ---------------------------------------------------------------------
-- 1. Rejected rows: kept for audit instead of silently dropped
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS pharmacy_sales.pharmacy_sales_rejected;
CREATE TABLE pharmacy_sales.pharmacy_sales_rejected AS
SELECT DISTINCT r.*, 'Zero or negative quantity' AS reject_reason
FROM pharmacy_sales.pharmacy_sales_raw r
WHERE r.quantity <= 0;

-- ---------------------------------------------------------------------
-- 2. Clean table
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS pharmacy_sales.pharmacy_sales_clean;
CREATE TABLE pharmacy_sales.pharmacy_sales_clean AS
WITH dedup AS (
    -- Duplicates are exact copies, so any one row per sale_id is safe to keep
    SELECT r.*,
           ROW_NUMBER() OVER (PARTITION BY sale_id ORDER BY sale_id) AS rn
    FROM pharmacy_sales.pharmacy_sales_raw r
    WHERE r.quantity > 0
),
standardised AS (
    SELECT
        sale_id,
        -- Dates: parse by pattern. The two impossible dates are remapped by
        -- assumption (see report) and flagged so they stay traceable.
        CASE
            WHEN sale_date = '2026-13-05' THEN STR_TO_DATE('2025-05-13', '%Y-%m-%d')
            WHEN sale_date = '2025-02-30' THEN STR_TO_DATE('2025-02-28', '%Y-%m-%d')
            WHEN sale_date LIKE '____-__-__' THEN STR_TO_DATE(sale_date, '%Y-%m-%d')
            WHEN sale_date LIKE '____/__/__' THEN STR_TO_DATE(sale_date, '%Y/%m/%d')
            WHEN sale_date LIKE '__/__/____' THEN STR_TO_DATE(sale_date, '%d/%m/%Y')
            ELSE NULL
        END AS sale_date,
        CASE WHEN sale_date IN ('2026-13-05', '2025-02-30') THEN 1 ELSE 0 END AS date_corrected,
        CONCAT(UPPER(LEFT(TRIM(branch), 1)), LOWER(SUBSTRING(TRIM(branch), 2))) AS branch,
        -- Product names: collapse spelling, spacing and casing variants
        CASE LOWER(REPLACE(TRIM(product_name), ' ', ''))
            WHEN 'paracetamol500mg'        THEN 'Paracetamol 500mg'
            WHEN 'ibuprofen400mg'          THEN 'Ibuprofen 400mg'
            WHEN 'amoxicillin500mg'        THEN 'Amoxicillin 500mg'
            WHEN 'amoxycillin500mg'        THEN 'Amoxicillin 500mg'
            WHEN 'ciprofloxacin500mg'      THEN 'Ciprofloxacin 500mg'
            WHEN 'artemether/lumefantrine' THEN 'Artemether/Lumefantrine'
            WHEN 'metformin500mg'          THEN 'Metformin 500mg'
            WHEN 'amlodipine5mg'           THEN 'Amlodipine 5mg'
            WHEN 'lisinopril10mg'          THEN 'Lisinopril 10mg'
            WHEN 'loratadine10mg'          THEN 'Loratadine 10mg'
            WHEN 'omeprazole20mg'          THEN 'Omeprazole 20mg'
            WHEN 'vitaminc1000mg'          THEN 'Vitamin C 1000mg'
            WHEN 'orssachet'               THEN 'ORS Sachet'
            WHEN 'salbutamolinhaler'       THEN 'Salbutamol Inhaler'
            WHEN 'metronidazole400mg'      THEN 'Metronidazole 400mg'
            ELSE TRIM(product_name)
        END AS product_name,
        quantity,
        unit_price,
        payment_method,
        customer_age
    FROM dedup
    WHERE rn = 1
),
priced AS (
    -- Reference price per product = lowest observed price (outliers only inflate)
    SELECT s.*,
           MIN(unit_price) OVER (PARTITION BY product_name) AS ref_price
    FROM standardised s
)
SELECT
    sale_id,
    sale_date,
    date_corrected,
    branch,
    product_name,
    -- Category is fixed per product, so blank categories are restored from the product
    CASE product_name
        WHEN 'Paracetamol 500mg'        THEN 'Analgesic'
        WHEN 'Ibuprofen 400mg'          THEN 'Analgesic'
        WHEN 'Amoxicillin 500mg'        THEN 'Antibiotic'
        WHEN 'Ciprofloxacin 500mg'      THEN 'Antibiotic'
        WHEN 'Metronidazole 400mg'      THEN 'Antibiotic'
        WHEN 'Artemether/Lumefantrine'  THEN 'Antimalarial'
        WHEN 'Metformin 500mg'          THEN 'Antidiabetic'
        WHEN 'Amlodipine 5mg'           THEN 'Antihypertensive'
        WHEN 'Lisinopril 10mg'          THEN 'Antihypertensive'
        WHEN 'Loratadine 10mg'          THEN 'Antihistamine'
        WHEN 'Omeprazole 20mg'          THEN 'Gastrointestinal'
        WHEN 'Vitamin C 1000mg'         THEN 'Supplement'
        WHEN 'ORS Sachet'               THEN 'Rehydration'
        WHEN 'Salbutamol Inhaler'       THEN 'Respiratory'
    END AS category,
    quantity,
    -- Prices more than 3x the reference are treated as entry errors
    CASE WHEN unit_price > 3 * ref_price THEN ref_price ELSE unit_price END AS unit_price,
    CASE WHEN unit_price > 3 * ref_price THEN 1 ELSE 0 END AS price_corrected,
    quantity * (CASE WHEN unit_price > 3 * ref_price THEN ref_price ELSE unit_price END) AS total_amount,
    CASE
        WHEN LOWER(TRIM(payment_method)) = 'cash' THEN 'Cash'
        WHEN LOWER(TRIM(payment_method)) = 'pos' THEN 'POS'
        WHEN LOWER(TRIM(payment_method)) IN ('transfer', 'bank transfer') THEN 'Transfer'
        ELSE 'Unknown'
    END AS payment_method,
    -- Impossible ages become NULL and are flagged, not guessed
    CASE WHEN customer_age BETWEEN 1 AND 110 THEN customer_age ELSE NULL END AS customer_age,
    CASE WHEN customer_age IS NULL OR customer_age NOT BETWEEN 1 AND 110 THEN 1 ELSE 0 END AS age_invalid
FROM priced
WHERE sale_date IS NOT NULL;
