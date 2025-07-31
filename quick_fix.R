# Quick fix for missing forcats package
if (!requireNamespace("forcats", quietly = TRUE)) {
  message("Installing forcats package...")
  install.packages("forcats")
}

# Run the app
shiny::runApp()