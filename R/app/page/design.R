# Design page module
# Handles discrimination test design functionality

box::use(
  shiny[..., reactiveValues],
  bs4Dash[...],
  ../mod/design_header,
  ../mod/design_params_simple,
  ../mod/sample_size
)

#' Design page UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(
      width = 12,
      h2("Design Discrimination Test", class = "page-header"),
      br()
    ),
    column(
      width = 12,
      design_header$ui(ns("header"))
    ),
    column(
      width = 6,
      design_params_simple$ui(ns("params"))
    ),
    column(
      width = 6,
      sample_size$ui(ns("sample_size"))
    )
  )
}

#' Design page server
#' @export
server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    # Call sub-modules
    test_config <- design_header$server("header")
    params <- design_params_simple$server("params")
    
    # Combine test config and params
    combined_params <- reactive({
      # Use list concatenation to preserve structure
      config <- test_config()
      param_values <- params()
      
      list(
        test_type = config$test_type,
        test_objective = config$test_objective,
        alpha = param_values$alpha,
        power = param_values$power,
        effect_size = param_values$effect_size,
        overdispersion = param_values$overdispersion,
        gamma = param_values$gamma
      )
    })
    
    sample_size_results <- sample_size$server("sample_size", combined_params)
    
    # Store design parameters in app_data
    observe({
      app_data$design_params <- combined_params()
    })
  })
}