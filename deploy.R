# Deployment script for Symrise Discrimination Training Dashboard

# Ensure rsconnect is installed
if (!requireNamespace("rsconnect", quietly = TRUE)) {
  install.packages("rsconnect")
}

# Deploy to shinyapps.io
rsconnect::deployApp(
  appDir = "./",
  account = "aigora",
  appName = "symrise-discrimination-dashboard-modernized",
  appTitle = "Symrise Discrimination Training Dashboard",
  forceUpdate = TRUE
)