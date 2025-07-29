# Data processing functions
# Handles special data formats like Double Tetrad

box::use(
  dplyr[...],
  tidyr[...]
)

#' Process uploaded data based on test type
#' @param data The raw data frame
#' @param test_type The type of test
#' @param test_objective The test objective (similarity/difference)
#' @return A list with processed data
#' @export
process_uploaded_data <- function(data, test_type, test_objective) {
  if (test_type == "double_tetrad") {
    return(process_double_tetrad(data, test_objective))
  } else {
    return(list(
      data_sets = list(data),
      test_type = test_type,
      test_objective = test_objective,
      is_double = FALSE
    ))
  }
}

#' Process Double Tetrad data
#' @param data The raw Double Tetrad data
#' @param test_objective The test objective
#' @return A list with two separate tetrad datasets
process_double_tetrad <- function(data, test_objective) {
  # Double Tetrad typically has specific column patterns
  # This is a placeholder implementation - adjust based on actual file format
  
  # Check if data has the expected structure for Double Tetrad
  # Assuming the data has columns that indicate Test 1 and Test 2
  
  # Look for columns that might indicate test separation
  col_names <- names(data)
  
  # Try to identify test 1 and test 2 columns
  test1_cols <- grep("test.*1|tetrad.*1|set.*1", col_names, ignore.case = TRUE, value = TRUE)
  test2_cols <- grep("test.*2|tetrad.*2|set.*2", col_names, ignore.case = TRUE, value = TRUE)
  
  if (length(test1_cols) > 0 && length(test2_cols) > 0) {
    # Split based on identified columns
    common_cols <- setdiff(col_names, c(test1_cols, test2_cols))
    
    data_test1 <- data %>%
      select(all_of(c(common_cols, test1_cols)))
    
    data_test2 <- data %>%
      select(all_of(c(common_cols, test2_cols)))
    
  } else {
    # Alternative: Split by rows if data is stacked
    # Check if there's a column indicating test number
    if ("test_number" %in% col_names || "test" %in% col_names) {
      test_col <- intersect(c("test_number", "test"), col_names)[1]
      
      data_test1 <- data %>%
        filter(!!sym(test_col) == 1 | !!sym(test_col) == "1" | !!sym(test_col) == "Test 1")
      
      data_test2 <- data %>%
        filter(!!sym(test_col) == 2 | !!sym(test_col) == "2" | !!sym(test_col) == "Test 2")
      
    } else {
      # If no clear separation found, split data in half
      n_rows <- nrow(data)
      mid_point <- floor(n_rows / 2)
      
      data_test1 <- data[1:mid_point, ]
      data_test2 <- data[(mid_point + 1):n_rows, ]
    }
  }
  
  # Return list with both datasets
  list(
    data_sets = list(
      test1 = data_test1,
      test2 = data_test2
    ),
    test_type = "tetrad",  # Each individual test is a tetrad
    test_objective = test_objective,
    is_double = TRUE,
    original_type = "double_tetrad"
  )
}

#' Validate discrimination test data
#' @param data The data frame to validate
#' @param test_type The type of test
#' @return A list with validation results
#' @export
validate_test_data <- function(data, test_type) {
  required_cols <- switch(test_type,
    "triangle" = c("panelist", "sample", "response"),
    "tetrad" = c("panelist", "response"),
    "duo_trio" = c("panelist", "sample", "response"),
    "two_afc" = c("panelist", "sample_a", "sample_b", "response"),
    "sod" = c("panelist", "sample", "rating"),
    c()  # Default: no specific requirements
  )
  
  missing_cols <- setdiff(required_cols, names(data))
  
  list(
    is_valid = length(missing_cols) == 0,
    missing_columns = missing_cols,
    n_rows = nrow(data),
    n_cols = ncol(data)
  )
}