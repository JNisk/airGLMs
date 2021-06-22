# airGLMs
Automatic Iterative Generalized Linear Model Selection

## Description

airGLMs is an R package for automatic iterative generalized linear model (GLM) selection.
It uses a forward stepwise selection process with Akake information criteria (AIC)
to select models with user-determined dependent and independent variables, variable interaction
terms, distributions and link functions and output file name. The module is focused on
easy usability, as models for several dependent variables can be fitted with a single function call.

## Dependencies

* R >= 4.0.5
* devtools >= 2.4.2

## Installation

    library("devtools")  
    install_github("JNisk/airGLMs")

## Usage

    library("airGLMs")
    models <- airglms(config_file)

where `config_file` is a path to a configuration file with analysis settings.
An example config file is included at `inst/extdata/example_config.txt`.

## Demo

    > library("airGLMs")
    > example_data <- read.table(system.file("extdata", "example_data.txt", package="airGLMs"), header=T, sep="\t")
    > head(example_data)
           id gender sterilization population metabolite1 metabolite2 metabolite3 metabolite4 metabolite5
    1 animal1      2             2          1    1.044836    8.068995   0.1413869    5.139955   0.09383798
    2 animal2      1             2          1    1.279460    3.865621   0.1820434    5.219343   0.07448186
    3 animal3      2             2          1    1.339995    4.372346   0.1451240    5.090788   0.03456361
    4 animal4      1             2          1    1.189126    1.225629   0.1789631    8.230903   0.09430225
    5 animal5      2             2          1    1.287063    1.346630   0.1238135    6.138686   0.02224719
    6 animal6      1             2          1    1.263728    6.654097   0.1077216    5.745389   0.04984494

    > example_config <- system.file("extdata","example_config.txt",package="airGLMs")
    > models <- airglms(example_config)
    > head(models)
                                                        metabolite1 
                                             "metabolite1 ~ gender" 
                                                        metabolite2 
                             "metabolite2 ~ gender + sterilization" 
                                                        metabolite3 
                                "metabolite3 ~ gender + population" 
                                                        metabolite4 
    "metabolite4 ~ gender + sterilization + gender * sterilization" 
                                                        metabolite5 
                                             "metabolite5 ~ gender" 

A full log of the selection process, including stepwise AIC values, can be found in the output file (default: `results.txt`).

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
