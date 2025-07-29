# Configuration module
# Handles app configuration and theming

box::use(
  shiny[tags]
)

# Symrise brand colors
PRIMARY_COLOR <- "#c51718"  # Symrise red
SECONDARY_COLOR <- "#696969" # Gray
BACKGROUND_COLOR <- "#FCFCFC"
TEXT_COLOR <- "#000000"

# App configuration
APP_NAME <- "Symrise Discrimination Training Dashboard"
APP_VERSION <- "2.0.0"

#' Setup function to initialize configuration
#' @export
setup <- function() {
  # For now, we'll handle theming through CSS instead of fresh package
  # The custom.css file contains all the necessary styling
}

#' Get app name
#' @export
get_app_name <- function() {
  APP_NAME
}

#' Get app version
#' @export
get_app_version <- function() {
  APP_VERSION
}

#' Get Symrise logo
#' @export
get_logo <- function() {
  # For now, return text logo until we have the actual image
  tags$span(
    "SYMRISE",
    style = paste0(
      "color: ", PRIMARY_COLOR, "; ",
      "font-weight: bold; ",
      "font-size: 20px; ",
      "margin-right: 10px;"
    )
  )
}