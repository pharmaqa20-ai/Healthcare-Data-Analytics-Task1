# Task 3 — Pharmacy Sales & Drug Analysis

## Executive summary
Analysis of an Indonesian pharmacy transaction database imported into MySQL Workbench. The `det_sales` table contained **514,620 records**. The `ms_product` catalogue contained **6,878 distinct product codes**, **157 manufacturer codes**, and **2 blank product names**. The uploaded top-30 product export and monthly query screenshots form the source evidence for the results below.

## Objective 1: Identify top-selling medicines
Ranked by sum of `det_sales.QTY` joined to `ms_product` on `KD_OBAT`.

| Rank | Product | Quantity sold |
|---:|---|---:|
| 1 | Metformin 500 mg | 173,131.00 |
| 2 | Neurodex FC komb | 167,570.00 |
| 3 | Candesartan TI 8 mg | 160,495.00 |
| 4 | Nitrokaf Retard Forte 5 mg | 138,153.00 |
| 5 | Eclid 50 mg | 133,644.00 |
| 6 | Lansoprazole 30 mg | 132,443.00 |
| 7 | Aptor 100 mg | 99,927.00 |
| 8 | Methylprednisolone 4 mg | 89,171.75 |
| 9 | Amlodipin 5 mg | 80,922.00 |
| 10 | Asam Mefenamat 500 mg | 73,324.00 |

**Finding:** Metformin 500 mg ranked first by quantity sold, followed by Neurodex FC komb and Candesartan TI 8 mg. Quantity units are not harmonised across product types, so this is a product-unit ranking, not a comparable count of prescriptions or doses.

## Objective 2: Analyse monthly sales growth
Estimated monthly sales were calculated as `SUM(det_sales.QTY * det_sales.HJ)` after joining `ms_sales` on `NO_RESEP`. Values are **not audited revenue**; the currency, per-unit price interpretation, taxes and any returns/discounts have not been independently verified. The date range is January–December 2015.

| Month | Estimated sales value | Month-over-month growth |
|---|---:|---:|
| 2015-01 | 663,046,255.32 | N/A |
| 2015-02 | 951,746,168.48 | +43.54% |
| 2015-03 | 1,295,033,623.86 | +36.07% |
| 2015-04 | 1,227,306,876.59 | -5.23% |
| 2015-05 | 1,211,618,083.86 | -1.28% |
| 2015-06 | 1,275,600,634.59 | +5.28% |
| 2015-07 | 1,174,794,659.55 | -7.90% |
| 2015-08 | 1,344,994,859.77 | +14.49% |
| 2015-09 | 1,704,854,371.83 | +26.76% |
| 2015-10 | 1,642,173,847.81 | -3.68% |
| 2015-11 | 1,416,579,988.92 | -13.74% |
| 2015-12 | 1,372,260,698.84 | -3.13% |

**Findings:** September recorded the highest estimated sales value (1,704,854,371.83). January recorded the lowest (663,046,255.32). February had the highest month-over-month growth (+43.54%); November had the largest decline (−13.74%).

## Objective 3: Compare branded versus generic medicines — classification audit
The imported product catalogue contains product name (`NAMA`), medicine code (`KD_OBAT`), manufacturer code (`KD_PABRIK`) and listed price (`HJ_RP`), but **no verified brand/generic category**. Product names, manufacturer codes, or price alone do not reliably determine regulatory brand/generic status. Accordingly, **a numerical branded-versus-generic comparison cannot be responsibly reported from this dataset alone**. The accompanying `Brand_Generic_Classification_Review.csv` records the 28 non-packaging products among the top 30 as **Unverified** pending validation against authoritative product records. Two empty-capsule packaging products (`Kapsul kosong 00` and `Kapsul kosong 0`) were excluded from that medicine-classification review.

**Recommended future work:** Obtain an authoritative product-level branded/generic classification and join it to `ms_product.KD_OBAT`; then compare total quantities, estimated sales values and product counts by verified class. Do not interpret this classification-review file as a completed brand/generic sales comparison.

## Data quality and limitations
- Source transaction and product tables may include packaging or non-medicine products.
- Fractional quantities exist and source units may differ by product.
- Monthly sales are derived estimates, not verified financial totals.
- The uploaded top-30 export is a limited subset, not a census of product classification.
- No verified branded/generic labels were available.

## Deliverables
`Top_30_Pharmacy_Medicines.csv`, `Monthly_Sales_Growth_2015.csv`, `Brand_Generic_Classification_Review.csv`, three chart PNGs, and `Analysis_Queries.sql`.
