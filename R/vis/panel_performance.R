# Panel performance visualization functions
# Creates traffic light plots and panel performance heatmaps

box::use(
  ggplot2[...],
  dplyr[..., `%>%`],
  tidyr[pivot_longer],
  stats[reorder],
  scales[percent]
)

# Helper function for factor reversal
fct_rev <- function(f) {
  if (requireNamespace("forcats", quietly = TRUE)) {
    forcats::fct_rev(f)
  } else {
    # Simple fallback if forcats not available
    factor(f, levels = rev(levels(f)))
  }
}

#' Create panel performance heatmap (traffic light plot)
#' @export
create_panel_heatmap <- function(data, test_type, overdispersion_info = NULL) {
  # Define colors
  primary_color <- "#C51718"
  secondary_color <- "#696969"
  white <- "#FFFFFF"
  blue <- "#0070C0"
  
  # Prepare data based on test type
  if (test_type %in% c("triangle", "tetrad", "duo_trio", "two_afc")) {
    # For discrimination tests, show Correct vs Total
    heatmap_data <- data %>%
      select(Panelist, Correct, Total) %>%
      pivot_longer(c(Correct, Total), names_to = "Type", values_to = "Count") %>%
      mutate(
        Type = fct_rev(factor(Type, levels = c("Correct", "Total"))),
        Panelist = factor(Panelist)
      )
    
    # Create title based on overdispersion results
    if (!is.null(overdispersion_info)) {
      if (is.na(overdispersion_info$p_value)) {
        plot_title <- "Panelists were not fully replicated so no test for overdispersion was performed"
      } else {
        plot_title <- paste0(
          "Overdispersion ",
          ifelse(overdispersion_info$detected, "WAS", "was not"),
          " detected, p-value = ",
          sprintf("%.3f", overdispersion_info$p_value)
        )
      }
    } else {
      plot_title <- "Panel Performance"
    }
    
    # Create heatmap
    p <- ggplot(heatmap_data, aes(x = Panelist, y = Type, fill = Count)) +
      geom_tile(color = secondary_color) +
      scale_x_discrete(guide = guide_axis(n.dodge = 3), position = "bottom") +
      scale_fill_gradient(
        name = "Count",
        limits = c(0, max(data$Total)),
        breaks = 0:max(data$Total),
        labels = 0:max(data$Total),
        low = white,
        high = blue
      ) +
      theme_minimal() +
      theme(
        axis.line = element_blank(),
        panel.grid = element_blank(),
        text = element_text(size = 10, color = secondary_color),
        legend.position = "right",
        axis.title = element_blank(),
        plot.title = element_text(size = 11, face = "bold")
      ) +
      guides(fill = guide_legend(title.position = "top", title.hjust = 0.5)) +
      ggtitle(plot_title)
    
  } else if (test_type == "sod") {
    # For SoD tests, show mean ratings by product
    heatmap_data <- data %>%
      group_by(Panelist, Product) %>%
      summarize(Rating = mean(Rating, na.rm = TRUE), .groups = "drop")
    
    plot_title <- "Panel Performance - Mean Ratings"
    
    p <- ggplot(heatmap_data, aes(x = Panelist, y = Product, fill = Rating)) +
      geom_tile(color = secondary_color) +
      geom_text(
        aes(label = sprintf("%.1f", Rating)),
        size = 3,
        color = "black"
      ) +
      scale_x_discrete(guide = guide_axis(n.dodge = 3), position = "bottom") +
      scale_fill_gradient(
        name = "Mean Rating",
        low = white,
        high = blue
      ) +
      theme_minimal() +
      theme(
        axis.line = element_blank(),
        panel.grid = element_blank(),
        text = element_text(size = 10, color = secondary_color),
        legend.position = "right",
        axis.title = element_blank(),
        plot.title = element_text(size = 11, face = "bold")
      ) +
      guides(fill = guide_legend(title.position = "top", title.hjust = 0.5)) +
      ggtitle(plot_title)
  }
  
  p
}

#' Create correct answers summary
#' @export
create_correct_answers_summary <- function(data, test_type) {
  if (!test_type %in% c("triangle", "tetrad", "duo_trio", "two_afc")) {
    return(NULL)
  }
  
  # Calculate proportion correct for each panelist
  panelist_summary <- data %>%
    mutate(
      Proportion = Correct / Total,
      Performance = case_when(
        Proportion >= 0.8 ~ "Excellent",
        Proportion >= 0.6 ~ "Good",
        Proportion >= 0.4 ~ "Fair",
        TRUE ~ "Poor"
      )
    ) %>%
    arrange(desc(Proportion))
  
  # Define colors for performance levels
  colors <- c(
    "Excellent" = "#70AD47",  # Green
    "Good" = "#0070C0",       # Blue
    "Fair" = "#FFC000",       # Orange
    "Poor" = "#C51718"        # Red
  )
  
  # Create bar plot
  p <- ggplot(panelist_summary, aes(x = stats::reorder(Panelist, Proportion), y = Proportion, fill = Performance)) +
    geom_bar(stat = "identity") +
    scale_fill_manual(values = colors) +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    coord_flip() +
    theme_minimal() +
    theme(
      text = element_text(size = 10),
      legend.position = "top",
      axis.title.x = element_text(margin = margin(t = 10))
    ) +
    labs(
      title = "Individual Panelist Performance",
      x = "Panelist",
      y = "Proportion Correct",
      fill = "Performance Level"
    )
  
  p
}

#' Create traffic light visualization for test conclusions
#' @export
create_traffic_light <- function(results) {
  # Determine status based on results
  if (results$test_objective == "similarity") {
    # For similarity tests
    if (results$meets_criteria) {
      status <- "PASS"
      color <- "#70AD47"  # Green
      message <- "Products are similar"
    } else if (results$is_significant) {
      status <- "FAIL"
      color <- "#C51718"  # Red
      message <- "Products are different"
    } else {
      status <- "INCONCLUSIVE"
      color <- "#FFC000"  # Orange
      message <- "Insufficient evidence"
    }
  } else {
    # For difference tests
    if (results$is_significant) {
      status <- "PASS"
      color <- "#70AD47"  # Green
      message <- "Difference detected"
    } else {
      status <- "FAIL"
      color <- "#C51718"  # Red
      message <- "No difference detected"
    }
  }
  
  # Create simple traffic light visualization
  p <- ggplot(data.frame(x = 1, y = 1), aes(x, y)) +
    geom_point(size = 50, color = color, fill = color, shape = 21) +
    annotate("text", x = 1, y = 1, label = status, size = 8, fontface = "bold", color = "white") +
    annotate("text", x = 1, y = 0.7, label = message, size = 5) +
    xlim(0.5, 1.5) +
    ylim(0.5, 1.5) +
    theme_void() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      plot.margin = margin(20, 20, 20, 20)
    ) +
    ggtitle("Test Conclusion")
  
  p
}