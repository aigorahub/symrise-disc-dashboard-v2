# Sample data generator for testing
# Creates data in the format expected by the discrimination analysis

box::use(
  stats[rbinom]
)

#' Generate sample discrimination test data
#' @export
generate_discrimination_data <- function(
  n_panelists = 30,
  n_reps = 3,
  test_type = "triangle",
  d_prime = 1.5
) {
  # Calculate probability correct based on d-prime and test type
  pc <- switch(test_type,
    "triangle" = 1/3 + (2/3) * pnorm(d_prime/sqrt(2)),
    "tetrad" = 1/4 + (3/4) * pnorm(d_prime/sqrt(2)),
    "duotrio" = 1/2 + (1/2) * pnorm(d_prime/sqrt(2)),
    "twoAFC" = pnorm(d_prime/sqrt(2)),
    0.5  # default
  )
  
  # Generate data
  data <- data.frame(
    Panelist = rep(1:n_panelists, each = 1),
    Total = rep(n_reps, n_panelists),
    Correct = rbinom(n_panelists, n_reps, pc)
  )
  
  data
}

#' Generate sample SoD data
#' @export
generate_sod_data <- function(
  n_panelists = 20,
  n_reps = 2,
  products = c("Control", "Test1", "Test2", "Test3"),
  d_primes = c(0, 1.0, 1.5, 2.0)
) {
  data <- expand.grid(
    Panelist = 1:n_panelists,
    Product = products,
    Rep = 1:n_reps
  )
  
  # Generate ratings based on d-prime values
  data$Rating <- numeric(nrow(data))
  for (i in 1:length(products)) {
    mask <- data$Product == products[i]
    # SoD ratings typically 0-10 scale
    mean_rating <- 5 + d_primes[i] * 2
    data$Rating[mask] <- pmax(0, pmin(10, rnorm(sum(mask), mean_rating, 1.5)))
  }
  
  data$Difference_Size <- data$Rating  # For SoD, these are the same
  
  data
}

#' Generate sample double tetrad data
#' @export
generate_double_tetrad_data <- function(
  n_panelists = 30,
  n_reps = 2,
  d_prime1 = 1.2,
  d_prime2 = 1.8
) {
  test1 <- generate_discrimination_data(n_panelists, n_reps, "tetrad", d_prime1)
  test2 <- generate_discrimination_data(n_panelists, n_reps, "tetrad", d_prime2)
  
  list(
    test1 = test1,
    test2 = test2
  )
}