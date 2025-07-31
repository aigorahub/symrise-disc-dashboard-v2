# Helper functions for sensR compatibility
# Handles different versions of sensR package

box::use(
  sensR
)

#' Calculate sample size for discrimination tests
#' Wrapper function that handles different sensR versions
#' @export
calculate_sample_size <- function(d_prime, power, alpha, test_obj, method) {
  # First try d.primeSS - this is what the old dashboard uses
  if (exists("d.primeSS", where = asNamespace("sensR"))) {
    tryCatch({
      result <- sensR::d.primeSS(
        d.primeA = d_prime,
        target.power = power,
        alpha = alpha,
        test = "difference",  # Always use "difference" as per old dashboard
        method = method
      )
      return(ceiling(result))
    }, error = function(e) {
      # If d.primeSS fails, fall through to other methods
      message("d.primeSS failed: ", e$message)
    })
  }
  
  # If d.primeSS doesn't exist or fails, use binary search with power functions
  n_min <- 5
  n_max <- 1000
  
  # Try to find which power function is available
  power_func <- NULL
  
  if (exists("d.primePwr", where = asNamespace("sensR"))) {
    power_func <- function(n) {
      sensR::d.primePwr(
        d.primeA = d_prime,
        sample.size = n,
        alpha = alpha,
        test = "difference",  # Always use "difference" as per old dashboard
        method = method
      )
    }
  } else if (exists("discrimPwr", where = asNamespace("sensR"))) {
    power_func <- function(n) {
      tryCatch({
        sensR::discrimPwr(
          pd = sensR::coef(sensR::psyfun(d_prime, method = method))$pd,
          sample.size = n,
          alpha = alpha,
          method = method
        )
      }, error = function(e) {
        # Alternative call signature
        sensR::discrimPwr(
          d.primeA = d_prime,
          sample.size = n,
          alpha = alpha,
          method = method
        )
      })
    }
  } else {
    # Fallback: Use basic approximation based on method
    pc_guess <- switch(method,
      "triangle" = 1/3 + (2/3) * pnorm(d_prime/sqrt(2)),
      "tetrad" = 1/4 + (3/4) * pnorm(d_prime/sqrt(2)),
      "twoAFC" = pnorm(d_prime/sqrt(2)),
      "duotrio" = 1/2 + (1/2) * pnorm(d_prime/sqrt(2)),
      0.75  # default
    )
    
    # Use normal approximation for sample size
    z_alpha <- qnorm(1 - alpha)
    z_beta <- qnorm(power)
    p0 <- switch(method, "triangle" = 1/3, "tetrad" = 1/4, "twoAFC" = 0.5, "duotrio" = 0.5, 1/3)
    
    n <- ((z_alpha * sqrt(p0 * (1 - p0)) + z_beta * sqrt(pc_guess * (1 - pc_guess)))^2) / 
          ((pc_guess - p0)^2)
    
    return(ceiling(n))
  }
  
  # Binary search for exact sample size
  if (!is.null(power_func)) {
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
  funs <- ls("package:sensR")
  list(
    sample_size_functions = funs[grep("SS|sample", funs, ignore.case = TRUE)],
    power_functions = funs[grep("pwr|power", funs, ignore.case = TRUE)],
    discrimination_functions = funs[grep("discrim", funs, ignore.case = TRUE)],
    all_functions = sort(funs)
  )
}