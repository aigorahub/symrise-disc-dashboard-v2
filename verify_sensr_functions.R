# Verify sensR functions are available
cat("Checking sensR package...\n")

# Load sensR
if (!requireNamespace("sensR", quietly = TRUE)) {
  stop("sensR package not installed. Please run: install.packages('sensR')")
}

library(sensR)

# Check key functions
functions_to_check <- c("discrim", "discrimPwr", "d.primePwr", "d.primeSS", "betabin", "dod")

cat("\nChecking functions:\n")
for (fn in functions_to_check) {
  if (exists(fn)) {
    cat(sprintf("  %-15s: FOUND\n", fn))
  } else {
    cat(sprintf("  %-15s: NOT FOUND\n", fn))
  }
}

# Test a simple calculation
cat("\nTesting d.primePwr:\n")
tryCatch({
  result <- d.primePwr(d.primeA = 1, sample.size = 30, alpha = 0.05, test = "difference", method = "triangle")
  cat("  Success! Power =", result, "\n")
}, error = function(e) {
  cat("  Error:", e$message, "\n")
})

# Test discrimPwr if it exists
cat("\nTesting discrimPwr:\n")
if (exists("discrimPwr")) {
  tryCatch({
    result <- d.primePwr(d.primeA = 1, sample.size = 30, alpha = 0.05, test = "difference", method = "triangle")
    cat("  Success! Power =", result, "\n")
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
  })
} else {
  cat("  Function not found\n")
}

cat("\nPackage version:", as.character(packageVersion("sensR")), "\n")