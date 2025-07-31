# Analysis runner module

box::use(
  shiny[..., icon, updateNumericInput],
  bs4Dash[...],
  ../../proc/discrimination_analysis
)

# Ensure sensR is available
if (!requireNamespace("sensR", quietly = TRUE)) {
  stop("sensR package is required but not installed")
}

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
      
      # Fix is_double if it's NULL or empty
      if (is.null(is_double) || length(is_double) == 0) {
        is_double <- FALSE
      }
      
      results <- tryCatch({
        if (test_type == "sod") {
          # Size of Difference analysis
          analysis_result <- discrimination_analysis$perform_sod_analysis(
            data = data_info,
            control_name = data_info$control_name,
            alpha_level = input$alpha_level,
            delta_threshold = input$delta_threshold
          )
          analysis_result$timestamp <- Sys.time()
          analysis_result
          
        } else if (is_double) {
          # Double tetrad analysis
          analysis_result <- discrimination_analysis$perform_double_tetrad_analysis(
            data = data_info,
            test_objective = test_objective,
            alpha_level = input$alpha_level,
            delta_threshold = input$delta_threshold
          )
          analysis_result$timestamp <- Sys.time()
          analysis_result
          
        } else {
          # Single discrimination test analysis
          analysis_result <- discrimination_analysis$perform_discrimination_test(
            data = data_info,
            test_type = test_type,
            test_objective = test_objective,
            alpha_level = input$alpha_level,
            delta_threshold = input$delta_threshold
          )
          analysis_result$timestamp <- Sys.time()
          analysis_result
        }
        
      }, error = function(e) {
        cat("Analysis error:", e$message, "\n")
        
        showNotification(
          paste("Analysis error:", e$message),
          type = "warning",
          duration = 10
        )
        
        # Return error result
        list(
          error = TRUE,
          error_message = e$message,
          test_type = test_type,
          test_objective = test_objective,
          timestamp = Sys.time()
        )
      })
      
      if (!is.null(results) && !isTRUE(results$error)) {
        showNotification("Analysis complete!", type = "message")
      }
      
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