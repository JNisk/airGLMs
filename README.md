# airGLMs
Automatic Iterative Generalized Linear Model Selection

## Description

airGLMs is an R package for automatic iterative generalized linear model (GLM) selection.
It uses a forward stepwise selection process with Akaike information criteria (AIC)
to select models with user-determined dependent and independent variables, variable interaction
terms, distributions and link functions and output file name. The package is focused on
streamlined usability, as models for multiple dependent variables can be fitted with a single function call.
It also utilizes an efficient iterative approach: instead of exhausting the entire model space
of all the possible combinations of independent variables and interaction terms, variables
are tested and added sequentially, which reduces runtime and memory load.

## Dependencies

* R >= 4.0.5
* devtools >= 2.4.2

## Installation

    library("devtools")  
    install_github("JNisk/airGLMs")

## Usage

    library("airGLMs")
    models <- airglms(config_file)

where `config_file` is a path to a configuration file with analysis settings. An example config file
is included at [inst/extdata/example_config.txt](https://github.com/JNisk/airGLMs/blob/main/inst/extdata/example_config.txt).

Two kinds of output will be generated: a brief description of the analysis parameters in the console,
and more detailed output, including stepwise AIC values, is written to the output file specified by
the user in the config file. For more detailed output during the run, you can add option `verbose=TRUE`.

In addition to the main functionality, you can also utilize helper functions `extract_variables` and `extract_interaction_variables`
to extract variable names from text formulas and interaction terms, respectively. Finally, function `clean_interaction` can be used to
ensure constant whitespacing in text interaction terms.

    > extract_variables("x ~ gender + population + gender*population")
    [[1]]
    [1] "gender"     "population"  "gender*population"
    
    > clean_interaction("gender*population")
    [1] "gender * population"
    
    > extract_interaction_variables <- extract_interaction_variables("gender * population")
    [1] "gender"     "population"

## Demo

    > library("airGLMs")
    > example_data <- read.table(system.file("extdata", "example_data.txt", package="airGLMs"), header=T, sep="\t")
    > example_data$gender <- as.factor(example_data$gender)
    > example_data$sterilization <- as.factor(example_data$sterilization)
    > example_data$population <- as.factor(example_data$population)
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
    initiate airglms

    data.frame: example_data 
    base model: x ~ gender 
    dependent variables: metabolite1, metabolite2, metabolite3, metabolite4, metabolite5 
    independent variables: sterilization, population 
    interactions: gender * sterilization 
    distribution table: C:/rlibs/4.0.5/airGLMs/extdata/example_distributions.txt 
    output file: example_results.txt 

    initiate selection
    metabolite1 
    metabolite2 
    metabolite3 
    metabolite4 
    metabolite5 

    finished run
    
    > head(models)
                                                        metabolite1 
                                             "metabolite1 ~ gender" 
                                                        metabolite2 
                "metabolite2 ~ gender + sterilization + population" 
                                                        metabolite3 
                                "metabolite3 ~ gender + population" 
                                                        metabolite4 
    "metabolite4 ~ gender + sterilization + gender * sterilization" 
                                                        metabolite5 
                                             "metabolite5 ~ gender" 

A full log of the selection process, including stepwise AIC values, can be found in the output file
generated during the run (default in the demo: `example_results.txt`).

## In-depth description

Models for each dependent variable are selected iteratively. The flowchart of the process is depicted below:

![Flowchart of airGLMs algorithm](https://github.com/JNisk/airGLMs/blob/main/images/airGLMs.png?raw=true)

