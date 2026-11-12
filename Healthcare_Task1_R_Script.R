# VIRTUAL WORKS INTERNSHIP - HEALTHCARE DATA ANALYTICS TASK 1
# Keep this script and the HealthcareAnalytics-main folder in the same project folder.
# In RStudio: File > New Project > Existing Directory, choose the folder containing this script.
# Then run this script from top to bottom.

# Install once if needed:
# install.packages(c("tidyverse", "lubridate", "writexl", "readxl"))

library(tidyverse)
library(lubridate)
library(writexl)
library(readxl)

# 1. Set input paths
data_dir <- "HealthcareAnalytics-main"
claims_file <- file.path(data_dir, "claims_data.csv")
pharma_file <- file.path(data_dir, "Pharma_data.csv")

if (!file.exists(claims_file)) {
  stop("claims_data.csv not found. Check that the HealthcareAnalytics-main folder is beside this R script.")
}

dir.create("task1_outputs", showWarnings = FALSE)

# 2. Import claims data.
# IDs and codes are explicitly read as text because they are identifiers, not measurements.
claims <- read_csv(
  claims_file,
  col_types = cols(
    `Claim ID` = col_character(),
    `Provider ID` = col_character(),
    `Patient ID` = col_character(),
    `Procedure Code` = col_character(),
    `Diagnosis Code` = col_character(),
    .default = col_guess()
  ),
  show_col_types = FALSE
)

# 3. Inspect original structure
cat("\\n--- DATA DIMENSIONS ---\\n")
print(dim(claims))
cat("\\n--- COLUMN NAMES AND TYPES ---\\n")
glimpse(claims)
cat("\\n--- SUMMARY ---\\n")
print(summary(claims))

# 4. Clean column names and standardise date
claims <- claims %>%
  rename_with(~ str_replace_all(str_to_lower(.x), "[^a-z0-9]+", "_")) %>%
  mutate(date_of_service = parse_date_time(
    date_of_service,
    orders = c("mdy", "dmy", "ymd")
  ))

# 5. Data-quality checks BEFORE removing anything
missing_summary <- tibble(
  column = names(claims),
  missing_count = map_int(claims, ~ sum(is.na(.x))),
  missing_percent = round(missing_count / nrow(claims) * 100, 2)
)

quality_summary <- tibble(
  check = c("Rows before cleaning", "Columns", "Missing cells",
            "Exact duplicate rows", "Duplicate Claim IDs",
            "Unique patients", "Unparseable service dates"),
  result = c(
    nrow(claims),
    ncol(claims),
    sum(is.na(claims)),
    sum(duplicated(claims)),
    sum(duplicated(claims$claim_id)),
    n_distinct(claims$patient_id),
    sum(is.na(claims$date_of_service))
  )
)

# 6. Remove exact duplicate rows only. Do not remove rows just because IDs repeat
# unless the data owner confirms they are duplicate claims.
claims_clean <- claims %>% distinct()

# 7. Patient, diagnosis and procedure summaries
patient_summary <- tibble(
  total_claim_records = nrow(claims_clean),
  unique_patients = n_distinct(claims_clean$patient_id),
  unique_diagnosis_codes = n_distinct(claims_clean$diagnosis_code),
  unique_procedure_codes = n_distinct(claims_clean$procedure_code)
)

diagnosis_frequency <- claims_clean %>%
  count(diagnosis_code, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 2))

procedure_frequency <- claims_clean %>%
  count(procedure_code, sort = TRUE) %>%
  mutate(percentage = round(n / sum(n) * 100, 2))

# 8. Category summaries
insurance_summary <- claims_clean %>% count(insurance_type, sort = TRUE)
claim_status_summary <- claims_clean %>% count(claim_status, sort = TRUE)
reason_summary <- claims_clean %>% count(reason_code, sort = TRUE)
followup_summary <- claims_clean %>% count(follow_up_required, sort = TRUE)
ar_status_summary <- claims_clean %>% count(ar_status, sort = TRUE)
outcome_summary <- claims_clean %>% count(outcome, sort = TRUE)

# 9. Financial summaries (currency is not specified in the source)
amount_summary <- claims_clean %>%
  summarise(
    across(
      c(billed_amount, allowed_amount, paid_amount),
      list(
        mean = ~ mean(.x, na.rm = TRUE),
        median = ~ median(.x, na.rm = TRUE),
        minimum = ~ min(.x, na.rm = TRUE),
        maximum = ~ max(.x, na.rm = TRUE),
        total = ~ sum(.x, na.rm = TRUE)
      )
    )
  )

financial_checks <- claims_clean %>%
  summarise(
    paid_greater_than_billed = sum(paid_amount > billed_amount, na.rm = TRUE),
    allowed_greater_than_billed = sum(allowed_amount > billed_amount, na.rm = TRUE),
    negative_billed = sum(billed_amount < 0, na.rm = TRUE),
    negative_allowed = sum(allowed_amount < 0, na.rm = TRUE),
    negative_paid = sum(paid_amount < 0, na.rm = TRUE)
  )

# 10. Plots
p1 <- diagnosis_frequency %>%
  slice_max(n, n = 10) %>%
  ggplot(aes(x = reorder(diagnosis_code, n), y = n)) +
  geom_col(fill = "steelblue") + coord_flip() +
  labs(title = "Top 10 Diagnosis Codes", x = "Diagnosis code",
       y = "Number of claim records") + theme_minimal()

p2 <- ggplot(claims_clean, aes(x = billed_amount)) +
  geom_histogram(bins = 30, fill = "darkseagreen", color = "white") +
  labs(title = "Distribution of Billed Amounts", x = "Billed amount",
       y = "Number of claims") + theme_minimal()

p3 <- ggplot(claims_clean, aes(x = insurance_type)) +
  geom_bar(fill = "coral") +
  labs(title = "Claims by Insurance Type", x = "Insurance type",
       y = "Number of claims") + theme_minimal() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave("task1_outputs/top_10_diagnosis_codes.png", p1, width = 8, height = 5, dpi = 300)
ggsave("task1_outputs/billed_amount_distribution.png", p2, width = 8, height = 5, dpi = 300)
ggsave("task1_outputs/claims_by_insurance.png", p3, width = 8, height = 5, dpi = 300)

# 11. Optional: clean the pharmaceutical reference file
# It is a product reference, not a patient-medication administration dataset.
pharma_clean <- NULL
if (file.exists(pharma_file)) {
  pharma <- read_csv(pharma_file, show_col_types = FALSE)
  pharma_clean <- pharma %>%
    filter(if_any(everything(), ~ !is.na(.x) & str_trim(as.character(.x)) != "")) %>%
    distinct()
  pharma_quality <- tibble(
    check = c("Raw rows", "Completely blank rows", "Nonblank rows after blank-row removal",
              "Exact duplicates after blank-row removal", "Rows after distinct()"),
    result = c(
      nrow(pharma),
      sum(rowSums(is.na(pharma)) == ncol(pharma)),
      sum(rowSums(is.na(pharma)) < ncol(pharma)),
      sum(duplicated(pharma %>% filter(if_any(everything(), ~ !is.na(.x) & str_trim(as.character(.x)) != "")))),
      nrow(pharma_clean)
    )
  )
} else {
  pharma_quality <- tibble(note = "Pharma_data.csv not found; pharmaceutical audit skipped.")
}

# 12. Export all tables to Excel
export_list <- list(
  Cleaned_Claims = claims_clean,
  Data_Quality = quality_summary,
  Missing_Values = missing_summary,
  Patient_Summary = patient_summary,
  Diagnosis_Frequency = diagnosis_frequency,
  Procedure_Frequency = procedure_frequency,
  Insurance_Summary = insurance_summary,
  Claim_Status = claim_status_summary,
  Reason_Codes = reason_summary,
  Followup = followup_summary,
  AR_Status = ar_status_summary,
  Outcomes = outcome_summary,
  Amount_Summary = amount_summary,
  Financial_Checks = financial_checks,
  Pharma_Quality = pharma_quality
)
if (!is.null(pharma_clean)) {
  export_list$Cleaned_Pharma_Reference <- pharma_clean
}

write_xlsx(export_list, "task1_outputs/Healthcare_Task1_R_Results.xlsx")
write_csv(claims_clean, "task1_outputs/claims_data_cleaned.csv")

cat("\\nSUCCESS: Results saved in the task1_outputs folder.\\n")
cat("Open task1_outputs/Healthcare_Task1_R_Results.xlsx for all tables.\\n")

# IMPORTANT INTERPRETATION:
# claims_data.csv does not contain Age, Gender, Medication or Dosage fields.
# Do not calculate or invent those values.
# Diagnosis codes in the claims file have not been verified against the supplied ICD-11 list.
# Do not label diagnosis codes with disease names until the correct code system is confirmed.
