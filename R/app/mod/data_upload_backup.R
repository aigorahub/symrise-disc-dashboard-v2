# Data upload module

box::use(
  shiny[..., updateSelectInput],
  bs4Dash[...],
  readxl[read_excel],
  ../../proc/data_processing
)

#' Data upload UI
#' @export
ui <- function(id) {
  ns <- NS(id)
  
  box(
    title = "Test Configuration & Data Upload",
    status = "primary",
    solidHeader = FALSE,
    width = 12,
    style = "border-top: 3px solid var(--symrise-red);",
    
    # Test configuration section
    fluidRow(
      column(
        width = 6,
        selectInput(
          ns("test_type"),
          "Select Test Type",
          choices = c(
            "Triangle" = "triangle",
            "Tetrad" = "tetrad",
            "Double Tetrad" = "double_tetrad",
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
          "Select Test Objective",
          choices = c(
            "Similarity" = "similarity",
            "Difference" = "difference"
          ),
          selected = "similarity"
        )
      )
    ),
    
    hr(),
    
    # File upload section
    fluidRow(
      column(
        width = 12,
        h4("Upload Data File"),
        fileInput(
          ns("file"),
          "Choose Excel File",
          accept = c(".xlsx", ".xls"),
          buttonLabel = "Browse...",
          placeholder = "No file selected"
        ),
        
        tags$div(
          class = "alert alert-info",
          tags$h5("File Requirements:"),
          tags$ul(
            tags$li("Excel format (.xlsx or .xls)"),
            tags$li("First row should contain column headers"),
            tags$li("Required columns depend on test type")
          )
        )
      )
    )
  )
}

#' Data upload server
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
    
    # Handle file upload
    uploaded_data <- reactive({
      req(input$file)
      
      tryCatch({
        # Get file extension
        file_ext <- tolower(tools::file_ext(input$file$name))
        
        # Read file based on extension
        if (file_ext %in% c("xlsx", "xls")) {
          data <- read_excel(input$file$datapath)
        } else if (file_ext == "csv") {
          data <- read.csv(input$file$datapath, stringsAsFactors = FALSE)
        } else {
          stop("Please upload an Excel (.xlsx, .xls) or CSV (.csv) file")
        }
        
        # Basic validation
        if (nrow(data) == 0) {
          showNotification("Uploaded file is empty", type = "error")
          return(NULL)
        }
        
        showNotification("File uploaded successfully", type = "success")
        
        # Process the data based on test type
        processed_data <- data_processing$process_uploaded_data(
          data = data,
          test_type = input$test_type,
          test_objective = input$test_objective
        )
        
        # Validate the data
        if (processed_data$is_double) {
          # Validate both datasets for double tetrad
          validation1 <- data_processing$validate_test_data(
            processed_data$data_sets$test1,
            "tetrad"
          )
          validation2 <- data_processing$validate_test_data(
            processed_data$data_sets$test2,
            "tetrad"
          )
          
          if (!validation1$is_valid || !validation2$is_valid) {
            showNotification(
              "Warning: Some expected columns may be missing in the Double Tetrad data",
              type = "warning",
              duration = 5
            )
          }
        } else {
          # Validate single dataset
          validation <- data_processing$validate_test_data(
            processed_data$data_sets[[1]],
            input$test_type
          )
          
          if (!validation$is_valid && length(validation$missing_columns) > 0) {
            showNotification(
              paste("Warning: Missing expected columns:", 
                    paste(validation$missing_columns, collapse = ", ")),
              type = "warning",
              duration = 5
            )
          }
        }
        
        # Return processed data with all metadata
        processed_data
        
      }, error = function(e) {
        showNotification(
          paste("Error reading file:", e$message),
          type = "error",
          duration = 10
        )
        NULL
      })
    })
    
    # Return uploaded data with configuration
    uploaded_data
  })
}