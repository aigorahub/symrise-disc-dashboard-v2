# Data preview module

box::use(
  shiny[...],
  bs4Dash[...],
  DT[...],
  dplyr[...]
)

#' Data preview UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Data Preview",
    status = "primary",
    solidHeader = FALSE,
    width = 12,
    collapsible = TRUE,
    collapsed = TRUE,
    style = "border-top: 3px solid var(--symrise-red);",
    
    DTOutput(ns("preview_table"))
  )
}

#' Data preview server
#' @export
server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    # Display data preview
    output$preview_table <- renderDT({
      req(data())
      data_info <- data()
      
      # Handle double tetrad - show first dataset with note
      if (data_info$is_double) {
        display_data <- data_info$data_sets$test1
        
        showNotification(
          "Double Tetrad detected: Showing Test 1 data. Test 2 will be analyzed separately.",
          type = "info",
          duration = 5
        )
      } else {
        # Single dataset
        display_data <- data_info$data_sets[[1]]
      }
      
      datatable(
        display_data,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          dom = 'Bfrtip'
        ),
        class = 'table-striped table-bordered',
        caption = if (data_info$is_double) {
          "Double Tetrad Test 1 Data Preview"
        } else {
          paste(data_info$test_type, "Test Data Preview")
        }
      )
    })
  })
}