#
#
# The working function from SAFE analysis, which will eventually be integrated into package.
# This is the most up to date version of it and it should be copied back to SAFE for revision if needed.
#
# 
#

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -------------------------------------

# DEBUGGING ---------------------------------------------------------------

DEBUG <- F
if(DEBUG){
  #   
  # rm(list = ls())
  library("data.table")
  library("MASS")
  library("tmvtnorm")
  
  x1 <- 20
  sd1 <- 1.5
  x2 <- 15
  sd2 <- 1
  n1 <- 10
  n2 <- 10
  formula_path = "data/effect_size_formulas.csv"
  effect_formulas <- fread(formula_path)
  # formula <- "log(x1 / x2)"
  # eval(parse(text = formula))
  input_vars = list(  x1 = 20,
                      sd1 = 1.5,
                      x2 = 15,
                      sd2 = 1,
                      n1 = 10,
                      n2 = 10)
  
  effect_type <- "lnRoM"
  data = NULL
  bind = TRUE
  verbose = TRUE
  default_formulas = TRUE
  paired = FALSE
  SAFE = FALSE
  SAFE_boots = 1e6
  SAFE_distribution = NULL 
  sigma_matrix = NULL
  
  eff_size(x1 = 20,
           sd1 = 1.5,
           x2 = 15,
           sd2 = 1,
           n1 = 10,
           n2 = 10,
           effect_type = "lnRoM")
  
  eff_size(x1 = x1,
           sd1 = sd1,
           x2 = x2,
           sd2 = sd2,
           n1 = n1,
           n2 = n2,
           effect_type = "lnRoM",
           data = as.data.frame(input_vars),
           bind = TRUE,
           verbose = TRUE,
           default_formulas = TRUE,
           paired = FALSE,
           SAFE = FALSE,
           SAFE_boots = 1e6,
           SAFE_distribution = NULL,
           sigma_matrix = NULL)
  
  
  effect_formulas.sub <- effect_formulas[effect_size == effect_type & paired_design == FALSE, ]
  
  
  eff_size(x1 = 20,
           sd1 = 1.5,
           x2 = 15,
           sd2 = 1,
           n1 = 10,
           n2 = 10,
           effect_type = "lnRoM",
           data = NULL,
           bind = TRUE,
           verbose = TRUE,
           default_formulas = TRUE,
           paired = FALSE,
           SAFE = FALSE,
           SAFE_boots = 1e6,
           SAFE_distribution = NULL,
           sigma_matrix = NULL)
  #
  # formula_path = "remote_mirrors/round_1/data/effect_size_formulas.csv"
  # effect_type = "lnRoM"
  # paired_design = FALSE
  # input_vars <- list(x1=x1, x2=x2, sd1=sd1,
  #                    n1=n1, n2=n2)
  # data = scenarios
  
}

#' [TO DO:]
#' *1. Allow it to take a data.frame or data.table with named columns or a vector* [DONE]
#' *2. Decide abotu paired designs. Single formula? Or separate formulas? Setting 'r' to *
#'      *0 for all nonpaired designs might be a problem if future formulas use the same symbol*
#' *3. Make sure n1 == n2 for paired designs OR have the option to set n1 to the smallest of the two, in case of a missing plot, etc *
#' *4. Some effect sizes are explicitly paired now. So even if you run the function with paired = FALSE, it should not error out* 
#' *5. Some effect sizes also only use SAFE for variance. Need to set SAFE to TRUE in those cases*
#' *6. Need to write 6 and 8_multivariate safe methods*
#' *7. Fix functions to work with revised formula table*
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -------------------------------------
# FUNCTIONS ---------------------------------------------------------------

#' [FUNCTION DESCRIPTION:]
#' *4 functions:*
#' *1. eff_size:* This is the master function that executes both plugin and SAFE calculations and is meant to be the user-facing function
#' *2. calc_effect* This function evaluates the formulas to calculate point/SE effect size calculations
#' *3. SAFE_calc* This function manages the SAFE calculations, including transforming the hyperparameters and calculating bias-corrected point estimates
#' *4. parameter_cloud* This function is the most complex as it creates sigma matrices appropriate for different types of effect sizes. It is called by SAFE_calc and returns a parameter cloud 
#' 
#' [CALLS:]
#' *eff_size* [->] *calc_effect*
#' *eff_size* [->] *SAFE_calc*
#' *SAFE_calc* [->] *parameter_cloud*


#' *MASTER FUNCTION*
eff_size <- function(..., 
                     effect_type = NULL,
                     data = NULL, # Data frame including the variables
                     bind = TRUE, # cbind with dataset
                     paired = FALSE,
                     default_formulas = TRUE, # if TRUE, return only the 'best' / least biased formulas
                     formula_path = "data/effect_size_formulas.csv",
                     SAFE = FALSE,
                     SAFE_boots = 1e6,
                     SAFE_distribution = NULL, #' [Aug 2025: Looks like some of these should provide a choice...]
                     sigma_matrix = NULL, #' [Custom sigma matrix. Needs to be a list calculated off of data of hte same length as input_vars. Maybe down the road this could be a custom function]
                     verbose = T){
  require("data.table")
  require("crayon")
  require("MASS")
  require("tmvtnorm")
  
  env <- parent.frame()
  
  if(!is.null(data)) dat <- copy(data)
  
  # >>> Load formulas -------------------------------------------------------
  if(file.exists(formula_path)){
    effect_formulas <- fread(formula_path)
  }else{
    cat(red("Effect size table not found. Specify with formula_path"))
    stop()
  }
  setorder(effect_formulas, effect_size, calc_type)
  
  # Check that effect type is specified and filter formulas
  if(is.null(effect_type)){
    
    cat(blue(("\nEffect type name must be specified with 'effect_type' argument 
    and provide necessary variables (named in arguments to function call) to match formula equations.\n")), 
        blue("\nReturning effect size names & required variables for reference.\n\n"))
    return(unique(effect_formulas[, .(effect_size, paired_design, vars_required)]))
    
  }else if(effect_type %in% effect_formulas$effect_size){
    # filter to desired effect_type  and calculation
    effect_formulas.sub <- effect_formulas[effect_size == effect_type, ]
    effect_formulas.sub <- effect_formulas.sub[paired_design == paired, ]
    
  }else if(!effect_type %in% effect_formulas$effect_size){
    
    cat(blue("Effect type name misspecified"),
        blue("\nReturning effect size names & required variables for reference.\n\n"))
    return(unique(effect_formulas[, .(effect_size, vars_required)]))
    
  }
  if(SAFE == FALSE){
    # Drop extra rows for multiple SAFE methods:
    effect_formulas.sub <- effect_formulas.sub[default_safe_family %in% c("yes", "") |  
                                                 is.na(default_safe_family), ]
  }
  # Get the required variables:
  vars <- strsplit(unique(effect_formulas.sub$vars_required), split = ", ") |> 
    unlist()
  
  # >>> Parse inputs ----------------------------------------------------
  # Function can now accept vectors or NSE inputs (unquoted column names)
  call_expr <- match.call(expand.dots = TRUE)
  args <- as.list(call_expr)[-1]
  if("" %in% names(args)) stop("Numeric arguments must be named")
  #
  args <- args[vars[vars %in% names(args)]] # because of optionally specified r
  input_vars <- list()
  
  # return(args)
  # return(dat[, eval(args[[1]], envir = env)])
  #
  if(!is.null(data)){
    setDT(dat)
    for(i in 1:length(args)){
      input_vars[[i]] <- dat[, eval(args[[i]], envir = env)]
    }
    
  }else if(is.vector(eval(args[[1]], envir = env))){
    for(i in 1:length(args)){
      input_vars[[i]] <- eval(args[[i]], envir = env)
    }
  }
  names(input_vars) <- names(args)
  # 
  # return(input_vars)
  
  if(length(unique(lengths(input_vars))) > 1){ stop(cat("Input vectors", "(", red(paste(names(input_vars), collapse = ", ")), ")",  "are different lengths. Please double check inputs.")) }
  
  # >>> Preliminary checks and filtering --------------------------------------------------
  # Deal with missing 'r' 
  if(paired == TRUE & 
     !"r" %in% names(input_vars)){ 
    
    cat("Paired design selected", red("but 'r' not specified."), "Setting 'r' to 0.5\n")
    input_vars$r <- rep(0.5, max(lengths(input_vars)))
    
    # This is not true:
    # cat("If a mixture of paired and unpaired data, please supply a vector named 'r' with `0`s for unpaired and 'r' for paired designs. 0.5 or 0.8 are commonly used measures for 'r' if unknown.")
    #' [This could cause trouble later...]
  }else if(paired == FALSE &
           !"r" %in% names(input_vars)){
    input_vars$r <- rep(0, max(lengths(input_vars))) # This is necessary for the shared sigma_matrices of some effect sizes
  }
  
  # return(input_vars)
  
  # Check for missing variables.
  if(!all(vars %in% names(input_vars))){ 
    return(cat("Missing the following variables:", 
               red(paste(setdiff(vars, names(input_vars)), collapse=", ")), "\n"))
  }
  
  # Print effect size specific warnings, e.g., 0 in lnOR and lnRR
  if(!is.na(unique(effect_formulas.sub$special_warnings)) & verbose == TRUE){
    cat(unique(effect_formulas.sub$special_warnings), 
        "Leaving it to user's discretion to check prior to execution.\n\n")
  }
  
  # Deal with alternative SAFE distributions.
  #' [I think this can be streamlined]
  if(is.null(SAFE_distribution) & "yes" %in% effect_formulas.sub$default_safe_family
     & SAFE == TRUE){
    # If unspecified (SAFE_distribution == NULL & there are multiple options for default, then choose default
    effect_formulas.sub <- effect_formulas.sub[default_safe_family == "yes", ]
  }else if(!is.null(SAFE_distribution)){
    # If SAFE_distribution is specified, subset to SAFE_distribution
    effect_formulas.sub <- effect_formulas.sub[SAFE_family == SAFE_distribution, ]
  }
  # If unspecified (SAFE_distribution == NULL & effect_formulas.sub$default is all NA then do nothing)
  
  if(nrow(effect_formulas.sub) == 0){    
    return(cat(red("\nEffect size not available after filtering to type."), 
               "\n\nEffect sizes currently supported include:", paste(sort(unique(effect_formulas$effect_size)), collapse = "; "),
               blue("\n\nTo add custom effect sizes please see XXXX")) )
  }


# >>> Filter defaults ---------------------------------------------------------
  # For SAFE:
  if(SAFE == TRUE) definition_formula <- effect_formulas.sub[derivative == "first" & calc_type == "point_estimate", ]
  
  if(default_formulas == TRUE) effect_formulas.sub <- effect_formulas.sub[default == "yes", ]

  # >>> Calculate plugin effect size: -------------------------------------------------
  if(verbose){
    
    cat("Using the formulas:\n\t", blue(paste(effect_formulas.sub$formula, collapse = "\n\t ")), 
        "\nBe sure that all variables in formula are correctly named.\n\n")
  }
  
  plugins <- calc_effect(effect_formulas.sub, input_vars)
  
  if(default_formulas == TRUE) setnames(plugins, names(plugins), gsub("_first|_second", "", names(plugins)))
  
  if(SAFE == TRUE){
    # >>> SAFE calculation ----------------------------------------------------------------
    # Extract reference plugin effect size. First order.
    definition <- calc_effect(definition_formula,
                                      input_vars)
    plugin_effect_size <- definition$yi_first
    
    #' [Need to lapply through each element in input_vars. This would benefit from parallelization]
    index <- seq(1:max(lengths(input_vars)))
    k <- 1
    
    if(length(plugin_effect_size) != max(index)){ return(cat("Shit.")) }
    
    #' *For debugging:*
    # formulas = effect_formulas.sub
    # k <- 1
    # input_k = lapply(input_vars, "[[", k) # select the first element in each element...
    # plugin_effect_k = plugin_effect_size[k]
    # sigma_matrix_k = sigma_matrix[[k]] # submit custom sigma_matrix if it exists.
    # SAFE_boots = 1e6
    # index <- seq(1:5)
    # Run SAFE function for each element of input_vars:
    
    safe_out <- lapply(index, function(k){
      if(verbose) cat("SAFE:", magenta(k, "/", max(index), "\r"))
      
      return(SAFE_calc(formulas = effect_formulas.sub,
                       input_k = lapply(input_vars, "[[", k), # select the first element in each element...
                       plugin_effect_k = plugin_effect_size[k],
                       sigma_matrix_k = sigma_matrix[[k]], # submit custom sigma_matrix if it exists.
                       SAFE_boots = 1e6)) 
    }) |> 
      rbindlist()
    
    out <- cbind(plugins, safe_out)
    
  }else if(SAFE == FALSE){
    out <- plugins
  }
  
  # >>> Return objects ------------------------------------------------------
  
  # If bind with data then do that:
  if(bind == TRUE & !is.null(data)){
    out <- cbind(data, out)
  }
  
  return(out)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -----------------------------------------
#' *PLUGIN EVALUATOR*
calc_effect <- function(formulas,
                        input){
  # Concatenate the formulas into a single formula, separated with ';'
  exec <- paste(formulas$exec_formula, collapse = "; ")
  
  # This adds the effects/variances to the local env but with name assignation:
  eval(parse(text = exec), envir = environment())
  
  res_list <- lapply(unique(formulas$label), function(x) 
    get(x, envir = environment()))
  names(res_list) <- unique(formulas$label)
  
  return(as.data.table(res_list))
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -----------------------------------------
#' *This calls parameter cloud and does calculations:*

SAFE_calc <- function(formulas,
                      input_k,
                      plugin_effect_k,
                      sigma_matrix_k,
                      SAFE_boots = 1e6){
  #' *For debugging:*
  # input = input_k
  # sigma_matrix = sigma_matrix_k #' if specified by user. Otherwise calculated based on SAFE_family
  # SAFE_boots = SAFE_boots
  # 
  cloud <- parameter_cloud(formulas = formulas, 
                           paired = ifelse(grepl("paired", formulas$effect_size), 
                                           "yes", "no"),
                           input = input_k,
                           sigma_matrix = sigma_matrix_k, #' if specified by user. Otherwise calculated based on SAFE_family
                           SAFE_boots = SAFE_boots)
  # unique(cloud[, .(a, b, c, d)])
  
  # Add missing inputs (e.g., n)
  cloud <- data.table(cloud,
                      input_k[!names(input_k) %in% names(cloud)] |> unlist() |> t() |> data.table())
  
  # Convert cloud
  cloud_trans <- calc_effect(formulas = formulas[calc_type == "effect_size" &
                                                   derivative == "first", ],
                             input = cloud)$yi_first
  
  # bias corrected estimate of sampling variance and SE:
  safe_SE <- sd(cloud_trans)
  safe_vi <- safe_SE^2
  
  bias_SAFE <- mean(cloud_trans) - plugin_effect_k
  
  safe_yi <- plugin_effect_k - bias_SAFE
  
  return(data.table(yi_safe = safe_yi,
                    vi_safe = safe_vi,
                    SE_safe = safe_SE))
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -----------------------------------------
#' *CLOUD MAKER*
parameter_cloud <- function(formulas,
                            paired = "no",
                            input,
                            sigma_matrix = NULL,
                            SAFE_boots = 1e6){
  
  # Construct sigma matrices ------------------------------------------------
  if(any(formulas$SAFE_family %in% "1_normal")){
    if(is.null(sigma_matrix)){
      sigma_matrix <- input$sd / sqrt(input$n)
    }
    means <- c(x = input$x)
    
  }else if(any(formulas$SAFE_family %in% "2_multivariate_normal")){
    if(is.null(sigma_matrix)){
      
      sigma_matrix <- matrix(data = c((input$sd1^2 / input$n1),                    (input$r*input$sd1*input$sd2)/input$n1, #  / n1 add this to sd1^2
                                      (input$r*input$sd1*input$sd2)/input$n1,      (input$sd2^2 / input$n2)), #  / n2 add this to sd2^2
                             nrow = 2, ncol = 2)
      
    }
    means <- c(x1 = input$x1, x2 = input$x2)
    
  }else if(any(formulas$SAFE_family == "4_multivariate_normal_wishart")){
    if(is.null(sigma_matrix)){
      
      sigma_matrix <- matrix(c(input$sd1^2, input$r*input$sd1*input$sd2,
                               input$r*input$sd1*input$sd2, input$sd2^2), 
                             2, 2)
      
    }
    means <- c(x1 = input$x1, x2 = input$x2)
    
    # means <- c(x1 = input$x1, x2 = input$x2)
  }else if(any(formulas$SAFE_family == "4_multivariate_normal")){
    if(is.null(sigma_matrix)){
      
      sigma_matrix <- matrix(data = c(input$sd1^2/input$n1,                  (input$r*input$sd1*input$sd2)/input$n1, 0,                                                  0,
                                      (input$r*input$sd1*input$sd2)/input$n1, input$sd2^2/input$n2,                   0,                                                  0,
                                      0,                                      0,                                      (2*input$sd1^4)/(input$n1-1),                       ((2*input$r^2*input$sd1^2*input$sd2^2)/(input$n1-1)),
                                      0,                                      0,                                      (2*input$r^2*input$sd1^2*input$sd2^2)/(input$n1-1), (2*input$sd2^4)/(input$n2-1)),
                             nrow = 4,
                             ncol = 4)
      
    }
    means <- c(x1 = input$x1, x2 = input$x2, 
               v1 = input$sd1^2, v2 = input$sd2^2)
    
  }else if(any(formulas$SAFE_family %in% c("2_multinomial_as_normal"))){
    #' [The new lnOR / lnRR as normal simulating probabilities]
    if(is.null(sigma_matrix)){
      
      if(!"n1" %in% names(input)){
        input$n1 <- input$a + input$b
        input$n2 <- input$c + input$d
      }
      input$p1 <- input$a / input$n1
      input$p2 <- input$c / input$n2
      
      # This is variance, which is what mvrnorm wants:
      input$v1 <- input$p1 * (1 - input$p1) #/ input$n1
      input$v2 <- input$p2 * (1 - input$p2) #/ input$n2
      input$r <- 0
      
      # The top-left and bottom-right corneres formerly were sd1^2 / n1 & sd2^2 / n2
      sigma_matrix <- matrix(data = c((input$v1 / input$n1),                    (input$r*input$v1*input$v2)/input$n1, #  / n1 add this to sd1^2
                                      (input$r*input$v1*input$v2)/input$n1,      (input$v2 / input$n2)), #  / n2 add this to sd2^2
                             nrow = 2, ncol = 2)
      
    }
    means <- c(p1 = input$a/input$n1, p2 = input$c/input$n2)
  }
  
  
  # Parse upper and lower bounds for truncated normal ------------------------------------------------
  if(!all(is.na(formulas$lower_filter))){
    formulas$lower_filter
    
    lower <- data.table::tstrsplit(unique(formulas$lower_filter), ",") |> 
      unlist() |>
      tstrsplit("=")
    
    upper <- data.table::tstrsplit(unique(formulas$upper_filter), ",") |> 
      unlist() |>
      tstrsplit("=")
    
    
    var_guide <- data.table::data.table(variable = lower[[1]] |> trimws(),
                                        lower_bounds = lower[[2]] |> as.numeric(),
                                        upper_bounds = upper[[2]] |> as.numeric()) |>
      merge(data.table(mean=means, variable = names(means)),
            by = "variable")
    
    var_guide
    
  }else if(!unique(formulas$SAFE_family) %in% c("2_binomial", "4_binomial", "3_multinomial") &
           all(is.na(formulas$lower_filter))){
    var_guide <- data.table(mean=means |> as.numeric(), 
                            variable = names(means),
                            lower = -Inf,
                            upper = Inf)
  }
  
  
  # Create Gaussian clouds ------------------------------------------------------------
  if(unique(formulas$SAFE_family == "1_normal")){
    
    out <- data.table(x = rnorm(n=SAFE_boots,
                                mean = var_guide$mean, 
                                sd = sigma_matrix))
    return(out)
    
  }else if(unique(formulas$SAFE_family %in% c("4_multivariate_normal",
                                              "2_multivariate_normal",
                                              "2_multinomial_as_normal"))){
    
    out <- rtmvnorm(n = SAFE_boots,
                    mean = var_guide$mean,
                    sigma = sigma_matrix,
                    lower = var_guide$lower_bounds,
                    upper = var_guide$upper_bounds) |>
      as.data.frame() |>
      setDT()
    names(out) <- var_guide$variable
    
    #' *Back convert the variance hyperparameters to SD*
    if(unique(formulas$SAFE_family == "4_multivariate_normal")){
      out[, `:=` (sd1 = sqrt(v1), sd2 = sqrt(v2))]
      out[, `:=` (v1 = NULL, v2 = NULL)]
    }
    if(unique(formulas$SAFE_family == "2_multinomial_as_normal")){
      out[, `:=` (n1 = input$n1, n2 = input$n2)]
      out[, `:=` (a = round(p1 * n1),
                  c = round(p2 * n2))]
      out[, `:=` (b = n1 - a,
                  d = n2 - c)]
    }
    #' [I really don't like this degree of specificity of effect_type manipulation inside the function]
    if(unique(formulas$effect_size) == "lnRR"){
      out[a == 0, `:=` (a = a + 0.5,
                        n1 = n1 + 1) ]
      out[c == 0, `:=` (c = c + 0.5,
                        n2 = n2 + 1) ]
    }
    if(unique(formulas$effect_size) == "lnOR"){
      out[(a == 0 | b == 0 | c == 0 | d == 0), `:=` 
          (a = a + 0.5,
            b = b + 0.5,
            c = c + 0.5,
            d = d + 0.5)]
    }
    
    return(out)
  }else if(unique(formulas$SAFE_family %in% c("4_multivariate_normal_wishart"))){
    
    out <- MASS::mvrnorm(n = SAFE_boots,
                         mu = var_guide$mean,
                         Sigma = (sigma_matrix / c(input$n1, sqrt(input$n1*input$n2), sqrt(input$n1*input$n2), input$n2))) |>
      as.data.frame() |>
      setDT()
    names(out) <- var_guide$variable
    #
    wishart.out <-  stats::rWishart(SAFE_boots, 
                                    df = (input$n1-1), 
                                    Sigma = sigma_matrix) 
    
    out[, sd1 := sqrt(wishart.out[1, 1, ] / (input$n1 - 1))]
    out[, sd2 := sqrt(wishart.out[2, 2, ] / (input$n2 - 1))]
    out
    
    return(out)
  }
  
  # Count data clouds --------------------------------------------------------------
  if(any(formulas$SAFE_family == "2_binomial")){ # lnRR
    
    out <- data.table(a = rbinom(SAFE_boots, input$n1, input$a / input$n1) |> as.double(),
                      c = rbinom(SAFE_boots, input$n2, input$c / input$n2) |> as.double())
    out[, n1 := input$n1]
    out[, n2 := input$n2]
    
    out[a == 0, `:=` (a = a + 0.5,
                      n1 = n1 + 1) ]
    out[c == 0, `:=` (c = c + 0.5,
                      n2 = n2 + 1) ]
    return(out)
    
  }else if(any(formulas$SAFE_family == "4_binomial")){ # this is lnOR
    if(!all(c("n1", "n2") %in% names(input))){
      input$n1 <- input$a + input$b
      input$n2 <- input$c + input$d
    }
    out <- data.table(a = rbinom(SAFE_boots, input$n1, input$a / input$n1) |> as.double(),
                      #b = rbinom(SAFE_boots, input$n1, input$b / input$n1) |> as.double(),
                      c = rbinom(SAFE_boots, input$n2, input$c / input$n2) |> as.double()#,
                      #d = rbinom(SAFE_boots, input$n2, input$d / input$n2) |> as.double()
    )
    
    out[, `:=` (b = input$n1 - a,
                d = input$n2 - c)]
    # Add 0.5 to rows with ANY zero
    # if(nrow(out[(a == 0 | b == 0 | c == 0 | d == 0), ]) > 0){
    out[(a == 0 | b == 0 | c == 0 | d == 0), `:=` 
        (a = a + 0.5,
          b = b + 0.5,
          c = c + 0.5,
          d = d + 0.5)]
    # }
    return(out)
    
  }else if(any(formulas$SAFE_family == "3_multinomial")){
    N <- (input$n_AA + input$n_Aa + input$n_aa)
    out <- stats::rmultinom(n = SAFE_boots,
                            size = N,
                            prob = c(n_AA = input$n_AA/N,
                                     n_Aa = input$n_Aa/N,
                                     n_aa = input$n_aa/N)) |>
      t() |> # For some reason these are returned WIDE, with 3 rows and 1e6 columns. Weird. Was freezing computer
      as.data.frame()
    
    data.table::setDT(out)
    out[, `:=` (n_AA = as.double(n_AA),
                n_Aa = as.double(n_Aa),
                n_aa = as.double(n_aa))]
    
    # if(nrow(out[(n_AA == 0 | n_Aa == 0 | n_aa == 0), ]) > 0){
    out[(n_AA == 0 | n_Aa == 0 | n_aa == 0), 
        `:=` (n_AA = n_AA + 0.5,
              n_Aa = n_Aa + 0.5,
              n_aa = n_aa + 0.5)]
    # }
    
    return(out)
  }
  return(cat("unexpected error 1: SAFE_family did not match"))
}

