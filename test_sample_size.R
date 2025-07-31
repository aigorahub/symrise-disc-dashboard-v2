# Test sample size calculation
library(sensR)

# Test case from user
method <- "tetrad"
d_prime <- 1.2
power <- 0.87
alpha <- 0.1

# Calculate sample size
result <- d.primeSS(
  d.primeA = d_prime,
  target.power = power,
  alpha = alpha,
  test = "difference",  # Always use "difference" as per old dashboard
  method = method
)

cat("Test parameters:\n")
cat("- Method:", method, "\n")
cat("- d-prime:", d_prime, "\n")
cat("- Power:", power, "\n")
cat("- Alpha:", alpha, "\n")
cat("\nResult:", ceiling(result), "participants\n")

# Verify with power calculation
actual_power <- d.primePwr(
  d.primeA = d_prime,
  sample.size = ceiling(result),
  alpha = alpha,
  test = "difference",
  method = method
)

cat("Verification - Power with", ceiling(result), "participants:", round(actual_power, 3), "\n")