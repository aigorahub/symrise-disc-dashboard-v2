# Symrise Discrimination Training Dashboard - Modernized
# Main entry point for the application

# Load sensR globally before any box modules to avoid namespace issues
library(sensR)

# Verify key functions are available
if (!exists("d.primePwr") || !exists("d.primeSS")) {
  stop("Required sensR functions not available. Please check sensR installation.")
}

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