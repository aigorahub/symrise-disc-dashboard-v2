# Simple check of sensR functions
library(sensR)

# Method 1: Direct check
cat("Method 1 - Direct exists check:\n")
cat("d.primeSS exists:", exists("d.primeSS"), "\n")
cat("d.primePwr exists:", exists("d.primePwr"), "\n\n")

# Method 2: Check in namespace
cat("Method 2 - Namespace check:\n")
cat("d.primeSS in namespace:", exists("d.primeSS", where = asNamespace("sensR")), "\n")
cat("d.primePwr in namespace:", exists("d.primePwr", where = asNamespace("sensR")), "\n\n")

# Method 3: Try to use the function
cat("Method 3 - Try to use functions:\n")
tryCatch({
  result <- d.primeSS(d.primeA = 1, target.power = 0.8, alpha = 0.05, test = "difference", method = "triangle")
  cat("d.primeSS works! Result:", result, "\n")
}, error = function(e) {
  cat("d.primeSS error:", e$message, "\n")
})

tryCatch({
  result <- d.primePwr(d.primeA = 1, sample.size = 30, alpha = 0.05, test = "difference", method = "triangle")
  cat("d.primePwr works! Result:", result, "\n")
}, error = function(e) {
  cat("d.primePwr error:", e$message, "\n")
})

# List all functions
cat("\n\nAll sensR functions containing 'prim':\n")
all_funs <- ls("package:sensR")
prim_funs <- all_funs[grep("prim", all_funs, ignore.case = TRUE)]
print(prim_funs)