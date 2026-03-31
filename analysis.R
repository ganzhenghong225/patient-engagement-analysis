# Load libraries
library(dplyr)
library(ggplot2)

# Load data
encounters <- read.csv(file.choose())

# Convert Date to proper format
encounters$Date <- as.Date(encounters$Date, format = "%m/%d/%y")

# Sort and calculate gaps
all_gaps <- encounters %>%
  arrange(PatientDurableKey, Date) %>%
  group_by(PatientDurableKey) %>%
  mutate(days_between = as.numeric(Date - lag(Date))) %>%
  ungroup()

# Create patient summary
patient_summary <- all_gaps %>%
  group_by(PatientDurableKey) %>%
  summarise(
    max_gap = max(days_between, na.rm = TRUE),
    visit_count = n()
  )

# Create groups
patient_summary <- patient_summary %>%
  mutate(group = ifelse(visit_count == 2, "Drop-off",
                 ifelse(visit_count > 5, "High-visit", "Other")))

# Boxplot
ggplot(patient_summary, aes(x = group, y = max_gap)) +
  geom_boxplot() +
  labs(
    title = "Gap Differences by Patient Type",
    x = "Patient Type",
    y = "Max Gap (days)"
  )

# Save plot
ggsave("boxplot.png")
