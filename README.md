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

## Usage

    library("airGLMs")
    models <- airglms(config_file)

## Demo

    library("airGLMs")
    example_data <- read.table(system.file("extdata", "example_data.txt", package="airGLMs"), header=T, sep="\t")
    head(example_data)

    example_config <- system.file("extdata","example_config.txt",package="airGLMs")
    models <- airglms(example_config)
    head(models)

## In-depth description

Models for user-determined dependent variables are selected iteratively. The process for each dependent variable is as follows:

### Independent variables
1) fit base model and save AIC value
2) fit model with the glm function for each independent variable
3) select independent variable whose model has the smallest AIC value
4) compare new AIC value with previous AIC value
5) if delta AIC > 2, add the independent variable to model
6) repeat with remaining independing variables until delta AIC < 2 or no variables are left

### Interaction terms (optional)
1) discard interaction terms with one or both variables not included in selected independent variables
2) for remaining interaction terms, fit model with the glm function
3) select the interaction term whose model has the smallest AIC value
4) compare new AIC value with previous AIC value
5) if delta AIC > 2, add the independent variable to model
6) repeat with remaining interaction terms until delta AIC < 2 or no variables are left

Selected models are returned as a character vector, and detailed information about the process
and AIC values are written to a log file specified in the config file.
