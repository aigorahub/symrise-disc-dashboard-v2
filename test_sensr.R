# Test script to verify sensR functions

library(sensR)

cat("Testing sensR functions...\n\n")

# Test 1: Triangle test sample size calculation
cat("Test 1: Triangle test sample size\n")
tryCatch({
  result <- d.primeSS(
    d.primeA = 1.0,
    target.power = 0.85,
    alpha = 0.10,
    test = "difference",
    method = "triangle"
  )
  cat("  Result:", result, "\n")
}, error = function(e) {
  cat("  Error:", e$message, "\n")
})

# Test 2: Tetrad test sample size calculation
cat("\nTest 2: Tetrad test sample size\n")
tryCatch({
  result <- d.primeSS(
    d.primeA = 1.0,
    target.power = 0.85,
    alpha = 0.10,
    test = "similarity",
    method = "tetrad"
  )
  cat("  Result:", result, "\n")
}, error = function(e) {
  cat("  Error:", e$message, "\n")
})

# Test 3: SoD power calculation
cat("\nTest 3: Size of Difference (dod.power)\n")
tryCatch({
  result <- dod.power(
    d.prime = 1.0,
    n = 50,
    alpha = 0.05
  )
  cat("  Result:", result, "\n")
}, error = function(e) {
  cat("  Error:", e$message, "\n")
})

# Test 4: Check function arguments
cat("\nTest 4: Checking d.primeSS arguments\n")
args(d.primeSS)

cat("\nTest 5: Checking dod.power arguments\n")
args(dod.power)