# Design parameters module
# Handles discrimination test parameter configuration

box::use(
  shiny[..., updateSelectInput],
  bs4Dash[...]
)

#' Design parameters UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Test Parameters",
    status = "primary",
    solidHeader = TRUE,
    width = 12,
    collapsible = TRUE,
    
    fluidRow(
      column(
        width = 6,
        selectInput(
          ns("test_type"),
          "Test Type",
          choices = c(
            "Triangle" = "triangle",
            "Tetrad" = "tetrad", 
            "Duo-Trio" = "duo_trio",
            "2-AFC" = "two_afc",
            "Size of Difference (SoD)" = "sod"
          ),
          selected = "triangle"
        )
      ),
      column(
        width = 6,
        selectInput(
          ns("test_objective"),
          "Test Objective",
          choices = c(
            "Similarity" = "similarity",
            "Difference" = "difference"
          ),
          selected = "similarity"
        )
      )
    ),
    
    fluidRow(
      column(
        width = 6,
        numericInput(
          ns("alpha"),
          "Significance Level (alpha value)",
          value = 0.05,
          min = 0.01,
          max = 0.10,
          step = 0.01
        )
      ),
      column(
        width = 6,
        numericInput(
          ns("power"),
          "Desired Power (1-β)",
          value = 0.80,
          min = 0.50,
          max = 0.99,
          step = 0.01
        )
      )
    ),
    
    fluidRow(
      column(
        width = 6,
        numericInput(
          ns("effect_size"),
          "Effect Size (d')",
          value = 1.0,
          min = 0.1,
          max = 3.0,
          step = 0.1
        )
      ),
      column(
        width = 6,
        checkboxInput(
          ns("overdispersion"),
          "Account for Overdispersion",
          value = FALSE
        )
      )
    ),
    
    conditionalPanel(
      condition = paste0("input['", ns("overdispersion"), "']"),
      fluidRow(
        column(
          width = 12,
          numericInput(
            ns("gamma"),
            "Overdispersion Parameter (γ)",
            value = 0.1,
            min = 0,
            max = 1,
            step = 0.01
          )
        )
      )
    )
  )
}

#' Design parameters server
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
    
    # Return reactive with all parameters
    reactive({
      list(
        test_type = input$test_type,
        test_objective = input$test_objective,
        alpha = input$alpha,
        power = input$power,
        effect_size = input$effect_size,
        overdispersion = input$overdispersion,
        gamma = if(input$overdispersion) input$gamma else NULL
      )
    })
  })
}