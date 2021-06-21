# airGLMs
Automatic Iterative Generalized Linear Model Selection

## Description

airGLMs is an R package for automatic iterative generalized linear model (GLM) selection.
It uses a forward stepwise selection process with Akake information criteria (AIC)
to select models with dependent and independent variables as well as variable interaction
terms determined by the user. The module is focused on easy usability, as models
can be selected for several dependent variables with a single command.

## Prerequisites

* R >= 4.0.5
* devtools >= 2.4.2

## Installation

    library("devtools")  
    install_github("airGLMs","JNisk")
