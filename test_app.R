# Test script to verify basic app functionality

# Check if required packages are available
required_packages <- c("shiny", "bs4Dash", "box")

missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat("Missing packages:", paste(missing_packages, collapse = ", "), "\n")
  cat("Please run: source('setup_renv.R')\n")
} else {
  cat("All required packages are available.\n")
  cat("Starting the app...\n")
  
  # Try to run the app
  tryCatch({
    shiny::runApp(".", launch.browser = FALSE)
  }, error = function(e) {
    cat("Error running app:\n")
    print(e)
  })
}