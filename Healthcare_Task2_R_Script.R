# Healthcare Data Visualization — Task 2
# Uses only fields present in claims_data_cleaned.csv

packages <- c("ggplot2", "dplyr", "readr", "tidyr")
to_install <- packages[!packages %in% installed.packages()[, "Package"]]
if (length(to_install)) install.packages(to_install)
invisible(lapply(packages, library, character.only = TRUE))

data <- read_csv("claims_data_cleaned.csv", show_col_types = FALSE)
dir.create("task2_outputs", showWarnings = FALSE)

# Check dataset structure and missing values
glimpse(data)
write_csv(data, "task2_outputs/claims_data_used.csv")
write_csv(
  data.frame(column = names(data),
             missing_values = sapply(data, function(x) sum(is.na(x)))),
  "task2_outputs/missing_value_summary.csv"
)

# 1. Top 10 diagnosis codes
diag <- data %>% count(`Diagnosis Code`, sort = TRUE) %>% slice_head(n = 10)
p1 <- ggplot(diag, aes(x = reorder(`Diagnosis Code`, n), y = n)) +
  geom_col() + coord_flip() +
  labs(title = "Top 10 Diagnosis Codes by Claim Count",
       x = "Diagnosis code", y = "Number of claims") +
  theme_minimal()
ggsave("task2_outputs/01_diagnosis_distribution.png", p1, width = 9, height = 5)

# 2. Claims by insurance type
ins <- data %>% count(`Insurance Type`, sort = TRUE)
p2 <- ggplot(ins, aes(x = reorder(`Insurance Type`, n), y = n)) +
  geom_col() + coord_flip() +
  labs(title = "Claims by Insurance Type", x = "Insurance type",
       y = "Number of claims") + theme_minimal()
ggsave("task2_outputs/02_insurance_distribution.png", p2, width = 9, height = 5)

# 3. Claims by outcome
out <- data %>% count(Outcome, sort = TRUE)
p3 <- ggplot(out, aes(x = reorder(Outcome, n), y = n)) +
  geom_col() + coord_flip() +
  labs(title = "Claims by Outcome", x = "Outcome",
       y = "Number of claims") + theme_minimal()
ggsave("task2_outputs/03_claim_outcome_distribution.png", p3, width = 9, height = 5)

# 4. Average billed, allowed and paid amounts by insurance type
amounts <- data %>%
  group_by(`Insurance Type`) %>%
  summarise(across(c(`Billed Amount`, `Allowed Amount`, `Paid Amount`),
                   ~ mean(.x, na.rm = TRUE)), .groups = "drop") %>%
  pivot_longer(-`Insurance Type`, names_to = "Amount Type", values_to = "Average Amount")
p4 <- ggplot(amounts, aes(x = `Insurance Type`, y = `Average Amount`,
                          fill = `Amount Type`)) +
  geom_col(position = "dodge") +
  labs(title = "Average Billed, Allowed and Paid Amount by Insurance Type",
       x = "Insurance type", y = "Average amount", fill = "Amount type") +
  theme_minimal()
ggsave("task2_outputs/04_amounts_by_insurance.png", p4, width = 9, height = 5)

# Age, gender and medication fields are not in the supplied dataset.
# Do not create or infer these values.
