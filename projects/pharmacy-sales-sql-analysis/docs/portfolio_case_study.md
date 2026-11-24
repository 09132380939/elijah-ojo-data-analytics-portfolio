# Pharmacy Sales: Data Cleaning, Analysis and Clinical Audit in SQL

**Role:** Research Data Analyst
**Tools:** MySQL, SQL (CTEs, window functions, CASE logic), Microsoft Word reporting
**Data:** Synthetic practice dataset, 1,525 transactions from five pharmacy branches in Osun State (2025)

## Overview

A pharmacy sales export arrived with duplicates, broken dates, inconsistent text, wrong prices and impossible customer ages. I built a SQL pipeline that cleans it with full traceability, then used the clean table to answer business questions and to audit whether the drugs sold made clinical sense for the customer's age.

## The problem

Raw data cannot be trusted for reporting. In this export, 25 transactions were duplicated, 10 had zero or negative quantities, 12 carried impossible calendar dates, and eight had unit prices 10 to 100 times too high. Product names, branch names and payment methods came in many spellings, and some customer ages were 0, negative or above 150.

## My approach

1. **Profile first.** I counted nulls, distinct values and anomalies before changing anything.
2. **Clean with traceability.** Duplicates were removed with window functions. Invalid rows went to a separate rejected table instead of vanishing. Every correction (dates, prices, ages) is flagged in its own column.
3. **Reconcile.** A check proves every raw row is accounted for: 1,525 raw rows = 25 duplicates + 10 rejected + 1,490 clean.
4. **Analyse.** Branch performance, payment mix and top category by month.
5. **Audit clinically.** Using my pharmacology background, I wrote age rules per drug and flagged implausible sales.

## Key findings

- **Price errors can change the story.** Eight bad prices added about ₦1.17 million of fake revenue, ₦976,500 of it in one branch. After correction, Iwo still leads on revenue (₦1,850,700), but Ede has the highest average order value.
- **Payments are evenly split:** Cash 34.01%, Transfer 33.64%, POS 31.50%.
- **Antibiotics and respiratory products** take the top category spot in every month, 7 and 5 months respectively.
- **70 sales (₦432,300) failed the clinical check**, for example antihypertensives and ciprofloxacin recorded for minors. I recommended escalating them for review rather than deleting or editing them, so financial and medical records stay intact.

## Skills demonstrated

Data profiling, data cleaning, window functions, CTEs, pattern-based date parsing, data validation and reconciliation, business analysis, clinical domain validation, technical reporting.

## What I learned

Cleaning is an analytical decision, not just a mechanical step. How you handle one column of bad prices can change which branch looks best. I also learned to document every assumption, such as how impossible dates were remapped, so a reader can challenge it.

## Links

- Full technical report (Word): _add link_
- SQL script on GitHub: _add link_
- Clean dataset: _add link_

*Note: the dataset is synthetic and was built for practice. The findings demonstrate method and do not describe a real pharmacy.*
