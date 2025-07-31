# Diagnostic script for sensR package

cat("=== sensR Package Diagnostics ===\n\n")

# Check if sensR is installed
if (!requireNamespace("sensR", quietly = TRUE)) {
  cat("ERROR: sensR package is not installed!\n")
  cat("Please install it with: install.packages('sensR')\n")
  stop("sensR not available")
}

library(sensR)

# Check package version
cat("sensR version:", as.character(packageVersion("sensR")), "\n\n")

# List available functions
all_functions <- ls("package:sensR")

cat("Functions for sample size calculation:\n")
ss_functions <- all_functions[grep("SS|sample", all_functions, ignore.case = TRUE)]
if (length(ss_functions) > 0) {
  print(ss_functions)
} else {
  cat("  No functions found containing 'SS' or 'sample'\n")
}

cat("\nFunctions for power calculation:\n")
pwr_functions <- all_functions[grep("pwr|power", all_functions, ignore.case = TRUE)]
if (length(pwr_functions) > 0) {
  print(pwr_functions)
} else {
  cat("  No functions found containing 'pwr' or 'power'\n")
}

cat("\nDiscrimination functions:\n")
discrim_functions <- all_functions[grep("discrim", all_functions)]
if (length(discrim_functions) > 0) {
  print(discrim_functions)
} else {
  cat("  No functions found containing 'discrim'\n")
}

# Test if key functions exist
cat("\n\nChecking key functions:\n")
key_functions <- c("d.primeSS", "discrimSS", "discrimPwr", "d.primePwr", 
                   "discrim", "dod.power", "dodPwr")

for (fn in key_functions) {
  exists_status <- exists(fn, where = asNamespace("sensR"))
  cat(sprintf("  %-15s: %s\n", fn, if (exists_status) "EXISTS" else "NOT FOUND"))
}

# Try to use available functions
cat("\n\nTesting available functions:\n")

# Test discrimPwr if available
if (exists("discrimPwr", where = asNamespace("sensR"))) {
  cat("\n1. Testing discrimPwr:\n")
  tryCatch({
    result <- discrimPwr(d.primeA = 1.0, sample.size = 50, alpha = 0.05, method = "triangle")
    cat("   Success! Power =", result, "\n")
  }, error = function(e) {
    cat("   Error:", e$message, "\n")
  })
}

# Test d.primePwr if available
if (exists("d.primePwr", where = asNamespace("sensR"))) {
  cat("\n2. Testing d.primePwr:\n")
  tryCatch({
    result <- d.primePwr(d.primeA = 1.0, sample.size = 50, alpha = 0.05, method = "triangle")
    cat("   Success! Power =", result, "\n")
  }, error = function(e) {
    cat("   Error:", e$message, "\n")
  })
}

# Show function arguments if they exist
cat("\n\nFunction signatures:\n")
if (exists("discrimPwr", where = asNamespace("sensR"))) {
  cat("\ndiscrimPwr arguments:\n")
  print(args(discrimPwr))
}

if (exists("discrim", where = asNamespace("sensR"))) {
  cat("\ndiscrim arguments:\n")
  print(args(discrim))
}

cat("\n=== End of diagnostics ===\n")