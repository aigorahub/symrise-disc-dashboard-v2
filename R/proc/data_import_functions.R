# Data import and tidying functions
# Ported from the old working dashboard

box::use(
  dplyr[...],
  tidyr[...],
  rio[import_list],
  janitor[clean_names]
)

#' Tidy triangle test data
#' @export
tidy_triangle <- function(file_path) {
  data <- import_list(file_path, rbind = TRUE) %>%
    clean_names() %>%
    select(assessor, product, difference) %>%
    group_by(assessor, product) %>%
    summarize(Correct = sum(difference), Total = n(), .groups = "drop") %>%
    ungroup() %>%
    rename(Panelist = assessor, Product = product) %>%
    mutate(Panelist = factor(Panelist))
  
  prod_labels <- strsplit(unique(data$Product), split = "-", fixed = TRUE) [[1]]
  
  return(list(tidy_data = data, prod_labels = prod_labels))
}

#' Tidy tetrad test data  
#' @export
tidy_tetrad <- function(file_path) {
  data <- import_list(file_path, rbind = TRUE) %>%
    clean_names() %>%
    select(assessor, product, tetrad) %>%
    group_by(assessor, product) %>%
    summarize(Correct = sum(tetrad), Total = n(), .groups = "drop") %>%
    ungroup() %>%
    rename(Panelist = assessor, Product = product) %>%
    mutate(Panelist = factor(Panelist))
  
  prod_labels <- strsplit(unique(data$Product), split = "-", fixed = TRUE) [[1]]
  
  return(list(tidy_data = data, prod_labels = prod_labels))
}

#' Tidy 2-AFCR test data
#' @export  
tidy_two_afcr <- function(file_path) {
  data <- import_list(file_path, rbind = TRUE) %>%
    clean_names() %>%
    select(assessor, product, same) %>%
    group_by(assessor, product) %>%
    summarize(Correct = sum(same), Total = n(), .groups = "drop") %>%
    ungroup() %>%
    rename(Panelist = assessor, Product = product) %>%
    mutate(Panelist = factor(Panelist))
  
  prod_labels <- strsplit(unique(data$Product), split = "-", fixed = TRUE) [[1]]
  
  return(list(tidy_data = data, prod_labels = prod_labels))
}

#' Load 2-AFC test data (first step)
#' @export
tidy_two_afc_load_data <- function(file_path) {
  raw_data <- import_list(file_path, rbind = TRUE) %>%
    clean_names()
  
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
  data <- import_list(file_path, rbind = TRUE) %>%
    clean_names()
  
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
  data <- import_list(file_path, rbind = TRUE) %>%
    clean_names()
  
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