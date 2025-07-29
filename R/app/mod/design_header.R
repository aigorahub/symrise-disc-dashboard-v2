# Design header module
# Modern header with test type and objective selection

box::use(
  shiny[..., updateSelectInput],
  bs4Dash[...]
)

#' Design header UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  tags$div(
    class = "design-header-zone",
    style = "background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;",
    fluidRow(
      column(
        width = 12,
        h3("Test Configuration", style = "margin-top: 0; color: var(--symrise-red);")
      )
    ),
    fluidRow(
      column(
        width = 6,
        selectInput(
          ns("test_type"),
          "Select Test Type",
          choices = c(
            "Triangle" = "triangle",
            "Tetrad" = "tetrad", 
            "Duo-Trio" = "duo_trio",
            "2-AFC" = "two_afc",
            "Size of Difference (SoD)" = "sod"
          ),
          selected = "triangle",
          width = "100%"
        )
      ),
      column(
        width = 6,
        selectInput(
          ns("test_objective"),
          "Select Test Objective",
          choices = c(
            "Similarity" = "similarity",
            "Difference" = "difference"
          ),
          selected = "similarity",
          width = "100%"
        )
      )
    )
  )
}

#' Design header server
#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Lock test objective to "Difference" when SoD is selected
    observe({
      if (input$test_type == "sod") {
        updateSelectInput(
          session, 
          "test_objective", 
          selected = "difference",
          choices = c("Difference" = "difference")
        )
      } else {
        updateSelectInput(
          session, 
          "test_objective",
          choices = c(
            "Similarity" = "similarity",
            "Difference" = "difference"
          )
        )
      }
    })
    
    # Return reactive with test configuration
    reactive({
      list(
        test_type = input$test_type,
        test_objective = input$test_objective
      )
    })
  })
}