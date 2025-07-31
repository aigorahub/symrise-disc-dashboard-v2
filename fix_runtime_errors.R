# Fix runtime errors in Symrise Dashboard

# 1. Ensure all required packages are installed
required_packages <- c(
  "shiny", "bs4Dash", "box", "sensR", "readxl",
  "dplyr", "tidyr", "ggplot2", "plotly", "officer",
  "flextable", "forcats", "scales"
)

missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages)
}

# 2. Load and test sensR
library(sensR)
cat("\nsensR version:", as.character(packageVersion("sensR")), "\n")

# Check available functions
cat("\nAvailable sensR functions:\n")
sensr_funs <- ls("package:sensR")
cat("- Sample size functions:", paste(sensr_funs[grep("SS", sensr_funs)], collapse = ", "), "\n")
cat("- Power functions:", paste(sensr_funs[grep("pwr|Pwr", sensr_funs)], collapse = ", "), "\n")

# 3. Test key functions
cat("\nTesting key functions:\n")

# Test d.primePwr
if ("d.primePwr" %in% sensr_funs) {
  test_power <- d.primePwr(d.primeA = 1, sample.size = 30, alpha = 0.05, test = "difference", method = "triangle")
  cat("✓ d.primePwr works. Test result:", round(test_power, 3), "\n")
} else {
  cat("✗ d.primePwr not found\n")
}

# Test d.primeSS
if ("d.primeSS" %in% sensr_funs) {
  test_ss <- d.primeSS(d.primeA = 1, target.power = 0.8, alpha = 0.05, test = "difference", method = "triangle")
  cat("✓ d.primeSS works. Test result:", ceiling(test_ss), "\n")
} else {
  cat("✗ d.primeSS not found\n")
}

cat("\nAll checks complete. You can now run: shiny::runApp()\n")