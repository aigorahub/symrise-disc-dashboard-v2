# Check available sensR functions

library(sensR)

cat("=== Checking sensR package functions ===\n\n")

# Get all functions from sensR
sensr_functions <- ls("package:sensR")

# Look for functions related to sample size, power, discrimination
cat("Functions containing 'SS' or 'sample':\n")
print(sensr_functions[grep("SS|sample", sensr_functions, ignore.case = TRUE)])

cat("\nFunctions containing 'pwr' or 'power':\n")
print(sensr_functions[grep("pwr|power", sensr_functions, ignore.case = TRUE)])

cat("\nFunctions containing 'discrim':\n")
print(sensr_functions[grep("discrim", sensr_functions, ignore.case = TRUE)])

cat("\nFunctions containing 'd.prime':\n")
print(sensr_functions[grep("d.prime", sensr_functions, ignore.case = TRUE)])

cat("\nAll sensR functions:\n")
print(sort(sensr_functions))

# Check if specific functions exist
cat("\n\nChecking specific functions:\n")
cat("d.primeSS exists:", "d.primeSS" %in% sensr_functions, "\n")
cat("discrimSS exists:", "discrimSS" %in% sensr_functions, "\n")
cat("discrim exists:", "discrim" %in% sensr_functions, "\n")