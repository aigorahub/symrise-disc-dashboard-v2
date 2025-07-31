# Fixed data upload module
# Handles file uploads and processes discrimination test data

box::use(
  shiny[..., updateSelectInput],
  bs4Dash[...],
  readxl[read_excel],
  dplyr[group_by, summarize, `%>%`],
  ../../proc/data_processing,
  ../../proc/data_import_functions
)

# Add custom showToast function for compatibility with old code
showToast <- function(title, description = "", type = "default") {
  # Convert old toast types to Shiny notification types
  shiny_type <- switch(type,
    "success" = "message",
    "error" = "warning", 
    "warning" = "warning",
    "default"
  )
  
  message_text <- if (description == "") title else paste(title, description, sep = " ")
  showNotification(message_text, type = shiny_type, duration = 5)
}

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
        file_path <- input$file$datapath
        
        # Validate file extension
        if (!file_ext %in% c("xlsx", "xls", "csv")) {
          showToast("File Extension:", "The file extension is incorrect", "error")
          return(NULL)
        }
        
        # Process data based on test type using the appropriate function
        processed_data <- switch(input$test_type,
          "triangle" = data_import_functions$tidy_triangle(file_path),
          "tetrad" = data_import_functions$tidy_tetrad(file_path),
          "two_afc" = data_import_functions$tidy_two_afc_load_data(file_path),
          "duo_trio" = data_import_functions$tidy_triangle(file_path),  # Similar to triangle
          "sod" = {
            # For SoD, read the raw data first
            if (file_ext %in% c("xlsx", "xls")) {
              raw_data <- read_excel(file_path)
            } else {
              raw_data <- read.csv(file_path, stringsAsFactors = FALSE)
            }
            # Return raw data for SoD - will be processed later when control is selected
            list(tidy_data = raw_data, test_type = "sod")
          },
          {
            # Default: try to read as simple discrimination data
            if (file_ext %in% c("xlsx", "xls")) {
              data <- read_excel(file_path)
            } else {
              data <- read.csv(file_path, stringsAsFactors = FALSE)
            }
            list(tidy_data = data)
          }
        )
        
        if (is.null(processed_data) || is.null(processed_data$tidy_data) || nrow(processed_data$tidy_data) == 0) {
          showToast("Data Error:", "Uploaded file is empty or has no valid data", "error")
          return(NULL)
        }
        
        showToast("Congrats:", "File loaded Successfully.", "success")
        
        # Add metadata
        processed_data$test_type <- input$test_type
        processed_data$test_objective <- input$test_objective
        
        # Determine if this is a double tetrad test
        # Check if there are multiple replicates per panelist-product combination
        if (input$test_type == "tetrad" && !is.null(processed_data$tidy_data)) {
          # Count replicates per panelist-product combination
          tidy_data <- processed_data$tidy_data
          if ("Panelist" %in% names(tidy_data) && "Product" %in% names(tidy_data)) {
            replicate_counts <- tidy_data %>%
              group_by(Panelist, Product) %>%
              summarize(n_reps = n(), .groups = "drop")
            max_reps <- max(replicate_counts$n_reps, na.rm = TRUE)
            processed_data$is_double <- max_reps > 1
          } else {
            processed_data$is_double <- FALSE
          }
        } else {
          processed_data$is_double <- FALSE
        }
        
        processed_data
        
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
        showNotification(error_msg, type = "warning", duration = 10)
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
        if (!is.null(data$is_double) && data$is_double) {
          tagList(
            tags$p(paste("Double Tetrad data loaded")),
            tags$p(paste("Test 1:", nrow(data$data_sets$test1), "rows")),
            tags$p(paste("Test 2:", nrow(data$data_sets$test2), "rows"))
          )
        } else if (!is.null(data$tidy_data)) {
          # For our processed data structure
          tagList(
            tags$p(paste("Rows:", nrow(data$tidy_data))),
            if (!is.null(data$prod_labels)) {
              tags$p(paste("Product labels:", paste(data$prod_labels, collapse = ", ")))
            }
          )
        } else if (!is.null(data$data_sets)) {
          # For other data structures
          tags$p(paste("Rows:", nrow(data$data_sets[[1]])))
        } else {
          tags$p("Data loaded successfully")
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