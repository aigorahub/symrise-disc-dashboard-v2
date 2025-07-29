# Core application module
# Orchestrates UI and server components

box::use(
  shiny[..., reactiveValues, tags, icon],
  bs4Dash[..., dashboardPage, dashboardHeader, dashboardSidebar, dashboardBody, 
          dashboardFooter, sidebarMenu, menuItem, tabItems, tabItem, dropdownMenu],
  shinyjs,
  ./page/design,
  ./page/import,
  ./page/run,
  ../config
)

# Define page specifications
pages <- list(
  design = list(
    id = "design",
    label = "DESIGN",
    icon = icon("pencil-ruler"),
    ui_fun = design$ui,
    server_fun = design$server
  ),
  import = list(
    id = "import", 
    label = "IMPORT",
    icon = icon("upload"),
    ui_fun = import$ui,
    server_fun = import$server
  ),
  run = list(
    id = "run",
    label = "RUN",
    icon = icon("play"),
    ui_fun = run$ui,
    server_fun = run$server
  )
)

#' Main UI function
#' @export
ui <- function() {
  dashboardPage(
    header = dashboardHeader(
      title = tagList(
        config$get_logo(),
        span(config$get_app_name(), style = "font-size: 16px;")
      ),
      controlbarIcon = icon("sun"),
      rightUi = tagList(
        dropdownMenu(
          type = "tasks",
          icon = icon("moon"),
          badgeStatus = NULL,
          headerText = "Dark Mode",
          .list = list(
            tags$li(
              tags$a(
                href = "#",
                onclick = "document.body.classList.toggle('dark-mode'); return false;",
                tags$i(class = "fas fa-adjust"),
                "Toggle Dark Mode"
              )
            )
          )
        )
      )
    ),
    sidebar = dashboardSidebar(
      sidebarMenu(
        id = "sidebar_menu",
        lapply(pages, function(page) {
          menuItem(
            text = page$label,
            tabName = page$id,
            icon = page$icon
          )
        })
      )
    ),
    body = dashboardBody(
      # Include shinyjs
      shinyjs::useShinyjs(),
      
      # Include custom CSS and JS
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "css/modern-ui.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "css/dark-mode-fixes.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "font/montserrat.css"),
        tags$script(src = "js/dark-mode-helper.js")
      ),
      
      # Tab items
      do.call(tabItems, lapply(pages, function(page) {
        tabItem(
          tabName = page$id,
          page$ui_fun(page$id)
        )
      }))
    ),
    footer = dashboardFooter(
      left = paste("Version", config$get_app_version()),
      right = "© 2024 Symrise AG"
    )
  )
}

#' Main server function
#' @export
server <- function(input, output, session) {
  # Initialize reactive values for data sharing between modules
  app_data <- reactiveValues(
    design_params = NULL,
    imported_data = NULL,
    analysis_results = NULL
  )
  
  # Call server functions for each page
  lapply(pages, function(page) {
    page$server_fun(
      id = page$id,
      app_data = app_data
    )
  })
  
  # Session management
  session$onSessionEnded(function() {
    # Clean up temporary files if any
  })
}