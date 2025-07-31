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
      
      # Handle different data structures
      if (!is.null(data_info$is_double) && data_info$is_double) {
        # Double tetrad case
        display_data <- data_info$data_sets$test1
        
        showNotification(
          "Double Tetrad detected: Showing Test 1 data. Test 2 will be analyzed separately.",
          type = "message",
          duration = 5
        )
      } else if (!is.null(data_info$tidy_data)) {
        # Our processed data structure
        display_data <- data_info$tidy_data
      } else if (!is.null(data_info$data_sets) && length(data_info$data_sets) > 0) {
        # Other data structure
        display_data <- data_info$data_sets[[1]]
      } else {
        # Fallback
        showNotification("No data to preview", type = "warning", duration = 3)
        return(NULL)
      }
      
      # Create safe caption
      caption_text <- if (!is.null(data_info$is_double) && data_info$is_double) {
        "Double Tetrad Test 1 Data Preview"
      } else if (!is.null(data_info$test_type)) {
        paste(toupper(data_info$test_type), "Test Data Preview")
      } else {
        "Data Preview"
      }
      
      datatable(
        display_data,
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          dom = 'Bfrtip'
        ),
        class = 'table-striped table-bordered',
        caption = caption_text
      )
    })
  })
}