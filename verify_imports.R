# Import verification script
# This script checks that all required packages and functions are available

cat("=== Symrise Dashboard Import Verification ===\n\n")

# List of required packages and their key functions
required_imports <- list(
  shiny = c("shinyApp", "NS", "moduleServer", "reactive", "observe", "req", 
            "renderUI", "uiOutput", "actionButton", "selectInput", "numericInput",
            "fileInput", "downloadButton", "downloadHandler", "showNotification",
            "fluidRow", "column", "br", "tags", "h2", "h4", "tagList", "icon",
            "eventReactive", "reactiveValues", "tabItems", "tabItem", "conditionalPanel",
            "checkboxInput"),
  bs4Dash = c("dashboardPage", "dashboardHeader", "dashboardSidebar", "dashboardBody",
              "dashboardFooter", "sidebarMenu", "menuItem", "box", "valueBox",
              "valueBoxOutput", "renderValueBox"),
  shinyjs = c("useShinyjs"),
  shinyWidgets = c("pickerInput", "switchInput"),
  DT = c("datatable", "DTOutput", "renderDT"),
  box = c("use"),
  tidyverse = c("mutate", "filter", "select", "arrange", "group_by", "summarise"),
  `data.table` = c("data.table", "fread"),
  readxl = c("read_excel"),
  openxlsx = c("write.xlsx"),
  ggplot2 = c("ggplot", "aes", "geom_point", "geom_bar", "theme_minimal"),
  plotly = c("ggplotly", "plotlyOutput", "renderPlotly"),
  viridis = c("scale_color_viridis"),
  patchwork = c("plot_layout"),
  FactoMineR = c("PCA"),
  SensoMineR = c("panellipse"),
  sensR = c("discrim", "d.primePwr"),
  lme4 = c("lmer", "glmer"),
  flextable = c("flextable"),
  officer = c("read_docx", "read_pptx", "body_add_par"),
  magrittr = c("%>%")
)

# Check each package
all_good <- TRUE

for (pkg_name in names(required_imports)) {
  cat(sprintf("\nChecking %s...\n", pkg_name))
  
  if (!requireNamespace(pkg_name, quietly = TRUE)) {
    cat(sprintf("  ❌ Package '%s' is NOT installed\n", pkg_name))
    all_good <- FALSE
  } else {
    cat(sprintf("  ✓ Package '%s' is installed\n", pkg_name))
    
    # Check specific functions
    missing_funs <- character()
    for (fun in required_imports[[pkg_name]]) {
      tryCatch({
        # Try to get the function
        if (pkg_name == "magrittr" && fun == "%>%") {
          # Special handling for pipe operator
          if (!exists("%>%", where = asNamespace("magrittr"))) {
            missing_funs <- c(missing_funs, fun)
          }
        } else {
          get(fun, asNamespace(pkg_name))
        }
      }, error = function(e) {
        missing_funs <<- c(missing_funs, fun)
      })
    }
    
    if (length(missing_funs) > 0) {
      cat(sprintf("  ⚠️  Missing functions: %s\n", paste(missing_funs, collapse = ", ")))
      all_good <- FALSE
    }
  }
}

cat("\n" , strrep("=", 50), "\n")
if (all_good) {
  cat("✅ All required packages and functions are available!\n")
} else {
  cat("❌ Some packages or functions are missing.\n")
  cat("   Please run: source('setup_renv.R')\n")
}

# Additional check for box module loading
cat("\n=== Testing Box Module Loading ===\n")
tryCatch({
  box::use(R/config)
  cat("✓ Box modules can be loaded successfully\n")
}, error = function(e) {
  cat("❌ Error loading box modules:\n")
  print(e)
})

cat("\n=== Import verification complete ===\n")