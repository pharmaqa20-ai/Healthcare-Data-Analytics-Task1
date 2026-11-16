# Healthcare Data Visualization — Task 2

## Objective
Visualize the supplied healthcare claims dataset.

## Files
- `Healthcare_Task2_Visualizations.xlsx` — summary tables and chart dashboard.
- `Healthcare_Task2_Report.docx` — project report and interpretation.
- `Healthcare_Task2_R_Script.R` — reproducible R code.
- `claims_data_cleaned.csv` — supplied cleaned dataset used for the analysis.
- `charts/` — exported chart images.

## Visualizations
1. Top 10 diagnosis codes by claim count.
2. Claims by insurance type.
3. Claims by outcome.
4. Average billed, allowed and paid amounts by insurance type.

## Data limitation
The supplied claims dataset does not contain age, gender, or medication fields. These requested chart topics cannot be calculated from the available data. Alternative charts using available fields are clearly identified; no demographic or medication values have been fabricated.

## How to reproduce in RStudio
1. Put this folder in your working directory.
2. Ensure `claims_data_cleaned.csv` is in the same folder as the R script.
3. Open `Healthcare_Task2_R_Script.R` in RStudio.
4. Click Source. The script creates a `task2_outputs` folder containing the chart images and a missing-value summary.
