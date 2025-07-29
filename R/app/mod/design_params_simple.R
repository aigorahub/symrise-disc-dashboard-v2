# Simplified design parameters module
# Handles just the statistical parameters

box::use(
  shiny[...],
  bs4Dash[...]
)

#' Design parameters simple UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Statistical Parameters",
    status = "primary",
    solidHeader = FALSE,
    width = 12,
    collapsible = TRUE,
    style = "border-top: 3px solid var(--symrise-red);",
    
    fluidRow(
      column(
        width = 6,
        numericInput(
          ns("alpha"),
          "Significance Level (alpha value)",
          value = 0.10,  # Changed default to 0.10 to match original
          min = 0.01,
          max = 0.20,
          step = 0.01
        )
      ),
      column(
        width = 6,
        numericInput(
          ns("power"),
          "Desired Power (1-β)",
          value = 0.85,  # Changed default to 0.85 to match original
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

#' Design parameters simple server
#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Return reactive with all parameters
    reactive({
      list(
        alpha = input$alpha,
        power = input$power,
        effect_size = input$effect_size,
        overdispersion = input$overdispersion,
        gamma = if(input$overdispersion) input$gamma else NULL
      )
    })
  })
}