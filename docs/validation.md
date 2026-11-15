
# Data Quality & Financial Reconciliation

Supporting validation documentation for the **Monthly Insurance Claims Reporting** project.

**Source:** Four synthetic monthly CSV datasets (January–April 2026).

## 1. Monthly Reconciliation

| Month | Raw Records | Duplicates Removed | Final Records | Recorded Payments (AUD) |
|---|---:|---:|---:|---:|
| January 2026 | 45 | 0 | 45 | $471,777.28 |
| February 2026 | 51 | 1 | 50 | $483,390.95 |
| March 2026 | 55 | 0 | 55 | $496,097.32 |
| April 2026 | 53 | 0 | 53 | $502,794.99 |
| **Total** | **204** | **1** | **203** | **$1,954,060.54** |

**Reconciliation findings:**
- February's original payment total was $492,611.30. Removing one confirmed duplicate (`SLI-26-02-0022`, valued at $9,220.35) reduced the reported total to **$483,390.95**.
- January contained one blank payment amount; March contained one `TBC` value. Both were excluded from financial totals.
- April contributed 53 records, with no duplicate Claim IDs identified in its source CSV.
- Source-file record counts and payment totals were independently checked against the final Excel reporting figures.

## 2. Data Cleansing & Quality Assurance

| Issue | Treatment | Purpose |
|---|---|---|
| Duplicate record | Removed one confirmed February duplicate | Prevent double-counting |
| Missing and `TBC` payments | Retained records, classified exceptions and excluded unknown amounts from sums | Maintain financial accuracy and traceability |
| Zero-value payment | Retained and flagged for review | Distinguish zero from missing |
| Inconsistent text and formats | Standardised using Power Query | Improve data consistency |
| Combined fields | Split region, location and handler details | Support structured reporting |
| Missing state values | Corrected two values in working CSV copies | Address incomplete geographic information |

## 3. Validation Methodology & Assumptions

- **Financial validation:** Compared the monthly record counts and payment totals with calculations from the original synthetic CSV files, accounting for duplicate removal and non-numeric values.
- **Duplicate handling:** The confirmed February duplicate was removed based on Claim ID. In real insurance systems, repeated Claim IDs may represent legitimate multiple payments and require investigation.
- **Duplicate-check scope:** A check referencing the already-deduplicated query confirms output uniqueness, not the absence of duplicates in incoming files.
- **Reporting scope:** Financial totals represent recorded payments rather than total incurred claims liabilities. Missing and unconfirmed amounts are excluded.
- **Source corrections:** Two missing state values were corrected in working source copies; original source snapshots should be retained to preserve traceability.
