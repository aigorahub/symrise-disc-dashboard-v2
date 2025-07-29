# Simple test version without box modules
library(shiny)
library(bs4Dash)

ui <- dashboardPage(
  header = dashboardHeader(
    title = "Symrise Discrimination Training Dashboard"
  ),
  sidebar = dashboardSidebar(
    sidebarMenu(
      menuItem("DESIGN", tabName = "design", icon = icon("pencil-ruler")),
      menuItem("IMPORT", tabName = "import", icon = icon("upload")),
      menuItem("RUN", tabName = "run", icon = icon("play"))
    )
  ),
  body = dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "font/montserrat.css")
    ),
    tabItems(
      tabItem(
        tabName = "design",
        h2("Design Discrimination Test"),
        box(
          title = "Test Parameters",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          p("Design module will be implemented here")
        )
      ),
      tabItem(
        tabName = "import",
        h2("Import Data"),
        box(
          title = "Upload Data",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          p("Import module will be implemented here")
        )
      ),
      tabItem(
        tabName = "run",
        h2("Run Analysis"),
        box(
          title = "Analysis",
          status = "primary",
          solidHeader = TRUE,
          width = 12,
          p("Run module will be implemented here")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Server logic will be added here
}

shinyApp(ui, server)