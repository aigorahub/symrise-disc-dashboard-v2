# Debug version to test the basic structure

library(shiny)
library(bs4Dash)

# Simple UI without modules
ui <- dashboardPage(
  header = dashboardHeader(title = "Debug Test"),
  sidebar = dashboardSidebar(
    sidebarMenu(
      id = "sidebar",
      menuItem("Test 1", tabName = "test1", icon = icon("home")),
      menuItem("Test 2", tabName = "test2", icon = icon("gear"))
    )
  ),
  body = dashboardBody(
    tabItems(
      tabItem(tabName = "test1", h2("Test Page 1")),
      tabItem(tabName = "test2", h2("Test Page 2"))
    )
  )
)

server <- function(input, output, session) {
  observe({
    cat("Selected tab:", input$sidebar, "\n")
  })
}

shinyApp(ui, server)