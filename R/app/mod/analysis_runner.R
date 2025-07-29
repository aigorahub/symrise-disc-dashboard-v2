# Analysis runner module

box::use(
  shiny[..., icon, updateNumericInput],
  bs4Dash[...],
  sensR
)

#' Analysis runner UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Analysis Parameters",
    status = "primary",
    solidHeader = FALSE,
    width = 12,
    style = "border-top: 3px solid var(--symrise-red);",
    
    fluidRow(
      column(
        width = 6,
        numericInput(
          ns("delta_threshold"),
          "Delta Threshold",
          value = 1.0,
          min = 0,
          max = 5,
          step = 0.1
        )
      ),
      column(
        width = 6,
        numericInput(
          ns("alpha_level"),
          "Significance Level (alpha value)",
          value = 0.05,
          min = 0.01,
          max = 0.10,
          step = 0.01
        )
      )
    ),
    
    fluidRow(
      column(
        width = 12,
        br(),
        actionButton(
          ns("run_analysis"),
          "Run Discrimination Analysis",
          class = "btn-primary btn-lg",
          icon = icon("play-circle"),
          style = "border-radius: 20px; padding: 10px 30px;"
        ),
        br(), br()
      )
    ),
    
    fluidRow(
      column(
        width = 12,
        uiOutput(ns("analysis_status"))
      )
    )
  )
}

#' Analysis runner server
#' @export
server <- function(id, design_params, imported_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Smart defaults for delta threshold and alpha based on test type and objective
    observe({
      req(imported_data())
      
      # Extract test info from imported data
      test_type <- imported_data()$test_type
      test_objective <- imported_data()$test_objective
      
      # Set smart defaults based on "Actual Standard" (these are examples, adjust as needed)
      if (test_objective == "similarity") {
        # Similarity tests typically use lower delta thresholds
        updateNumericInput(session, "delta_threshold", value = 0.5)
        updateNumericInput(session, "alpha_level", value = 0.10)
      } else {
        # Difference tests
        if (test_type %in% c("triangle", "tetrad")) {
          updateNumericInput(session, "delta_threshold", value = 1.0)
          updateNumericInput(session, "alpha_level", value = 0.05)
        } else if (test_type == "two_afc") {
          updateNumericInput(session, "delta_threshold", value = 0.75)
          updateNumericInput(session, "alpha_level", value = 0.05)
        } else if (test_type == "sod") {
          updateNumericInput(session, "delta_threshold", value = 1.5)
          updateNumericInput(session, "alpha_level", value = 0.05)
        }
      }
    })
    
    # Run analysis
    analysis_results <- eventReactive(input$run_analysis, {
      req(design_params(), imported_data())
      
      showNotification("Running analysis...", type = "message", duration = 2)
      
      # Extract data and parameters
      data_info <- imported_data()
      test_type <- data_info$test_type
      test_objective <- data_info$test_objective
      is_double <- data_info$is_double
      
      # Calculate confidence interval based on alpha
      # For two-sided test: CI = 1 - (2 * alpha)
      # For one-sided test: CI = 1 - alpha
      confidence_level <- 1 - (2 * input$alpha_level)
      
      if (is_double) {
        # Analyze both datasets for double tetrad
        data1 <- data_info$data_sets$test1
        data2 <- data_info$data_sets$test2
        
        # Placeholder analysis for both tests
        Sys.sleep(1.5) # Simulate longer processing for double
        
        results <- list(
          is_double = TRUE,
          test_type = "tetrad",
          original_type = "double_tetrad",
          test_objective = test_objective,
          test1_results = list(
            n_total = nrow(data1),
            d_prime = 1.23,
            p_value = 0.034,
            confidence_interval = c(0.89, 1.57),
            confidence_level = confidence_level,
            alpha = input$alpha_level,
            delta_threshold = input$delta_threshold
          ),
          test2_results = list(
            n_total = nrow(data2),
            d_prime = 0.98,
            p_value = 0.067,
            confidence_interval = c(0.65, 1.31),
            confidence_level = confidence_level,
            alpha = input$alpha_level,
            delta_threshold = input$delta_threshold
          ),
          timestamp = Sys.time()
        )
      } else {
        # Single test analysis
        data <- data_info$data_sets[[1]]
        
        # Placeholder analysis - replace with actual sensR analysis
        Sys.sleep(1) # Simulate processing
        
        results <- list(
          is_double = FALSE,
          n_total = nrow(data),
          test_type = test_type,
          test_objective = test_objective,
          d_prime = 1.23,
          p_value = 0.034,
          confidence_interval = c(0.89, 1.57),
          confidence_level = confidence_level,
          alpha = input$alpha_level,
          delta_threshold = input$delta_threshold,
          timestamp = Sys.time()
        )
      }
      
      showNotification("Analysis complete!", type = "success")
      
      results
    })
    
    # Display status
    output$analysis_status <- renderUI({
      if (is.null(analysis_results())) {
        return(NULL)
      }
      
      tags$div(
        class = "alert alert-success",
        tags$h5("Analysis completed successfully"),
        tags$p(paste("Timestamp:", analysis_results()$timestamp))
      )
    })
    
    # Return results
    analysis_results
  })
}