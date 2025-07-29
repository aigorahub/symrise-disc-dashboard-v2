# Test app functionality

cat("=== Testing Symrise Dashboard Functionality ===\n\n")

# Load required packages
library(shiny)
library(bs4Dash)
library(sensR)
library(box)

# Test 1: Check if sensR functions exist
cat("Test 1: Checking sensR functions availability\n")
cat("  d.primeSS exists:", exists("d.primeSS", where = asNamespace("sensR")), "\n")
cat("  dod.power exists:", exists("dod.power", where = asNamespace("sensR")), "\n")

# Test 2: Test sample size calculation directly
cat("\nTest 2: Direct function test\n")
tryCatch({
  result <- sensR::d.primeSS(
    d.primeA = 1.0,
    target.power = 0.85,
    alpha = 0.10,
    test = "difference",
    method = "triangle"
  )
  cat("  Triangle test sample size:", result, "\n")
}, error = function(e) {
  cat("  Error:", e$message, "\n")
})

# Test 3: Check box module loading
cat("\nTest 3: Box module loading\n")
tryCatch({
  box::use(R/config)
  cat("  Config module loaded successfully\n")
}, error = function(e) {
  cat("  Error loading config:", e$message, "\n")
})

cat("\n=== End of tests ===\n")