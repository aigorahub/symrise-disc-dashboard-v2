# Setup script for renv and essential packages
# Run this script to initialize the project with required dependencies

# Initialize renv
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

renv::init()

# Install essential packages
essential_packages <- c(
  # Core Shiny packages
  "shiny",
  "bs4Dash",
  "shinyjs",
  "shinyWidgets",
  "DT",
  
  # Box for modular structure
  "box",
  
  # Data handling
  "tidyverse",
  "data.table",
  "readxl",
  "openxlsx",
  
  # Visualization
  "ggplot2",
  "plotly", 
  "viridis",
  "RColorBrewer",
  "scales",
  "patchwork",
  "ggrepel",
  "ggthemes",
  "ggradar",
  
  # Statistical analysis
  "FactoMineR",
  "SensoMineR",
  "sensR",
  "lme4",
  "lmerTest",
  "car",
  
  # Reporting
  "flextable",
  "officer",
  "rvg",
  
  # Utilities
  "janitor",
  "magrittr"
)

# Install packages
for (pkg in essential_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    renv::install(pkg)
  }
}

# Take a snapshot
renv::snapshot()

cat("Setup complete! The project is now ready with renv package management.\n")