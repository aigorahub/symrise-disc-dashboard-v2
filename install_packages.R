# Install missing packages for Symrise Dashboard

# Check if package is installed, if not install it
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing", pkg, "..."))
    install.packages(pkg)
  } else {
    message(paste(pkg, "is already installed"))
  }
}

# Core packages needed
required_packages <- c(
  "shiny",
  "bs4Dash",
  "box",
  "sensR",
  "ggplot2",
  "plotly",
  "dplyr",
  "tidyr",
  "forcats",  # For fct_rev function
  "readxl",
  "officer",
  "flextable",
  "scales"
)

# Install each package
for (pkg in required_packages) {
  install_if_missing(pkg)
}

# Verify sensR is properly installed
if (requireNamespace("sensR", quietly = TRUE)) {
  library(sensR)
  message("\nAvailable sensR functions:")
  funs <- ls("package:sensR")
  message("Sample size functions: ", paste(funs[grep("SS|sample", funs)], collapse = ", "))
  message("Power functions: ", paste(funs[grep("pwr|power", funs)], collapse = ", "))
  message("Discrimination functions: ", paste(funs[grep("discrim", funs)], collapse = ", "))
} else {
  message("ERROR: sensR package not installed properly")
}

message("\nPackage installation complete!")
message("You can now run the app with: shiny::runApp()")