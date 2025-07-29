# Report generator module

box::use(
  shiny[...],
  bs4Dash[...],
  officer[...],
  flextable[...],
  magrittr[`%>%`]
)

#' Report generator UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Generate Report",
    status = "info",
    solidHeader = FALSE,
    width = 12,
    collapsible = TRUE,
    collapsed = TRUE,
    style = "border-top: 3px solid var(--symrise-red);",
    
    fluidRow(
      column(
        width = 12,
        p("Generate a PowerPoint presentation with your analysis results."),
        br(),
        downloadButton(
          ns("make_report"),
          "Make Report",
          class = "btn-primary btn-lg",
          style = "border-radius: 20px; padding: 10px 30px;"
        )
      )
    )
  )
}

#' Report generator server
#' @export
server <- function(id, analysis_results) {
  moduleServer(id, function(input, output, session) {
    # Generate PowerPoint report
    output$make_report <- downloadHandler(
      filename = function() {
        paste0(
          "discrimination_test_report_",
          format(Sys.Date(), "%Y%m%d"),
          ".pptx"
        )
      },
      content = function(file) {
        req(analysis_results())
        results <- analysis_results()
        
        # Create PowerPoint presentation
        pres <- read_pptx()
        
        # Slide 1: Main results summary
        pres <- pres %>%
          add_slide(layout = "Title and Content", master = "Office Theme") %>%
          ph_with(
              value = "Discrimination Test Results",
              location = ph_location_type(type = "title")
          ) %>%
          ph_with(
            value = paste(
              "Test Type: ", results$test_type, "\n",
              "Test Objective: ", results$test_objective, "\n",
              "Sample Size: ", results$n_total, "\n",
              "d-prime: ", round(results$d_prime, 3), "\n",
              "p-value: ", format(results$p_value, digits = 3), "\n",
              "Confidence Interval (", round(results$confidence_level * 100), "%): [",
              round(results$confidence_interval[1], 3), ", ",
              round(results$confidence_interval[2], 3), "]\n",
              "Alpha Level: ", results$alpha, "\n",
              "Delta Threshold: ", results$delta_threshold,
              sep = ""
            ),
            location = ph_location_type(type = "body")
          )
        
        # Slide 2: Comments slide
        pres <- pres %>%
          add_slide(layout = "Title and Content", master = "Office Theme") %>%
          ph_with(
            value = "Comments",
            location = ph_location_type(type = "title")
          ) %>%
          ph_with(
            value = "Add your comments here...",
            location = ph_location_type(type = "body")
          )
        
        print(pres, target = file)
      }
    )
  })
}