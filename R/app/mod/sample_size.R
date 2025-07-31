# Sample size calculation module

box::use(
  shiny[..., icon],
  bs4Dash[...],
  sensR,
  ../../util/sensr_helpers
)

#' Sample size UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Sample Size Calculation",
    status = "primary",
    solidHeader = FALSE,
    width = 12,
    collapsible = TRUE,
    style = "border-top: 3px solid var(--symrise-red);",
    
    fluidRow(
      column(
        width = 12,
        actionButton(
          ns("calculate"),
          "Calculate Sample Size",
          class = "btn-primary",
          icon = icon("calculator"),
          style = "border-radius: 20px; padding: 10px 30px;"
        ),
        br(), br()
      )
    ),
    
    fluidRow(
      column(
        width = 12,
        uiOutput(ns("results"))
      )
    )
  )
}

#' Sample size server
#' @export
server <- function(id, params) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Calculate sample size when button clicked
    sample_size <- eventReactive(input$calculate, {
      req(params())
      p <- params()
      
      tryCatch({
        if (p$test_type == "sod") {
          # Size of Difference calculations using dod_power
          # For SoD, we need to calculate sample size from power
          # dod_power function: dod.power(d.prime, n, alpha)
          # We need to find n that gives us the desired power
          
          # Binary search for sample size
          n_min <- 10
          n_max <- 1000
          target_power <- p$power
          
          while (n_max - n_min > 1) {
            n_mid <- floor((n_min + n_max) / 2)
            current_power <- sensR::dod.power(
              d.prime = p$effect_size,
              n = n_mid,
              alpha = p$alpha
            )
            
            if (current_power < target_power) {
              n_min <- n_mid
            } else {
              n_max <- n_mid
            }
          }
          
          n <- n_max
          actual_power <- sensR::dod.power(
            d.prime = p$effect_size,
            n = n,
            alpha = p$alpha
          )
          
        } else if (p$test_type %in% c("triangle", "tetrad", "duo_trio", "two_afc")) {
          # Standard discrimination test calculations
          method_name <- switch(p$test_type,
            "triangle" = "triangle",
            "tetrad" = "tetrad",
            "duo_trio" = "duotrio",
            "two_afc" = "twoAFC"
          )
          
          # Try direct sensR call first (matching old dashboard exactly)
          # IMPORTANT: Old dashboard always uses test = "difference" for sample size calculation
          result <- tryCatch({
            sensR::d.primeSS(
              d.primeA = p$effect_size,
              target.power = p$power,
              alpha = p$alpha,
              test = "difference",  # Always use "difference" as per old dashboard
              method = method_name
            )
          }, error = function(e) {
            # If direct call fails, use helper function
            sensr_helpers$calculate_sample_size(
              d_prime = p$effect_size,
              power = p$power,
              alpha = p$alpha,
              test_obj = "difference",  # Always use "difference" as per old dashboard
              method = method_name
            )
          })
          
          n <- ceiling(result)
          actual_power <- p$power
          
        } else {
          # Default calculation
          n <- ceiling(50 * (1 + p$effect_size))
          actual_power <- p$power
        }
        
        list(
          n = n,
          test_type = p$test_type,
          test_objective = p$test_objective,
          alpha = p$alpha,
          power = actual_power,
          effect_size = p$effect_size,
          calculation_successful = TRUE
        )
        
      }, error = function(e) {
        # Enhanced error logging
        error_details <- paste(
          "Error details:",
          "\n- Test type:", p$test_type,
          "\n- Test objective:", p$test_objective,
          "\n- Alpha:", p$alpha,
          "\n- Power:", p$power,
          "\n- Effect size:", p$effect_size,
          "\n- Error message:", e$message
        )
        
        cat(error_details, "\n")  # Log to console
        
        showNotification(
          paste("Error in calculation:", e$message),
          type = "error",
          duration = 10
        )
        
        list(
          n = NA,
          test_type = p$test_type,
          test_objective = p$test_objective,
          alpha = p$alpha,
          power = p$power,
          effect_size = p$effect_size,
          calculation_successful = FALSE,
          error_message = e$message,
          error_details = error_details
        )
      })
    })
    
    # Display results
    output$results <- renderUI({
      req(sample_size())
      s <- sample_size()
      
      if (!s$calculation_successful) {
        return(
          tags$div(
            class = "alert alert-danger",
            tags$h4("Calculation Error"),
            tags$p(s$error_message)
          )
        )
      }
      
      # Format test type for display
      test_type_display <- switch(s$test_type,
        "triangle" = "Triangle",
        "tetrad" = "Tetrad",
        "duo_trio" = "Duo-Trio",
        "two_afc" = "2-AFC",
        "sod" = "Size of Difference (SoD)",
        s$test_type
      )
      
      tagList(
        h4("Required Sample Size"),
        tags$div(
          class = "alert alert-primary",
          tags$h3(s$n, " participants"),
          tags$p(
            "Based on:",
            tags$ul(
              tags$li(paste("Test type:", test_type_display)),
              if (!is.null(s$test_objective)) tags$li(paste("Test objective:", s$test_objective)),
              tags$li(paste("Significance level (α):", s$alpha)),
              tags$li(paste("Power (1-β):", round(s$power, 3))),
              tags$li(paste("Effect size (d'):", s$effect_size))
            )
          ),
          if (s$test_type == "sod") {
            tags$p(
              tags$small(
                tags$em("Note: Size of Difference test always uses 'Difference' objective")
              )
            )
          }
        )
      )
    })
    
    # Return the calculated sample size
    sample_size
  })
}