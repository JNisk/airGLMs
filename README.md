# airGLMs
Automatic Iterative Generalized Linear Model Selection

## Description

airGLMs is an R package for automatic iterative generalized linear model (GLM) selection.
It uses a forward stepwise selection process with Akake information criteria (AIC)
to select models with user-determined dependent and independent variables, variable interaction
terms, distributions and link functions and output file name. The module is focused on
easy usability, as models can be selected for several dependent variables with a single function call.

## Prerequisites

* R >= 4.0.5
* devtools >= 2.4.2

## Installation

    library("devtools")  
    install_github("airGLMs","JNisk")

## Demo

    library("airGLMs")
    example_data <- read.table(system.file("extdata", "example_data.txt", package="airGLMs"), header=T, sep="\t")
    head(example_data)

    example_config <- system.file("extdata","example_config.txt",package="airGLMs")
    models <- airglms(example_config)
    head(models)

## In-depth description

Models for all dependent variables are selected iteratively. The process is as follows:

### Independent variables
* select dependent variable
* fit base model and save AIC value
* fit model with the glm function for each independent variable
* select independent variable whose model has the smallest AIC value
* compare new AIC value with previous AIC value
* if delta AIC > 2, add the independent variable to model
* repeat with remaining independing variables until delta AIC < 2 or no variables are left

### Interaction terms (optional)
* discard interaction terms with one or both variables not included in selected independent variables
* for remaining interaction terms, fit model with the glm function
* select the interaction term whose model has the smallest AIC value
* compare new AIC value with previous AIC value
* if delta AIC > 2, add the independent variable to model
* repeat with remaining interaction terms until delta AIC < 2 or no variables are left

Selected models are returned as a character vector, and detailed information about the process
and AIC values are written to a log file specified in the config file.
