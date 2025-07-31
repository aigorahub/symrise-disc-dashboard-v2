# Test script to debug discrimination analysis
library(sensR)

# Create sample data matching expected format
sample_data <- data.frame(
  Panelist = factor(paste0("P", rep(1:10, each = 2))),
  Product = rep(c("1-2", "3-4"), 10),
  Correct = c(1, 0, 1, 1, 0, 1, 1, 0, 1, 0,  # Sample correct/incorrect responses
             0, 1, 1, 0, 1, 0, 0, 1, 0, 1),
  Total = rep(1, 20)
)

cat("Sample data structure:\n")
print(head(sample_data))
cat("Columns:", paste(names(sample_data), collapse = ", "), "\n")

# Test data structure that would come from import functions
test_data_info <- list(
  tidy_data = sample_data,
  test_type = "triangle",
  test_objective = "similarity",
  is_double = FALSE
)

cat("\nTesting discrimination analysis...\n")

# Import the discrimination analysis function using box
box::use(R/proc/discrimination_analysis)

# Test the analysis function
tryCatch({
  result <- discrimination_analysis$perform_discrimination_test(
    data = test_data_info,
    test_type = "triangle",
    test_objective = "similarity",
    alpha_level = 0.1,
    delta_threshold = 0.5
  )

  cat("SUCCESS! Analysis returned:\n")
  cat("Keys:", paste(names(result), collapse = ", "), "\n")
  cat("d_prime:", result$d_prime, "\n")
  cat("p_value:", result$p_value, "\n")

}, error = function(e) {
  cat("ERROR in analysis:\n")
  cat("Message:", e$message, "\n")
  cat("Traceback:\n")
  traceback()
})

