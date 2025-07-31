# Detailed test of sample size calculation
library(sensR)

cat("=== Testing Sample Size Calculation ===\n\n")

# Test case 1: From user report
cat("Test 1: Triangle, d'=1, power=0.85, alpha=0.1\n")
if (exists("d.primeSS", where = asNamespace("sensR"))) {
  result1 <- d.primeSS(
    d.primeA = 1.0,
    target.power = 0.85,
    alpha = 0.1,
    test = "difference",
    method = "triangle"
  )
  cat("Result:", ceiling(result1), "participants\n\n")
} else {
  cat("ERROR: d.primeSS not found in sensR!\n\n")
}

# Test case 2: Original user example
cat("Test 2: Tetrad, d'=1.2, power=0.87, alpha=0.1\n")
if (exists("d.primeSS", where = asNamespace("sensR"))) {
  result2 <- d.primeSS(
    d.primeA = 1.2,
    target.power = 0.87,
    alpha = 0.1,
    test = "difference",
    method = "tetrad"
  )
  cat("Result:", ceiling(result2), "participants\n\n")
} else {
  cat("ERROR: d.primeSS not found in sensR!\n\n")
}

# Check available functions
cat("Available sensR functions for sample size:\n")
funs <- ls("package:sensR")
ss_funs <- funs[grep("SS|sample", funs, ignore.case = TRUE)]
if (length(ss_funs) > 0) {
  print(ss_funs)
} else {
  cat("No functions containing 'SS' or 'sample' found\n")
}

# Try alternative approaches
cat("\n\nTrying binary search with d.primePwr:\n")
if (exists("d.primePwr", where = asNamespace("sensR"))) {
  # Binary search for sample size
  d_prime <- 1.0
  target_power <- 0.85
  alpha <- 0.1
  method <- "triangle"
  
  n_min <- 5
  n_max <- 1000
  
  while (n_max - n_min > 1) {
    n_mid <- floor((n_min + n_max) / 2)
    
    current_power <- d.primePwr(
      d.primeA = d_prime,
      sample.size = n_mid,
      alpha = alpha,
      test = "difference",
      method = method
    )
    
    cat("n =", n_mid, ", power =", round(current_power, 3), "\n")
    
    if (current_power < target_power) {
      n_min <- n_mid
    } else {
      n_max <- n_mid
    }
  }
  
  cat("\nBinary search result:", n_max, "participants\n")
  
  # Verify
  final_power <- d.primePwr(
    d.primeA = d_prime,
    sample.size = n_max,
    alpha = alpha,
    test = "difference",
    method = method
  )
  cat("Verification - Power with", n_max, "participants:", round(final_power, 3), "\n")
}