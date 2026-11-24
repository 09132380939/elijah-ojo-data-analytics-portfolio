# Data Dictionary: pharmacy_sales_raw.csv

Source: synthetic dataset for practice. A small pharmacy chain with five branches in Osun State, sales for calendar year 2025.

| Column | Meaning |
|---|---|
| sale_id | Transaction ID |
| sale_date | Date of sale |
| branch | Branch where the sale happened |
| product_name | Drug or product sold |
| category | Therapeutic or product category |
| quantity | Units sold |
| unit_price | Price per unit in Naira |
| total_amount | Quantity x unit_price, in Naira |
| payment_method | Cash, Transfer or POS |
| customer_age | Age of customer in years |

## Brief
You have just been handed this export. Before anyone can trust a report from it, it must be profiled and cleaned with SQL.
1. Profile the table: row counts, nulls, distinct values per column.
2. Find and handle every data quality problem you can.
3. Produce a clean table and report what changed and why.
4. Answer: top branches by revenue, best categories by month, payment mix.

## Extra task: clinical plausibility check
Customer age was not generated with any link to the product sold, so some age and drug combinations make no clinical sense (for example an antihypertensive recorded for a toddler).
1. Using your pharmacology knowledge, define a set of age rules per drug and justify each one.
2. Write SQL to flag every row that breaks a rule, with counts per drug and per branch.
3. Decide what to do with flagged rows (exclude, correct, or escalate) and explain why.
