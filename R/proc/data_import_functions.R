# Data import and tidying functions
# Ported from the old working dashboard

box::use(
  dplyr[...],
  tidyr[...],
  readxl[read_excel, excel_sheets]
)

# Simple function to clean column names without janitor
clean_names_simple <- function(data) {
  names(data) <- tolower(gsub("[^a-zA-Z0-9_]", "_", names(data)))
  names(data) <- gsub("_{2,}", "_", names(data))  # Remove multiple underscores
  names(data) <- gsub("^_|_$", "", names(data))   # Remove leading/trailing underscores
  data
}

# Helper function to read Excel files with multiple sheets
read_excel_allsheets <- function(file_path) {
  file_ext <- tolower(tools::file_ext(file_path))
  
  if (file_ext %in% c("xlsx", "xls")) {
    sheets <- excel_sheets(file_path)
    data_list <- lapply(sheets, function(sheet) {
      read_excel(file_path, sheet = sheet)
    })
    # Combine all sheets
    do.call(rbind, data_list)
  } else if (file_ext == "csv") {
    read.csv(file_path, stringsAsFactors = FALSE)
  } else {
    stop("Unsupported file format")
  }
}

#' Tidy triangle test data
#' @export
tidy_triangle <- function(file_path) {
  data <- read_excel_allsheets(file_path) %>%
    clean_names_simple()
  
  # Debug: show what columns actually exist (remove this later)
  cat("Available columns:", paste(names(data), collapse = ", "), "\n")
  
  # Try to auto-detect column names
  cols <- names(data)
  assessor_col <- cols[grepl("assessor|panelist|judge|participant", cols, ignore.case = TRUE)]
  product_col <- cols[grepl("product|sample|treatment", cols, ignore.case = TRUE)]
  # For triangle, look for response columns (including tetrad since files might have mixed test data)
  difference_col <- cols[grepl("difference|correct|response|answer|triangle|tetrad", cols, ignore.case = TRUE)]
  
  # Use detected columns or fall back to positional
  if (length(assessor_col) == 0) assessor_col <- cols[1]
  if (length(product_col) == 0) product_col <- cols[2]
  if (length(difference_col) == 0) difference_col <- cols[3]
  
  # Take only the first detected column for each type
  assessor_final <- assessor_col[1]
  product_final <- product_col[1] 
  difference_final <- difference_col[1]
  
  cat("Using columns:", assessor_final, "->", product_final, "->", difference_final, "\n")
  
  processed_data <- data %>%
    select(Panelist = all_of(assessor_final), 
           Product = all_of(product_final), 
           difference = all_of(difference_final)) %>%
    group_by(Panelist, Product) %>%
    summarize(Correct = sum(difference), Total = n(), .groups = "drop") %>%
    ungroup() %>%
    mutate(Panelist = factor(Panelist))
  
  # Extract product labels from the processed data
  cat("Creating product labels from:", unique(processed_data$Product), "\n")
  prod_labels <- strsplit(as.character(unique(processed_data$Product)[1]), split = "-", fixed = TRUE) [[1]]
  
  return(list(tidy_data = processed_data, prod_labels = prod_labels))
}

#' Tidy tetrad test data  
#' @export
tidy_tetrad <- function(file_path) {
  data <- read_excel_allsheets(file_path) %>%
    clean_names_simple()
  
  # Debug: show what columns actually exist (remove this later)
  cat("Available columns:", paste(names(data), collapse = ", "), "\n")
  
  # Try to auto-detect column names
  cols <- names(data)
  assessor_col <- cols[grepl("assessor|panelist|judge|participant", cols, ignore.case = TRUE)]
  product_col <- cols[grepl("product|sample|treatment", cols, ignore.case = TRUE)]
  tetrad_col <- cols[grepl("tetrad|correct|response|answer|difference", cols, ignore.case = TRUE)]
  
  # Use detected columns or fall back to positional
  if (length(assessor_col) == 0) assessor_col <- cols[1]
  if (length(product_col) == 0) product_col <- cols[2]
  if (length(tetrad_col) == 0) tetrad_col <- cols[3]
  
  # Take only the first detected column for each type
  assessor_final <- assessor_col[1]
  product_final <- product_col[1] 
  tetrad_final <- tetrad_col[1]
  
  cat("Using columns:", assessor_final, "->", product_final, "->", tetrad_final, "\n")
  
  processed_data <- data %>%
    select(Panelist = all_of(assessor_final), 
           Product = all_of(product_final), 
           tetrad = all_of(tetrad_final)) %>%
    group_by(Panelist, Product) %>%
    summarize(Correct = sum(tetrad), Total = n(), .groups = "drop") %>%
    ungroup() %>%
    mutate(Panelist = factor(Panelist))
  
  # Extract product labels from the processed data
  cat("Creating product labels from:", unique(processed_data$Product), "\n")
  prod_labels <- strsplit(as.character(unique(processed_data$Product)[1]), split = "-", fixed = TRUE) [[1]]
  
  return(list(tidy_data = processed_data, prod_labels = prod_labels))
}

#' Tidy 2-AFCR test data
#' @export  
tidy_two_afcr <- function(file_path) {
  data <- read_excel_allsheets(file_path) %>%
    clean_names_simple() %>%
    select(assessor, product, same) %>%
    group_by(assessor, product) %>%
    summarize(Correct = sum(same), Total = n(), .groups = "drop") %>%
    ungroup() %>%
    rename(Panelist = assessor, Product = product) %>%
    mutate(Panelist = factor(Panelist))
  
  prod_labels <- strsplit(as.character(unique(data$Product)[1]), split = "-", fixed = TRUE) [[1]]
  
  return(list(tidy_data = data, prod_labels = prod_labels))
}

#' Load 2-AFC test data (first step)
#' @export
tidy_two_afc_load_data <- function(file_path) {
  raw_data <- read_excel_allsheets(file_path) %>%
    clean_names_simple()
  
  data <- raw_data %>%
    select(assessor, product, comparison) %>%
    rename(Panelist = assessor, Product = product, selection = comparison) %>%
    filter(!is.na(selection)) %>%
    mutate(number_of_times = 1) %>%
    group_by(Panelist, Product, selection) %>%
    summarise(times = sum(number_of_times), .groups = "drop") %>%
    ungroup() %>%
    pivot_wider(names_from = selection, values_from = times, values_fill = 0) %>%
    mutate(Total = rowSums(across(3:4)))
  
  # List of products / options
  poss_corr_prods <- strsplit(unique(raw_data$product), split = "-", fixed = TRUE) [[1]]
  poss_corr_opts <- c(poss_corr_prods, "Don't Know")
  
  return(list("options" = poss_corr_opts, "prods" = poss_corr_prods, "data" = data))
}

#' Process 2-AFC test data (second step)
#' @export
tidy_two_afc_process_data <- function(poss_corr_prods, corr_prod, data) {
  # If user "Don't Know" - decide the "Correct sample" by counting the number of answers
  if (corr_prod == "Don't Know") {
    corr_prod <- data %>%
      select(3:4) %>%
      colSums() %>%
      sort(decreasing = TRUE) %>%
      names() %>%
      .[[1]]
  }
  
  # Define product labels
  prod_labels <- c(corr_prod, setdiff(poss_corr_prods, corr_prod))
  
  # Process data
  processed_data <- data %>%
    rowwise() %>%
    mutate(Correct = get(corr_prod)) %>%
    ungroup() %>%
    select(Panelist, Product, Correct, Total) %>%
    mutate(Panelist = factor(Panelist))
  
  return(list(tidy_data = processed_data, prod_labels = prod_labels))
}

#' Tidy DFC (Difference from Control) data
#' @export  
tidy_dfc_load_data <- function(file_path) {
  data <- read_excel_allsheets(file_path) %>%
    clean_names_simple()
  
  # Get control names (samples that appear most frequently)
  control_candidates <- data %>%
    count(sample_name, sort = TRUE) %>%
    pull(sample_name)
  
  # Get attribute columns (numeric columns that aren't panelist/sample identifiers)
  numeric_cols <- data %>%
    select_if(is.numeric) %>%
    select(-matches("session|position|rep|code")) %>%
    names()
  
  return(list(
    data = data,
    control_name = control_candidates,
    options = numeric_cols
  ))
}

#' Process DFC data
#' @export
tidy_dfc_process_data <- function(control, control_names, dfc_var, data) {
  processed_data <- data %>%
    select(panelist_code, sample_name, all_of(dfc_var)) %>%
    rename(Panelist = panelist_code, Product = sample_name, Rating = all_of(dfc_var)) %>%
    mutate(
      Panelist = factor(Panelist),
      Type = ifelse(Product == control, "Control", "Test")
    )
  
  return(list(
    tidy_data = processed_data,
    control_name = control,
    attribute = dfc_var
  ))
}

#' Tidy RaR (Ranking against Reference) data  
#' @export
tidy_rar <- function(file_path) {
  data <- read_excel_allsheets(file_path) %>%
    clean_names_simple()
  
  # Get control names
  control_names <- data %>%
    distinct(sample_name) %>%
    pull(sample_name)
  
  # Process data
  processed_data <- data %>%
    select(panelist_code, sample_name, matches("size|difference")) %>%
    rename(
      Panelist = panelist_code,
      Product = sample_name,
      Rating = 3  # Assuming the 3rd column is the rating
    ) %>%
    mutate(Panelist = factor(Panelist))
  
  return(list(
    tidy_data = processed_data,
    control_names = control_names
  ))
} 