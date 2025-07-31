# Test data import
library(readxl)

# Create test data
test_data <- data.frame(
  Panelist = rep(1:30, each = 3),
  Total = rep(3, 90),
  Correct = sample(0:3, 90, replace = TRUE, prob = c(0.1, 0.2, 0.3, 0.4))
)

# Save as Excel
write.csv(test_data, "test_discrimination_data.csv", row.names = FALSE)

cat("Test data created: test_discrimination_data.csv\n")
cat("Columns:", paste(names(test_data), collapse = ", "), "\n")
cat("Rows:", nrow(test_data), "\n")

# Test reading
data <- read.csv("test_discrimination_data.csv")
cat("\nData read successfully\n")
print(head(data))