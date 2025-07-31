# Results display module

box::use(
  shiny[..., icon],
  bs4Dash[..., valueBox, valueBoxOutput, renderValueBox],
  ggplot2[...],
  plotly[ggplotly, plotlyOutput, renderPlotly],
  ../../vis/panel_performance
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
    
    # Display results
    output$results_content <- renderUI({
      req(analysis_results())
      results <- analysis_results()
      
      # Check for errors
      if (!is.null(results$error) && results$error) {
        return(
          tags$div(
            class = "alert alert-danger",
            tags$h5("Analysis Error"),
            tags$p(results$error_message)
          )
        )
      }
      
      if (results$test_type == "sod") {
        # Display SoD results
        tagList(
          h4("Size of Difference Results"),
          tags$p(paste("Control product:", results$control_product)),
          tags$div(
            class = "table-responsive",
            tags$table(
              class = "table table-bordered",
              tags$thead(
                tags$tr(
                  tags$th("Test Product"),
                  tags$th("d'"),
                  tags$th("90% CI"),
                  tags$th("p-value"),
                  tags$th("Significant?")
                )
              ),
              tags$tbody(
                lapply(names(results$test_results), function(prod) {
                  res <- results$test_results[[prod]]
                  tags$tr(
                    tags$td(prod),
                    tags$td(sprintf("%.2f", res$d_prime)),
                    tags$td(sprintf("[%.2f, %.2f]", res$ci_lower, res$ci_upper)),
                    tags$td(sprintf("%.3f", res$p_value)),
                    tags$td(if (res$is_significant) "Yes" else "No")
                  )
                })
              )
            )
          )
        )
      } else if (!is.null(results$is_double) && results$is_double) {
        # Display double tetrad results
        tagList(
          h4("Double Tetrad Results"),
          fluidRow(
            column(
              width = 6,
              h5("Test 1"),
              tags$div(
                class = "info-box",
                tags$p(paste("Correct:", results$test1_results$num_correct, "of", results$test1_results$num_total)),
                tags$p(paste("d':", sprintf("%.2f", results$test1_results$d_prime))),
                tags$p(paste("90% CI: [", 
                            sprintf("%.2f", results$test1_results$ci_lower),
                            ", ",
                            sprintf("%.2f", results$test1_results$ci_upper),
                            "]", sep = "")),
                tags$p(paste("p-value:", sprintf("%.3f", results$test1_results$p_value))),
                tags$p(
                  "Result: ",
                  tags$strong(
                    if (results$test1_results$is_significant) "Significant" else "Not significant",
                    style = paste0("color: ", if (results$test1_results$is_significant) "green" else "gray")
                  )
                )
              )
            ),
            column(
              width = 6,
              h5("Test 2"),
              tags$div(
                class = "info-box",
                tags$p(paste("Correct:", results$test2_results$num_correct, "of", results$test2_results$num_total)),
                tags$p(paste("d':", sprintf("%.2f", results$test2_results$d_prime))),
                tags$p(paste("90% CI: [", 
                            sprintf("%.2f", results$test2_results$ci_lower),
                            ", ",
                            sprintf("%.2f", results$test2_results$ci_upper),
                            "]", sep = "")),
                tags$p(paste("p-value:", sprintf("%.3f", results$test2_results$p_value))),
                tags$p(
                  "Result: ",
                  tags$strong(
                    if (results$test2_results$is_significant) "Significant" else "Not significant",
                    style = paste0("color: ", if (results$test2_results$is_significant) "green" else "gray")
                  )
                )
              )
            )
          )
        )
      } else {
        # Display single test results
        tagList(
          h4("Discrimination Test Results"),
          fluidRow(
            column(
              width = 6,
              tags$div(
                class = "info-box",
                tags$p(
                  tags$strong("Test type: "),
                  switch(results$test_type,
                    "triangle" = "Triangle",
                    "tetrad" = "Tetrad",
                    "duo_trio" = "Duo-Trio",
                    "two_afc" = "2-AFC",
                    results$test_type
                  )
                ),
                tags$p(tags$strong("Test objective: "), results$test_objective),
                tags$p(
                  tags$strong("Results: "),
                  paste(results$num_correct, "correct out of", results$num_total)
                ),
                tags$p(
                  tags$strong("d': "),
                  sprintf("%.2f", results$d_prime)
                ),
                tags$p(
                  tags$strong("90% CI: "),
                  sprintf("[%.2f, %.2f]", results$ci_lower, results$ci_upper)
                ),
                tags$p(
                  tags$strong("p-value: "),
                  sprintf("%.3f", results$p_value)
                ),
                tags$p(
                  tags$strong("Power: "),
                  sprintf("%.1f%%", results$power * 100)
                ),
                tags$hr(),
                tags$p(
                  "Result is ",
                  tags$strong(
                    if (results$is_significant) "significant" else "not significant",
                    style = paste0("color: ", if (results$is_significant) "green" else "gray")
                  ),
                  sprintf(" at α = %.2f", results$alpha_level)
                ),
                if (results$test_objective == "similarity") {
                  tags$p(
                    "Meets similarity criterion: ",
                    tags$strong(
                      if (results$meets_criteria) "Yes" else "No",
                      style = paste0("color: ", if (results$meets_criteria) "green" else "red")
                    ),
                    sprintf(" (CI upper bound < %.1f)", results$delta_threshold)
                  )
                } else {
                  tags$p(
                    "Products are ",
                    tags$strong(
                      if (results$is_significant) "different" else "not detectably different"
                    )
                  )
                },
                if (!is.na(results$overdispersion_p)) {
                  tags$p(
                    "Overdispersion ",
                    tags$strong(
                      if (results$overdispersion_detected) "detected" else "not detected"
                    ),
                    sprintf(" (p = %.3f)", results$overdispersion_p)
                  )
                }
              )
            ),
            column(
              width = 6,
              plotlyOutput(ns("traffic_light_plot"))
            )
          ),
          hr(),
          h5("Panel Performance"),
          fluidRow(
            column(
              width = 12,
              plotlyOutput(ns("panel_heatmap"))
            )
          ),
          if (!is.null(results$panel_data)) {
            fluidRow(
              column(
                width = 12,
                br(),
                plotlyOutput(ns("correct_answers_plot"))
              )
            )
          }
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
        lower = results_data$ci_lower,
        upper = results_data$ci_upper
      )) +
        geom_point(aes(x = 1, y = estimate), size = 4, color = "#c51718") +
        geom_errorbar(
          aes(x = 1, ymin = lower, ymax = upper),
          width = 0.1,
          color = "#c51718"
        ) +
        geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
        geom_hline(yintercept = results_data$delta_threshold, linetype = "dashed", color = "red", alpha = 0.5) +
        scale_x_continuous(limits = c(0.5, 1.5), breaks = NULL) +
        labs(
          title = paste0("d-prime Estimate with 90% Confidence Interval", title_suffix),
          y = "d-prime",
          x = ""
        ) +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_blank()
        ) +
        annotate("text", x = 1.4, y = results_data$delta_threshold, 
                label = paste("δ =", results_data$delta_threshold), 
                color = "red", size = 3)
      
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
    
    # Traffic light plot
    output$traffic_light_plot <- renderPlotly({
      req(analysis_results())
      results <- analysis_results()
      
      if (!is.null(results$error) && results$error) return(NULL)
      
      p <- panel_performance$create_traffic_light(results)
      ggplotly(p) %>%
        layout(
          showlegend = FALSE,
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE)
        )
    })
    
    # Panel performance heatmap
    output$panel_heatmap <- renderPlotly({
      req(analysis_results())
      results <- analysis_results()
      
      if (!is.null(results$error) && results$error) return(NULL)
      if (is.null(results$panel_data)) return(NULL)
      
      overdispersion_info <- list(
        detected = results$overdispersion_detected,
        p_value = results$overdispersion_p
      )
      
      p <- panel_performance$create_panel_heatmap(
        results$panel_data,
        results$test_type,
        overdispersion_info
      )
      
      ggplotly(p)
    })
    
    # Correct answers plot
    output$correct_answers_plot <- renderPlotly({
      req(analysis_results())
      results <- analysis_results()
      
      if (!is.null(results$error) && results$error) return(NULL)
      if (is.null(results$panel_data)) return(NULL)
      if (results$test_type == "sod") return(NULL)
      
      p <- panel_performance$create_correct_answers_summary(
        results$panel_data,
        results$test_type
      )
      
      if (!is.null(p)) {
        ggplotly(p)
      }
    })
  })
}