# Quick test to run the app with error handling

cat("Testing Symrise Dashboard...\n")

# Try to run the app
tryCatch({
  shiny::runApp(launch.browser = FALSE, port = 3838)
}, error = function(e) {
  cat("\nError occurred:\n")
  print(e)
  cat("\nDebug info:\n")
  traceback()
})