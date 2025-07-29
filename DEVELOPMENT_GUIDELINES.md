# Development Guidelines - Symrise Dashboard

## Box Module Import Best Practices

### 1. Always Explicitly Import Functions

When using functions from external packages in box modules, follow these patterns:

#### For commonly used functions from a package:
```r
box::use(
  shiny[...],  # Imports all exported functions
  bs4Dash[...]
)
```

#### For specific functions only:
```r
box::use(
  plotly[ggplotly, plotlyOutput, renderPlotly],
  DT[datatable, DTOutput, renderDT]
)
```

#### For mixed usage:
```r
box::use(
  shiny[..., icon],  # Import all plus explicitly ensure 'icon' is available
  bs4Dash[..., valueBox, valueBoxOutput, renderValueBox]
)
```

### 2. Common Import Pitfalls and Solutions

#### Problem: "could not find function"
**Symptoms:**
```
Error in functionName() : could not find function "functionName"
```

**Solutions:**
1. Check if the function is from an external package
2. Add it to the box::use import statement
3. Use `verify_imports.R` to check all imports

#### Problem: Missing pipe operator (%>%)
**Solution:**
```r
box::use(
  magrittr[`%>%`]  # Note the backticks for special operators
)
```

### 3. Package-Function Reference

Here are the most commonly used functions and their source packages:

#### Shiny UI Components:
- `actionButton`, `selectInput`, `numericInput`, `textInput` → `shiny`
- `fileInput`, `downloadButton` → `shiny`
- `fluidRow`, `column` → `shiny`
- `icon` → `shiny` (often forgotten!)
- `NS`, `moduleServer` → `shiny`

#### BS4Dash Components:
- `box`, `infoBox`, `valueBox` → `bs4Dash`
- `dashboardPage`, `dashboardHeader`, `dashboardSidebar` → `bs4Dash`
- `tabBox`, `tabPanel` → `bs4Dash`

#### Data Table:
- `DTOutput` → `DT` (UI side)
- `renderDT` → `DT` (server side)
- `datatable` → `DT`

#### Plotting:
- `plotOutput`, `renderPlot` → `shiny`
- `plotlyOutput`, `renderPlotly` → `plotly`
- `ggplotly` → `plotly`

#### Reactive Programming:
- `reactive`, `observe`, `observeEvent` → `shiny`
- `reactiveVal`, `reactiveValues` → `shiny`
- `req`, `isolate` → `shiny`
- `eventReactive` → `shiny`

### 4. Module Structure Template

Use this template when creating new modules:

```r
# Module description
# What this module does

box::use(
  shiny[...],
  bs4Dash[...],
  # Add other package imports here
)

#' Module UI
#' @param id Module namespace ID
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  # UI code here
}

#' Module Server
#' @param id Module namespace ID
#' @param ... Additional parameters
#' @export
server <- function(id, ...) {
  moduleServer(id, function(input, output, session) {
    # Server code here
  })
}
```

### 5. Testing Imports

Before committing changes:

1. Run the import verification script:
   ```r
   source("verify_imports.R")
   ```

2. Test the app:
   ```r
   shiny::runApp()
   ```

3. Check for console errors

### 6. Adding New Packages

When adding a new package:

1. Add it to `setup_renv.R` in the appropriate category
2. Run `renv::install("package_name")`
3. Update `renv.lock` with `renv::snapshot()`
4. Document the package purpose in code comments

### 7. Debugging Import Issues

If you encounter import errors:

1. Check the error message for the function name
2. Identify the source package:
   ```r
   # In R console
   ?functionName  # Shows which package it's from
   ```
3. Add to box::use import
4. Restart R session and test again

### 8. Performance Considerations

- Use `...` imports sparingly - they load all functions
- Prefer explicit imports for better code clarity
- Group related imports together
- Avoid circular dependencies between modules

## Code Review Checklist

Before submitting code:

- [ ] All functions have proper imports
- [ ] No "could not find function" errors
- [ ] App runs without console errors
- [ ] Import verification script passes
- [ ] New packages added to setup_renv.R
- [ ] Documentation updated if needed