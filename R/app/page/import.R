# Import page module
# Handles data import functionality

box::use(
  shiny[...],
  bs4Dash[...],
  ../mod/data_upload,
  ../mod/data_preview
)

#' Import page UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(
      width = 12,
      h2("Import Data", class = "page-header"),
      br()
    ),
    column(
      width = 12,
      data_upload$ui(ns("upload"))
    ),
    column(
      width = 12,
      br(),
      data_preview$ui(ns("preview"))
    )
  )
}

#' Import page server
#' @export
server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    # Handle data upload
    uploaded_data <- data_upload$server("upload")
    
    # Preview uploaded data
    data_preview$server("preview", uploaded_data)
    
    # Store imported data in app_data
    observe({
      req(uploaded_data())
      app_data$imported_data <- uploaded_data()
    })
  })
}