# Planted data issues (synthetic dataset notes)

Counts are approximate because some issues overlap on the same rows.

- **Exact duplicate rows**: 25 rows duplicated (same sale_id appears twice)
- **Inconsistent branch text**: 60 rows with uppercase, lowercase or stray spaces
- **Payment method variants**: 50 rows, e.g. cash, CASH, pos, Bank Transfer
- **Missing values**: 40 blank customer_age, 30 blank category, 20 blank payment_method
- **Impossible ages**: 12 rows with ages like 0, -5, 150, 999
- **Invalid quantities**: 10 rows with zero or negative quantity (total_amount no longer matches)
- **Total mismatch**: About 35 rows where total_amount does not equal quantity x unit_price
- **Mixed or invalid date formats**: 18 rows with dd/mm/yyyy, slashes, or impossible dates
- **Price outliers**: 8 rows with unit_price 10x or 100x too high
- **Product name inconsistencies**: Spelling and casing variants of product_name (Paracetamol, Amoxicillin, Metformin, Ibuprofen)

## Clinically implausible age and drug pairs (added after review)

The customer ages in this file were generated at random, independent of the product. So implausible pairs occur naturally throughout the data and are not a small planted set. Approximate counts after removing duplicates, using these example rules:

- **Lisinopril (antihypertensive) under 18**: about 19 rows
- **Amlodipine (antihypertensive) under 18**: about 18 rows
- **Metformin (antidiabetic) under 10**: about 6 rows
- **Ciprofloxacin under 18 (generally avoided in children)**: about 27 rows
- **Loratadine under 2**: about 1 rows

Total: about 71 flagged rows. Your own rules may differ, which is fine. Justify each one in your write-up.
