# airGLMs
Automatic Iterative Generalized Linear Model Selection

## Description

airGLMs is an R package for automatic iterative generalized linear model (GLM) selection.
It uses a forward stepwise selection process, calling the `glm` function available in base R and using AIC or BIC to select models.
The user determines dependent and independent variables, variable interaction terms, distributions and link functions and output file
name with plain text files. The package is focused on streamlined usability, as models for multiple dependent variables can be fitted
with a single function call. It also utilizes an efficient iterative approach: variables are tested and added sequentially, which 
avoids the need to exhaust the entire model space of all possible combinations of independent variables
and interaction terms, thus saving runtime and memory load.

## Dependencies

* R >= 3.6.3
* devtools >= 2.4.2 (for installation)

## Installation

    library("devtools")  
    install_github("JNisk/airGLMs")

## Usage

    library("airGLMs")
    models <- airglms(config_file, score="AIC")

where `config_file` is a path to a configuration file with analysis settings and `score` is one of `AIC` or `BIC`. An example config file
is included at [inst/extdata/example_config.txt](https://github.com/JNisk/airGLMs/blob/main/inst/extdata/example_config.txt).


An object containing the selected formula and a dataframe with stepwise information criterion scores for each dependent variable is returned. By default,
the dataframe is sorted by the order of the independent variables and interaction terms in the config file. To obtain dataframes sorted
by the scores, use option `sort="score"`. Also, two kinds of output are produced: a brief description of the analysis parameters in the console,
and more detailed log, including stepwise scores, is written to the output file specified by the user in the config file. For 
detailed output during the run, you can add option `verbose=TRUE`.

**Do note that `airglms` will raise a warning if missing data (NA) is detected in columns that are included in the base model, dependent variables
or independent variables.** If you encounter this warning, make sure to preprocess your data in a meaningful manner. Also, **if dependent and independent
variables overlap, the dependent variable will not be included as an independent variable when the model is being fitted**.

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
    > models <- airglms(example_config, score="AIC")
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
    
    > models
    $metabolite1
    $metabolite1$formula
    [1] "metabolite1 ~ gender"

    $metabolite1$scores
                         metabolite1 ~ gender
    metabolite1 ~ gender     3.97547479855492
    sterilization            4.41767088400479
    population               2.09808174145804

    $metabolite1$score_type
    [1] "AIC"

    $metabolite2
    $metabolite2$formula
    [1] "metabolite2 ~ gender + population"

    $metabolite2$AIC
                         metabolite2 ~ gender     + population
    metabolite2 ~ gender     244.134763387494                 
    sterilization            245.911514129003 243.788738728259
    population               241.950605943952                 
   
    $metabolite2$score_type
    [1] "AIC"    

    $metabolite3
    $metabolite3$formula
    [1] "metabolite3 ~ gender + population"

    $metabolite3$AIC
                         metabolite3 ~ gender      + population
    metabolite3 ~ gender    -51.1899719495492                  
    sterilization             -49.24248213259 -184.472867756109
    population              -186.321282984104                  
    
    $metabolite3$score_type
    [1] "AIC" 

    $metabolite4
    $metabolite4$formula
    [1] "metabolite4 ~ gender + population"
    
    $metabolite4$AIC
                         metabolite4 ~ gender     + population
    metabolite4 ~ gender     187.072728054696                 
    sterilization            188.295383832006 185.785732566012
    population               184.361896509834                 

    $metabolite4$score_type
    [1] "AIC" 

    $metabolite5
    $metabolite5$formula
    [1] "metabolite5 ~ gender"

    $metabolite5$AIC
                         metabolite5 ~ gender
    metabolite5 ~ gender    -208.903966099404
    sterilization           -207.753825389241
    population              -207.126193507209
    
    $metabolite5$score_type
    [1] "AIC"
    
A full log of the selection process, including stepwise scores, can be found in the output file
generated during the run (default in the demo: `example_results.txt`).

## In-depth description

Models for each dependent variable are selected iteratively. The flowchart of the process is depicted below:

![Flowchart of airGLMs algorithm](https://github.com/JNisk/airGLMs/blob/main/images/airGLMs.png?raw=true)

