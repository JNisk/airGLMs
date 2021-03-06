#' Get parameter
#'
#' This function is used to extract parameters from config file.
#' Returns text after equals sign.
#' @param line Line of text from the config file
#' @param comma_split Whether the line is split by commas. Default: no (NULL).
#' @keywords parameter
#' @export
#' @examples
#' get_parameter("output = myfile.txt")

get_parameter <- function(line, comma_split = NULL){
  value <- as.list(strsplit(line, " = ")[[1]])[[2]]
  if (!is.null(comma_split)) {
    value <- as.vector(lapply(strsplit(value, ","),trimws))[[1]]
  }
  return(value)
}

#' Write to log file
#'
#' This function is used to append a list of text to a file.
#' Does not return anything.
#' @param file Filename
#' @param ... One or more R objects to be written as text to the file.
#' @keywords log
#' @export
#' @examples
#' write_log("mylog.txt", "Hello world!")

write_log <- function(file, ...){
  text <- paste(list(...), collapse=" ")
  write(text, file=file, append=TRUE)
}

#' Extract variables
#'
#' This function is used to extract variables from a text formula.
#' Returns a list.
#' @param text_formula A string representation of a formula.
#' @keywords variable
#' @export
#' @examples
#' extract_variables("x ~ a + b")

extract_variables <- function(text_formula){
  variables <- strsplit(text_formula, " ~ ")[[1]][2]
  variables <- strsplit(variables, " \\+ ")
  return(variables)
}

#' Extract interaction variables
#'
#' This function is used to extract variables from a text interaction formula.
#' Returns a list.
#' @param interaction A string representation of an interaction formula.
#' @keywords variable
#' @export
#' @examples
#' extract_variables("a * b")

extract_interaction_variables <- function(interaction){
  variables <- strsplit(interaction, " \\* ")[[1]]
  return(variables)
}

#' Tidy interaction terms
#'
#' This function is used to introduce consistent whitespaces in a text interaction formula.
#' Returns a character vector.
#' @param interaction A string representation of an interaction formula.
#' @keywords interaction
#' @export
#' @examples
#' extract_variables("a*b")

clean_interaction <- function(text_interaction){
  tmp_text <- as.list(strsplit(text_interaction, "\\*"))[[1]]
  tmp_text <- as.vector(lapply(tmp_text,trimws))
  return(paste(tmp_text, collapse = " * "))
}

#' Select generalized linear models automatically
#'
#' The main function of the package.
#' It is used to automatically select generalized linear models (GLM).
#' The dependent and independent variables and interactions to be tested,
#' distributions and link functions, base model, data frame and 
#' output file name are determined by the user in a configuration file.
#' GLM selection is performed with forward stepwise selection
#' using AIC or BIC.
#' Returns a character vector with models for each dependent variable,
#' and writes detailed output to the file specified.
#' @param config_file Name of the configuration file with analysis settings.
#' @param score Which information criteria to use (one of: AIC, BIC)
#' @param verbose Print intermediate results of GLM selection while running (default: FALSE)
#' @param sort How the dataframes in the resulting object will be sorted (default: in given order, score: by scores)
#' @export
#' @examples
#' airglms("myconfig.txt")

airglms <- function(config_file, score, verbose=FALSE, sort="default"){

  if (score != "AIC" && score != "BIC") {
    stop("invalid value for option verbose (use one of: AIC, BIC)")
  }

  if (verbose != FALSE && verbose != TRUE) {
    stop("invalid value for option verbose (use either TRUE or FALSE)")
  }
	
  if (sort != "default" && sort != "score") {
    stop("invalid value for option sort (use one of: default, score)")
  }

  # create a named list where parameters from config file will be stored
  config <- list()

  # open config file and read lines to list
  config_file_content <- readLines(config_file)

  # check each line in config file
  for (line in config_file_content) {
  
    # data frame object
    if (startsWith(line, "data =")) {
      config$data <- get_parameter(line)
    
    # output file name
    } else if (startsWith(line, "output = ")) {
      log_file <<- get_parameter(line)
    
    # distribution table name
    } else if (startsWith(line, "distributions = ")) {
      param <- get_parameter(line)
    
      # if demo mode in use, use proper extdata path
      if (startsWith(param, "system.file")) {
        param <- paste(system.file("extdata", "example_distributions.txt", package="airGLMs"))
      }
      config$table <- param
      
    # base model
    } else if (startsWith(line, "base model = ")) {
      config$base_model <- get_parameter(line)
    
    # dependent variables
    } else if (startsWith(line, "dependent = ")) {
      config$dependent <- get_parameter(line, comma_split=TRUE)
    
    # independent variables
    } else if (startsWith(line, "independent = ")) {
      config$independent <- get_parameter(line, comma_split=TRUE)
    
    # interactions
    } else if (startsWith(line, "interactions = ")) {
      config$interactions <- get_parameter(line, comma_split=TRUE)
    }
  }
  
  # clean interaction terms
  config$interactions <- lapply(config$interactions, clean_interaction)
  
  # start writing log (first time only without write_log wrapper function)
  write(paste("started run: ", Sys.time(), "\n", sep=""), file=log_file)
  
  write_log(file=log_file, "read config file from:",config_file)
  write_log(file=log_file, "\nusing the following settings:")
  write_log(file=log_file, "* output file:",log_file)
  write_log(file=log_file, "* data.frame:",config$data)
  write_log(file=log_file, "* base model:",config$base_model)
  write_log(file=log_file, "* dependent variables:", paste(config$dependent, collapse=", "))
  write_log(file=log_file, "* independent variables:", paste(config$independent, collapse=", "))
  write_log(file=log_file, "* interactions:", paste(config$interactions, collapse=", "))
  write_log(file=log_file, "* distribution table:",config$table)
  
  cat("initiate airglms\n\n")
  cat(paste("data frame:",config$data,"\n"))
  cat(paste("base model:",config$base_model,"\n"))
  cat(paste("dependent variables:",paste(config$dependent, collapse=", "),"\n"))
  cat(paste("independent variables:",paste(config$independent, collapse=", "),"\n"))
  cat(paste("interactions:",paste(config$interactions, collapse=", "),"\n"))
  cat(paste("distribution table:",config$table,"\n"))
  cat(paste("output file:",log_file,"\n"))
  
  ### open distribution table file
  
  # open distribution file and read lines to list
  table_file <- read.table(config$table, header=T, stringsAsFactors=FALSE)
  rownames(table_file) <- table_file[,1]
  table_file[,1] <- NULL
  
  ### access and cross-check data
  
  write_log(file=log_file, "\naccessing data")
  
  if(!(exists(config$data))) {
    stop(paste("no such variable found:",config$data,sep=" "))
  }
  
  config$data <- eval(parse(text = config$data))
  
  write_log(file=log_file, "in the data frame, found:")
  write_log(file=log_file, ncol(config$data), "columns")
  write_log(file=log_file, nrow(config$data), "rows")
  
  #### check that dependent and independent variables exist in data
  write_log(file=log_file, "\nchecking that variable names exist in data")
  
  if (!all(config$dependent %in% colnames(config$data))) {
    write_log(file=log_file, "\nERROR: did not find all dependent variables in data")
    stop("not all dependent variables found in data")
  } else {
    write_log(file=log_file, "dependent variables: ok")
  }
  
  if (!all(config$independent %in% colnames(config$data))) {
    write_log(file=log_file, "\nERROR: did not find all independent variables in data")
    stop("not all independent variables found in data")
  } else {
    write_log(file=log_file, "independent variables: ok")
  }
  
  ### check that dependent variables exist in distribution table
  
  write_log(file=log_file, "\nchecking that all dependent variables are in the distribution table file")
  
  if (all(config$dependent %in% rownames(table_file))) {
    write_log(file=log_file, "ok")
  } else {
    write_log(file=log_file, "ERROR: did not find all dependent variables")
    stop(paste("not all dependent variables found in the distribution table"))
  }
  
  ### check that variables in interactions exist in base model + independent variables
  
  if (length(config$interactions) > 0) {
    
    write_log(file=log_file, "\nchecking that variables of interactions exist")
    all_variables <- c(extract_variables(config$base_model)[[1]],config$independent)
    
    for (i in config$interactions) {
      tmp_variables <- extract_interaction_variables(i)
      if (!all(tmp_variables %in% all_variables)) {
        write_log(file=log_file, "ERROR: did not find all variables of interaction",i)
        stop(paste("not all variables of interaction",i,"found in base model and independent variables"))
      }
    write_log(file=log_file, "ok")
    }
  }
  
  ### check that there are no NA's in data
  
  base_variables <- extract_variables(config$base_model)
  
  for (col in colnames(config$data)) {
    if (col %in% base_variables || col %in% config$independent || col %in% config$dependent) {
	  num_na = sum(is.na(config$data[[col]]))
	  if (num_na > 0) {
	    warning(paste(c(num_na," missing values (NA) detected in column '",col,"'"), sep=""))
      }
	}
  }
  
  
  ### main loop
  
  write_log(file=log_file, "\nstart iteration")
  
  # named list
  #selected_models <- setNames(c(rep("",length(config$dependent))), c(config$dependent))
  selected_models <- list()
  
  # text for a nice log 
  round_text <- "\n... round"
  
  cat("\ninitiate selection\n")
  
  # use one dependent variable (d) at a time
  for (d in config$dependent) {
	
    # nested list for storing formula and scores
    selected_models[[d]] <- list()  
  
    if (verbose) {
      cat(paste("\n\n*** ",d," ***\n", sep=""))
    } else {
      cat(paste(d,"\n"))
    }
    
    write_log(file=log_file, "\n-----")
    write_log(file=log_file, "dependent variable:",d)
    
    distribution <- table_file[d,"distribution"]
    link_function <- table_file[d,"link_function"]
    
    write_log(file=log_file, "distribution:",distribution)
    write_log(file=log_file, "link:",link_function)
	
    # keep track of rounds
    iter_round = 1
    
    # convert base model from text to formula
    # replace x with dependent variable
    text_formula <- gsub("x ~", paste(d," ~", sep=""), config$base_model)
    variable_order <- c(text_formula)
	
    df <- data.frame("tmp"=rep("",length(config$independent)+1))
    names(df)[1] <- text_formula
    rownames(df) <- c(c(text_formula),config$independent)
    
    formula <- as.formula(text_formula)
    write_log(file=log_file, "base model:",text_formula)
    
    # starting model
    model <- glm(formula, data=config$data, family=do.call(distribution, list(link=link_function)))
	if (score == "AIC") {
	  current_score <- model$aic
	} else if (score == "BIC") {
	  current_score <- BIC(model)
	}
    df[text_formula,text_formula] <- current_score
    
    if (verbose) {
      cat(paste("\nstarting ",score," ",current_score,"\n"))
    }
    write_log(file=log_file, "base",score,":",current_score)
    
    # put all independent variables to vector
    # variables will be dropped from this vector one at a time if they are added to model
    remaining_variables <- config$independent
	
	# make sure that dependent variable is not in independent variables
	if (d %in% remaining_variables) {
		warning(paste(c("independent variables include the dependent variable, skip ", d, " in model fitting"), sep=""))
		remaining_variables <- remaining_variables[!remaining_variables == d]
	}
    
    # test independent variables in a while loop
    # when improvement is set to false, loop ends
    improvement <- TRUE
    
    
    if (verbose) {
      cat("\n- independent variables -\n")
    }
    
    while (improvement) {
      
      write_log(file=log_file, round_text, iter_round)
      
      # initiate named vector with temporary value 0
      # 0 will be replaced by score
      temp_score <- setNames(c(rep("",length(remaining_variables))), c(remaining_variables))
      
      ### independent variables
      
      # test each independent variable (r) at a time
      for (r in remaining_variables) {
        formula <- as.formula(paste(text_formula, "+", r, sep=" "))
        tmp_model <- glm(formula, data=config$data, family=do.call(distribution, list(link=link_function)))
        
		if (score == "AIC") {
		  tmp_score <- as.numeric(tmp_model$aic)
		} else if (score == "BIC") {
		  tmp_score <- as.numeric(BIC(tmp_model))
		}
		
        # replace 0 with score
        temp_score[[r]] <- tmp_score
        df[r,text_formula] <- tmp_score
        
        write_log(file=log_file, r,temp_score[[r]])
      }
      
      # find the variable that has the smallest score
      best_variable <- names(temp_score)[which.min(temp_score)]
      
      write_log(file=log_file, "\nlargest delta ",score,":",best_variable)
      
      # report collected scores to screen
      if (verbose) {
        cat(paste("\nround",iter_round,score," values\n"))
        for (r in remaining_variables){
          cat(paste(r,temp_score[[r]],"\n"))
        }
      }
      
      # score difference > 2
      if ((current_score - as.numeric(temp_score[[best_variable]])) > 2) {
        
        # update score
        current_score <- as.numeric(temp_score[[best_variable]])
        # drop best variable from next round
        remaining_variables <- remaining_variables[!remaining_variables == best_variable]
        variable_order <- append(variable_order,best_variable)
		
        write_log(file=log_file, score," difference > 2, add variable to model and continue")
        
        # update model and score dataframe
        text_formula <- paste(text_formula, "+", best_variable)
        df["tmp"] <- ""
        names(df)[length(df)] <- text_formula
        
        if (verbose) {
          cat(paste("delta",score,"> 2\n"))
          cat(paste("\nformula:",text_formula,"\n"))
        }
        
        # stop if no more independent variables remain
        if (length(remaining_variables) == 0) {
          improvement <- FALSE
          write_log(file=log_file, "no more independent variables left")
          
          if(verbose) {
            cat("no more variables left\n")
          }
        }
        
      # score difference < 2
      } else {
        # this triggers the loop to end
        improvement <- FALSE
        
        if (verbose) {
          cat(paste("delta",score,"< 2\n"))
		  cat(paste("\nformula:",text_formula,"\n"))
        }
        
        write_log(file=log_file, score," difference < 2, finished independent variables")
      }
    
      iter_round <- iter_round + 1

    }
	
    # update variable order by score
    # from smallest to largest

	if (length(remaining_variables) > 0) {
		remaining_variables_order <- names(temp_score[order(unlist(temp_score))])
	} else {
		remaining_variables_order <- c()
	}
    variable_order <- append(variable_order, remaining_variables_order)

    # check from text formula which independent variables were included
    included_variables <- extract_variables(text_formula)[[1]]
    
    ### interactions
    
    # initiate placeholder vector for interactions
    remaining_interactions <- rep(NA, length(config$interactions))
    
    if (length(remaining_interactions) > 0) {
      
      # check for each interaction if their variables exist in model so far
      for (i in 1:length(config$interactions)) {
        tmp_interaction <- config$interactions[i][[1]]
        tmp_variables <- extract_interaction_variables(tmp_interaction)
        
        # if yes, add interaction to list of those that will be tested
        if (all(tmp_variables %in% included_variables)) {
          remaining_interactions[i] <- tmp_interaction
        }
      }
      # remove placeholder NA's
      remaining_interactions <- remaining_interactions[!is.na(remaining_interactions)]
    }
    
    if (verbose) {
      cat("\n- interactions -\n")
    }
    
    # test all interactions that include both  independent variables in the model
    if (length(remaining_interactions) > 0) {
      
      # add interactions to dataframe
	  for (i in remaining_interactions) {
	    df[nrow(df)+1,] <- ""
		rownames(df)[nrow(df)] <- i
	  }
	  
      improvement <- TRUE
      while (improvement) {
        
        write_log(file=log_file, round_text, iter_round)
        
        # initiate named vector with temporary value 0
        # 0 will be replaced by score
        temp_score <- setNames(c(rep(0,length(remaining_interactions))), c(remaining_interactions))
        
        # test each interaction (i) at a time
        for (i in remaining_interactions) {
          
          formula <- as.formula(paste(text_formula, "+", i, sep=" "))
          
          tmp_model <- glm(formula, data=config$data, family=do.call(distribution, list(link=link_function)))
          
          # replace 0 with score and update df
          if (score == "AIC") {
	    tmp_score <- tmp_model$aic
	  } else if (score == "BIC") {
	    tmp_score <- BIC(tmp_model)
	  }
          temp_score[[i]] <- tmp_score
          df[i,text_formula] <- tmp_score
		  
          write_log(file=log_file, i,temp_score[[i]])
        }
        
        # find the interaction that has the smallest score
        best_interaction <- names(temp_score)[which.min(temp_score)]
        
        write_log(file=log_file, "\nlargest delta AIC:",best_interaction)
        
        # report collected scores to screen
        if (verbose) {
          cat(paste("\nround",iter_round,score," values\n"))
          for (i in remaining_interactions) {
            cat(paste(i, temp_score[[i]], "\n"))
          }
        }
        
        # score difference > 2
        if ((current_score - temp_score[[best_interaction]]) > 2) {
          
          # update score
          current_score <- temp_score[[best_interaction]]
          # drop best variable from next round
          remaining_interactions <- remaining_interactions[!remaining_interactions == best_interaction]
          variable_order <- append(variable_order,best_interaction)
		  
          write_log(file=log_file, score," difference > 2, add interaction to model and continue")
          
          # update model and df
          text_formula <- paste(text_formula, "+", best_interaction)
		  
          if (verbose) {
            cat(paste("delta",score, "> 2\n"))
            cat(paste("\nformula:",text_formula,"\n"))
          }
          
          # stop if no more independent interactions remain
          if (length(remaining_interactions) == 0) {
            improvement <- FALSE
            write_log(file=log_file, "no more interactions left")
            
            if (verbose) {
              paste("no more interactions left")
            }     
          }
          
        # score difference < 2
        } else {
          # this triggers the loop to end
          improvement <- FALSE
		  
          if (verbose) {
            cat(paste("delta",score, "< 2\n"))
          }

          write_log(file=log_file, score," difference < 2, finished interactions")
        }
        iter_round <- iter_round + 1
        
      }
      
    } else {
      write_log(file=log_file, "\neither no interactions selected or none included both variables in the model")
      write_log(file=log_file, "skip interactions")
      
      if (verbose) {
        cat("\nno interactions selected or none included both variables in the model\n")
      }
    }

    if (verbose) {
      cat(paste("\nfinal formula:",text_formula,"\n"))
    }
	
	# establish order of interactions by score
	# from smallest to largest

	if (length(remaining_interactions) > 0) {
		remaining_interactions_order <- names(temp_score[order(unlist(temp_score))])
	} else {
		remaining_interactions_order <- c()
	}
    variable_order <- append(variable_order, remaining_interactions_order)

    # save selected model
    selected_models[[d]][["formula"]] <- text_formula
    # update df names
    if (ncol(df) >= 2) {
      for (n in 2:ncol(df)) {
        tmp <- strsplit(colnames(df)[n], " \\+ ")[[1]]
        colnames(df)[n] <- paste("+",tmp[[length(tmp)]])
      }
    }
		
	# sort dataframe
    if (sort == "score") {
      if (ncol(df) == 1) {
	    # temporarily add dummy column to enable sorting
		# sorting of one-column dataframes is tricky
	    df$dummy <- NA
        df <- df[order(df[[1]], decreasing=TRUE),]
		df$dummy <- NULL
      } else {
		df <- df[match(variable_order, rownames(df)),]
      }
    }
	
    selected_models[[d]][["scores"]] <- df
	selected_models[[d]][["score_type"]] <- score
    
  }
  
  ### finish run
  
  write_log(file=log_file, "\n---")
  write_log(file=log_file, "selected models:\n")
  
  for (d in config$dependent) {
    #write_log(file=log_file, selected_models[[d]])
    write_log(file=log_file, selected_models[[d]][["formula"]])
  }
  
  write(paste("\nfinished run: ", Sys.time(), "\n", sep=""), file=log_file, append=TRUE)
  
  if (verbose) {
    cat("\n*** selected models ***\n\n")
    print(selected_models)
  } else {
    cat("\nfinished run\n")
  }
  
  return(selected_models)
  
}
