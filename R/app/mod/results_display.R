# Results display module

box::use(
  shiny[..., icon],
  bs4Dash[..., valueBox, valueBoxOutput, renderValueBox],
  ggplot2[...],
  plotly[ggplotly, plotlyOutput, renderPlotly]
)

#' Results display UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Analysis Results",
    status = "success",
    solidHeader = FALSE,
    width = 12,
    collapsible = TRUE,
    collapsed = TRUE,
    style = "border-top: 3px solid var(--symrise-red);",
    
    # Dynamic UI that will show single or double results
    uiOutput(ns("results_content"))
  )
}

#' Results display server
#' @export
server <- function(id, analysis_results) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Render dynamic UI based on whether results are single or double
    output$results_content <- renderUI({
      req(analysis_results())
      results <- analysis_results()
      
      if (results$is_double) {
        # Double tetrad - show results for both tests
        tagList(
          h4("Double Tetrad Results", style = "color: var(--symrise-red);"),
          br(),
          
          # Test 1 Results
          h5("Test 1 Results"),
          fluidRow(
            column(
              width = 6,
              valueBoxOutput(ns("d_prime_box_1"))
            ),
            column(
              width = 6,
              valueBoxOutput(ns("p_value_box_1"))
            )
          ),
          fluidRow(
            column(
              width = 12,
              plotlyOutput(ns("results_plot_1"))
            )
          ),
          
          hr(),
          
          # Test 2 Results
          h5("Test 2 Results"),
          fluidRow(
            column(
              width = 6,
              valueBoxOutput(ns("d_prime_box_2"))
            ),
            column(
              width = 6,
              valueBoxOutput(ns("p_value_box_2"))
            )
          ),
          fluidRow(
            column(
              width = 12,
              plotlyOutput(ns("results_plot_2"))
            )
          )
        )
      } else {
        # Single test results
        tagList(
          fluidRow(
            column(
              width = 6,
              valueBoxOutput(ns("d_prime_box"))
            ),
            column(
              width = 6,
              valueBoxOutput(ns("p_value_box"))
            )
          ),
          fluidRow(
            column(
              width = 12,
              plotlyOutput(ns("results_plot"))
            )
          )
        )
      }
    })
    
    # Helper function to create value box
    create_d_prime_box <- function(results_data) {
      valueBox(
        value = round(results_data$d_prime, 2),
        subtitle = "d-prime",
        icon = icon("chart-line"),
        color = "primary"
      )
    }
    
    create_p_value_box <- function(results_data) {
      valueBox(
        value = format(results_data$p_value, digits = 3),
        subtitle = "p-value",
        icon = icon("calculator"),
        color = if(results_data$p_value < 0.05) "success" else "warning"
      )
    }
    
    # Helper function to create plot
    create_ci_plot <- function(results_data, title_suffix = "") {
      p <- ggplot(data.frame(
        estimate = results_data$d_prime,
        lower = results_data$confidence_interval[1],
        upper = results_data$confidence_interval[2]
      )) +
        geom_point(aes(x = 1, y = estimate), size = 4, color = "#c51718") +
        geom_errorbar(
          aes(x = 1, ymin = lower, ymax = upper),
          width = 0.1,
          color = "#c51718"
        ) +
        geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
        scale_x_continuous(limits = c(0.5, 1.5), breaks = NULL) +
        labs(
          title = paste0("d-prime Estimate with ", 
                        round(results_data$confidence_level * 100), 
                        "% Confidence Interval", title_suffix),
          y = "d-prime",
          x = ""
        ) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_blank()
        )
      
      ggplotly(p)
    }
    
    # Single test outputs
    output$d_prime_box <- renderValueBox({
      req(analysis_results())
      create_d_prime_box(analysis_results())
    })
    
    output$p_value_box <- renderValueBox({
      req(analysis_results())
      create_p_value_box(analysis_results())
    })
    
    output$results_plot <- renderPlotly({
      req(analysis_results())
      create_ci_plot(analysis_results())
    })
    
    # Double tetrad outputs - Test 1
    output$d_prime_box_1 <- renderValueBox({
      req(analysis_results())
      results <- analysis_results()
      req(results$is_double)
      create_d_prime_box(results$test1_results)
    })
    
    output$p_value_box_1 <- renderValueBox({
      req(analysis_results())
      results <- analysis_results()
      req(results$is_double)
      create_p_value_box(results$test1_results)
    })
    
    output$results_plot_1 <- renderPlotly({
      req(analysis_results())
      results <- analysis_results()
      req(results$is_double)
      create_ci_plot(results$test1_results, " - Test 1")
    })
    
    # Double tetrad outputs - Test 2
    output$d_prime_box_2 <- renderValueBox({
      req(analysis_results())
      results <- analysis_results()
      req(results$is_double)
      create_d_prime_box(results$test2_results)
    })
    
    output$p_value_box_2 <- renderValueBox({
      req(analysis_results())
      results <- analysis_results()
      req(results$is_double)
      create_p_value_box(results$test2_results)
    })
    
    output$results_plot_2 <- renderPlotly({
      req(analysis_results())
      results <- analysis_results()
      req(results$is_double)
      create_ci_plot(results$test2_results, " - Test 2")
    })
  })
}