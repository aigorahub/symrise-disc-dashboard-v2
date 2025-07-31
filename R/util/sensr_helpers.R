# Helper functions for sensR compatibility
# Handles different versions of sensR package

# Ensure sensR functions are available in this module environment  
# Note: box modules have isolated environments, so we need to explicitly load sensR here
if (!exists("d.primePwr")) {
  library(sensR)
}

#' Calculate sample size for discrimination tests
#' Wrapper function that handles different sensR versions
#' @export
calculate_sample_size <- function(d_prime, power, alpha, test_obj, method) {
  # First try d.primeSS - this is what the old dashboard uses
  if (exists("d.primeSS", where = asNamespace("sensR"))) {
    tryCatch({
      # Different parameters for similarity vs difference tests
      if (test_obj == "similarity") {
        result <- sensR::d.primeSS(
          d.primeA = 0,
          d.prime0 = d_prime,
          target.power = power,
          alpha = alpha,
          test = "similarity",
          method = method
        )
      } else {
        result <- sensR::d.primeSS(
          d.primeA = d_prime,
          target.power = power,
          alpha = alpha,
          test = "difference",
          method = method
        )
      }
      return(ceiling(result))
    }, error = function(e) {
      # If d.primeSS fails, fall through to other methods
      message("d.primeSS failed: ", e$message)
    })
  }
  
  # If d.primeSS doesn't exist or fails, use binary search with power functions
  n_min <- 5
  n_max <- 500  # Reduced from 1000 to avoid extreme values
  
  # Try to find which power function is available
  power_func <- NULL
  
  if (exists("d.primePwr", where = asNamespace("sensR"))) {
    power_func <- function(n) {
      # Different parameters for similarity vs difference tests
      if (test_obj == "similarity") {
        sensR::d.primePwr(
          d.primeA = 0,
          d.prime0 = d_prime,
          sample.size = n,
          alpha = alpha,
          test = "similarity",
          method = method
        )
      } else {
        sensR::d.primePwr(
          d.primeA = d_prime,
          sample.size = n,
          alpha = alpha,
          test = "difference",
          method = method
        )
      }
    }
  } else {
    # Fallback: Use basic approximation based on method
    pc_guess <- switch(method,
      "triangle" = 1/3 + (2/3) * stats::pnorm(d_prime/sqrt(2)),
      "tetrad" = 1/4 + (3/4) * stats::pnorm(d_prime/sqrt(2)),
      "twoAFC" = stats::pnorm(d_prime/sqrt(2)),
      "duotrio" = 1/2 + (1/2) * stats::pnorm(d_prime/sqrt(2)),
      0.75  # default
    )
    
    # Use normal approximation for sample size
    z_alpha <- stats::qnorm(1 - alpha)
    z_beta <- stats::qnorm(power)
    p0 <- switch(method, "triangle" = 1/3, "tetrad" = 1/4, "twoAFC" = 0.5, "duotrio" = 0.5, 1/3)
    
    n <- ((z_alpha * sqrt(p0 * (1 - p0)) + z_beta * sqrt(pc_guess * (1 - pc_guess)))^2) / 
          ((pc_guess - p0)^2)
    
    return(ceiling(n))
  }
  
  # Binary search for exact sample size
  if (!is.null(power_func)) {
    # First check if we need a larger range
    max_power <- tryCatch({
      power_func(n_max)
    }, error = function(e) {
      0.5
    })
    
    # If max power is still less than target, increase range
    while (max_power < power && n_max < 1000) {
      n_max <- min(n_max * 2, 1000)
      max_power <- tryCatch({
        power_func(n_max)
      }, error = function(e) {
        0.5
      })
    }
    
    # Binary search
    while (n_max - n_min > 1) {
      n_mid <- floor((n_min + n_max) / 2)
      
      current_power <- tryCatch({
        power_func(n_mid)
      }, error = function(e) {
        # If error, try with a larger sample
        0.5
      })
      
      if (current_power < power) {
        n_min <- n_mid
      } else {
        n_max <- n_mid
      }
    }
    
    return(n_max)
  } else {
    stop("No suitable power calculation function found in sensR package")
  }
}

#' List available sensR functions
#' @export
list_sensr_functions <- function() {
  # Avoid ls() during module loading - use static list instead
  list(
    sample_size_functions = c("d.primeSS", "discrimSS"),
    power_functions = c("d.primePwr", "discrimPwr", "dodPwr", "samediffPwr", "twoACpwr"),
    discrimination_functions = c("discrim", "discrimPwr", "discrimR", "discrimSim", "discrimSS"),
    all_functions = c("d.primeSS", "d.primePwr", "discrim", "discrimPwr", "dodPwr")
  )
}