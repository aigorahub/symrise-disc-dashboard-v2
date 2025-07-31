# Fixed data upload module
# Handles file uploads and processes discrimination test data

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
    title = "Data Import",
    status = "primary",
    solidHeader = FALSE,
    width = 12,
    collapsible = TRUE,
    style = "border-top: 3px solid var(--symrise-red);",
    
    fluidRow(
      column(
        width = 4,
        selectInput(
          ns("test_type"),
          "Test Type",
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
        width = 4,
        selectInput(
          ns("test_objective"),
          "Test Objective",
          choices = c(
            "Similarity" = "similarity",
            "Difference" = "difference"
          ),
          selected = "similarity"
        )
      ),
      column(
        width = 4,
        conditionalPanel(
          condition = paste0("input['", ns("test_type"), "'] == 'sod'"),
          selectInput(
            ns("control_product"),
            "Control Product",
            choices = c("Select after upload" = "")
          )
        )
      )
    ),
    
    fluidRow(
      column(
        width = 12,
        fileInput(
          ns("file"),
          "Choose File",
          accept = c(".xlsx", ".xls", ".csv"),
          placeholder = "Select Excel or CSV file"
        )
      )
    ),
    
    fluidRow(
      column(
        width = 12,
        uiOutput(ns("upload_status"))
      )
    )
  )
}

#' Data upload server
#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Lock test objective to "difference" when SoD is selected
    observe({
      if (input$test_type == "sod") {
        updateSelectInput(session, "test_objective", selected = "difference")
      }
    })
    
    # Handle file upload
    uploaded_data <- reactive({
      req(input$file)
      
      tryCatch({
        # Get file extension
        file_ext <- tolower(tools::file_ext(input$file$name))
        
        # Read file based on extension
        data <- NULL
        if (file_ext %in% c("xlsx", "xls")) {
          data <- read_excel(input$file$datapath)
        } else if (file_ext == "csv") {
          data <- read.csv(input$file$datapath, stringsAsFactors = FALSE)
        } else {
          stop("Please upload an Excel (.xlsx, .xls) or CSV (.csv) file")
        }
        
        # Basic validation
        if (is.null(data) || nrow(data) == 0) {
          showNotification("Uploaded file is empty", type = "error", duration = 5)
          return(NULL)
        }
        
        showNotification("File uploaded successfully", type = "success", duration = 3)
        
        # Process the data based on test type
        processed_data <- data_processing$process_uploaded_data(
          data = data,
          test_type = input$test_type,
          test_objective = input$test_objective
        )
        
        # Update control product choices for SoD
        if (input$test_type == "sod" && !is.null(processed_data)) {
          products <- unique(data$Product)
          if (length(products) > 0) {
            updateSelectInput(
              session, 
              "control_product",
              choices = products,
              selected = products[1]
            )
          }
        }
        
        # Return processed data with all metadata
        processed_data
        
      }, error = function(e) {
        error_msg <- paste("Error reading file:", e$message)
        showNotification(error_msg, type = "error", duration = 10)
        cat("Upload error:", error_msg, "\n")
        NULL
      })
    })
    
    # Display upload status
    output$upload_status <- renderUI({
      data <- uploaded_data()
      if (is.null(data)) return(NULL)
      
      tags$div(
        class = "alert alert-info",
        tags$h5("Data Summary"),
        if (data$is_double) {
          tagList(
            tags$p(paste("Double Tetrad data loaded")),
            tags$p(paste("Test 1:", nrow(data$data_sets$test1), "rows")),
            tags$p(paste("Test 2:", nrow(data$data_sets$test2), "rows"))
          )
        } else {
          tags$p(paste("Rows:", nrow(data$data_sets[[1]])))
        },
        tags$p(paste("Test type:", input$test_type)),
        tags$p(paste("Test objective:", input$test_objective))
      )
    })
    
    # Return uploaded data with configuration
    reactive({
      data <- uploaded_data()
      if (is.null(data)) return(NULL)
      
      # Add configuration to the data
      data$test_type <- input$test_type
      data$test_objective <- input$test_objective
      if (input$test_type == "sod") {
        data$control_name <- input$control_product
      }
      
      data
    })
  })
}