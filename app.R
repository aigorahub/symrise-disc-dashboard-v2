# Symrise Discrimination Training Dashboard - Modernized
# Main entry point for the application

# Use box for module management
box::purge_cache()
box::use(
  R/config,
  R/app/core
)

# Load configuration and theme
config$setup()

# Start the application
shinyApp(
  ui = core$ui(),
  server = core$server
)