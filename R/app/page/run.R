# Run page module
# Handles discrimination test analysis

box::use(
  shiny[...],
  bs4Dash[...],
  ../mod/analysis_runner,
  ../mod/results_display,
  ../mod/report_generator
)

#' Run page UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(
      width = 12,
      h2("Run Analysis", class = "page-header"),
      br()
    ),
    column(
      width = 12,
      analysis_runner$ui(ns("analysis"))
    ),
    column(
      width = 12,
      br(),
      results_display$ui(ns("results"))
    ),
    column(
      width = 12,
      br(),
      report_generator$ui(ns("report"))
    )
  )
}

#' Run page server
#' @export
server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    # Run analysis when data is available
    analysis_results <- analysis_runner$server(
      "analysis",
      design_params = reactive(app_data$design_params),
      imported_data = reactive(app_data$imported_data)
    )
    
    # Display results
    results_display$server("results", analysis_results)
    
    # Generate reports
    report_generator$server("report", analysis_results)
    
    # Store results in app_data
    observe({
      req(analysis_results())
      app_data$analysis_results <- analysis_results()
    })
  })
}