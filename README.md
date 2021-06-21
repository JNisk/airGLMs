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

## In-depth explanation
