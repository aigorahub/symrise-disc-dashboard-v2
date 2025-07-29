# Symrise Discrimination Training Dashboard - Modernized

A modern R Shiny application for discrimination testing and sensory analysis, rebuilt with a modular architecture.

## Features

- **Design**: Configure discrimination test parameters
- **Import**: Upload and validate test data
- **Run**: Perform statistical analysis and generate reports

## Architecture

This dashboard has been modernized with:
- **Box package** for modular code organization
- **renv** for reproducible package management
- **BS4Dash** for modern UI components
- **Clean separation** of UI, server, and business logic

## Getting Started

### Prerequisites
- R (>= 4.0.0)
- RStudio (recommended)

### Installation

1. Clone the repository
2. Open `symrise-dashboard-modernized.Rproj` in RStudio
3. Run the setup script to initialize renv and install packages:
   ```r
   source("setup_renv.R")
   ```

### Running the Application

```r
shiny::runApp()
```

## Project Structure

```
symrise-dashboard-modernized/
├── app.R                    # Main application entry
├── R/
│   ├── app/
│   │   ├── core.R          # Core orchestration
│   │   ├── ext/            # UI extensions
│   │   ├── mod/            # Feature modules
│   │   └── page/           # Page definitions
│   ├── config.R            # Configuration
│   ├── data/               # Data processing
│   ├── proc/               # Business logic
│   ├── util/               # Utilities
│   └── vis/                # Visualization
├── www/                    # Web assets
├── templates/              # Report templates
└── renv/                   # Package management
```

## Deployment

Deploy to shinyapps.io:
```r
rsconnect::deployApp("./", account="your-account", appName="symrise-discrimination-dashboard")
```

## Development

This project uses:
- **box** for modular imports
- **renv** for package management
- **BS4Dash** for UI framework
- **Symrise branding** maintained throughout

## License

© 2024 Symrise AG - All rights reserved