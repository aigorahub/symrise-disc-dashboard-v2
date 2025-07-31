# Test similarity vs difference sample size calculations
library(sensR)

cat("=== Testing Similarity vs Difference Sample Size ===\n\n")

# Test parameters
effect_size <- 1.2
power <- 0.87
alpha <- 0.1
method <- "triangle"

# Test 1: Difference test
cat("Test 1: Difference test\n")
cat("- Effect size (d'):", effect_size, "\n")
cat("- Power:", power, "\n")
cat("- Alpha:", alpha, "\n")
cat("- Method:", method, "\n")

result_diff <- d.primeSS(
  d.primeA = effect_size,
  target.power = power,
  alpha = alpha,
  test = "difference",
  method = method
)
cat("Result:", ceiling(result_diff), "participants\n\n")

# Test 2: Similarity test
cat("Test 2: Similarity test\n")
cat("- Effect size (d'0):", effect_size, "\n")
cat("- Power:", power, "\n")
cat("- Alpha:", alpha, "\n")
cat("- Method:", method, "\n")

result_sim <- d.primeSS(
  d.primeA = 0,
  d.prime0 = effect_size,
  target.power = power,
  alpha = alpha,
  test = "similarity",
  method = method
)
cat("Result:", ceiling(result_sim), "participants\n\n")

# Comparison
cat("=== Comparison ===\n")
cat("Difference test:", ceiling(result_diff), "participants\n")
cat("Similarity test:", ceiling(result_sim), "participants\n")
cat("Difference:", ceiling(result_sim) - ceiling(result_diff), "participants\n") 