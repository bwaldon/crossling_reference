library(tidyverse)
library(grid)
library(gridExtra)
library(viridis)
library(jsonlite)
library('varhandle')
library("stringr")

# Set working directory = R code knows where to get relevant documents
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# RUN WEBPPL FROM A V8 JS ENGINE (FASTER WHEN YOU NEED TO RUN MANY, MANY CALLS TO WEBPPL)
source("../../_shared/V8wppl.R")

# SOURCE SOME HELPER SCRIPTS

# Load all the functions found in stefanSimulationHelpers.R
#   This contains the runModel function that interacts with the V8 engine
#   and runs the code in Webppl online
source("stefanSimulationHelpers.R")

# Source the engine
# Engine = basic RSA model in webppl code (all the speaker and listener functions)
engine <- read_file("stefanEngine.txt")
angEngine <- read_file("angEngine.txt")

# Load all the extra semantic functions that are required for the main Serbo-Croatian
#   semantics function to run, but that are not found in the csv file created by stefanAllScenarios.py
semanticHelperFunctions <- read_file("stefanSemanticHelperFunctions.txt")

envCode <-read_file("createEnv.txt")
# load in csv file with conditions to run
# Load the csv file with all the conditions to run. This csv file is created by 
#   stefanAllScenarios.py. It contains the following columns:
# states: a set states that defines the particular scenario we are running
# command: command/model type, aka is semantics boolean or continuous and
#       are we using the incremental or vanilla/global model
# target: the target object
# utterance: one of the utterances that could apply to that scenario. This field is NA
#       for global utterance commands because only the incremental utterance commands
#       require us to specify a single utterance
# model: RSA model function with all words and their noise/cost, this is a string
#       of javaScript code
# Semantics: RSA semantics function with all dictionary entries and their noise
#       this is a string of javaScript code
scenariosToRun <- read.csv("../series/series1/model_input/stefanScenarioSeries1.csv", as.is = TRUE)
scenariosToRun_2 <- read.csv("../series/series1/model_input/ang_model_input.csv", as.is = TRUE)
# Do to a bug in the python script, we have duplicates of boolean semantic rows
# therefore we only want to get the unique rows
scenariosToRun <- unique(scenariosToRun)


# Function that takes in values from each row of the scneariosToRun csv file
#   run the model on those values, and return the speaker probability
# Input:
#   States: list of states
#   command: The type of model which should be run. Command is a string of one of the following types:
#     globalbool = global utterance/vanilla model with boolean semantics
#     globalcont = global utterance/vanilla model with continuous/noisy semantics
#     incBool = incremental model with boolean semantics
#     incCont = incremental model with continuous semantics
#   target: target state
#   utterance: a single utterance which applies to at least one state in the list of states
#   model: string of JS code, model function which is needed in the RSA input with values pertaining to
#     this scenario
#   semantics: string of JS code, semantics function for Serbo-Croatian with values pertaining to this scenario
#   parameters: 
# Output: A single number representing speaker probability of producing the given utterance and target
runModelWrapper <- function(states, commandType, command, target, utterance, allUtterances, model, semantics, 
                            alpha, sizeNoise, colorNoise, genderNoise, nounNoise, colorCost, sizeCost, nounCost) {

  runModel('V8', engine, model, semantics, semanticHelperFunctions, command, states, allUtterances,
          alpha, sizeNoise, colorNoise, genderNoise, nounNoise,
           colorCost, sizeCost, nounCost)
}

runModelWrapper2 <-function(ref, nouns, adj, sizeAdj, sizeNoise, colorNoise, nounNoise, lang){
  
  all <- createEnv(envCode, ref, nouns, adj, sizeAdj, sizeNoise, colorNoise, nounNoise)
  newEnv <- data.frame(0)
  groups <- strsplit(all, ':')
  groups <- as.data.frame(groups)
  states <- groups[1,]
  states <- strsplit(states, ",")
  states <- toString(states)
  statesStripped <- substr(states, 3, nchar(states)-1)
  semantics <- groups[2,]
  semantics <- strsplit(semantics, ",")
  semantics <- toString(semantics)
  semStripped <- substr(semantics, 7, nchar(semantics)-1)
  semRef <- str_replace_all(semStripped, ", \"_\", ", "],[")
  words <- groups[3,]
  words <- strsplit(words, ",")
  words <- toString(words)
  wordsStripped <- substr(words, 7, nchar(words)-1)
  utterances <-groups[4,]
  utterances <- strsplit(utterances, ",")
  utterances <- toString(utterances)
  utterancesStripped <- substr(utterances, 7, nchar(utterances)-1)
  utterancesLang <- str_replace_all(utterancesStripped, ", \"_\", ", "],[")
  newEnv$states <- statesStripped
  newEnv$semantics <- semRef
  newEnv$words <- wordsStripped
  newEnv$utterances <- utterancesLang
  return(runModel_2('V8', angEngine, newEnv, lang))
}
# Turn the contents of the csv file into a data frame
scenarios <- data.frame(scenariosToRun)
scenarios2 <- data.frame(scenariosToRun_2)

newEnv <- runModelWrapper2(scenarios2$Objects, scenarios2$Nouns, scenarios2$Adjectives, 
                           scenarios2$Size_adjectives, scenarios2$size_noise,scenarios2$color_noise,
# Run the model on all rows, each representing a single scenario with a specific set
# of parameters to be ran.
scenarios <- scenarios %>%
  mutate(output = sapply(
  split(scenarios, 1:nrow(scenarios)),
  function(x) do.call(runModelWrapper, x)
))


# Incremental versus global models return different outputs. Therefore we must split them up and
#   manipulate them to have them be of the same format
# For the incremental models there is a single row per utterance, and the output column contains 
#   a single value corresponding to the probability of the speaker producing that utterance given
#   the condition. This is the format that we want all the data to be in
# For the global/vanilla models, each row represents a scenario including all possible utterances.
#   the output is a string of all the utterances the speaker could produce, along with the probabilities
#   that they produce that utterance.

globalScenarios <- scenarios %>%
  filter(scenarios$commandType == "globalBool" | scenarios$commandType == "globalCont")

incrementalScenarios <- scenarios %>%
  filter(scenarios$commandType == "incBool" | scenarios$commandType == "incCont")
incrementalScenarios$output <- as.numeric(incrementalScenarios$output)

# The RSA for incremental utteracnes outputs a single number
# but for global utterances it produces a whole string, so we want to split that string up

###
# FORMAT THE GLOBAL SCENARIOS
#
# This section of the code takes the string model output of the global scenarios
# which looks like "Margin: 'START big_masc STOP' : 0.503, 'START big_masc blue_masc STOP' : 0.345, ..."
# and converts it to a data frame, whereby each row represents a single utterance that
# can apply to a specific scenario. Thus a single scenario will have n rows, such that
# there are n utterances that apply to the scenario. 


# Function that expands the of the RSA models and turns them into a dataframe
# Input: String representing output of RSA model (for a single scenario)
# Output: a data frame with two columns: utterances and probabilities
expandOutput <- function(output) {
  
  #output is a vector containing all unformatted outputs from the global contexts
  # tester <- globalScenarios[19,17]
  
  #split up the input
  wordsAndNumbers <- unlist(str_split(output, "\n"))
  
  # get rid of the string "Marginal:"
  #wordsAndNumbers <- wordsAndNumbers[!grepl(paste0("Marginal:", collapse = "|"), wordsAndNumbers)]
  wordsAndNumbers <- wordsAndNumbers[-1]
  
  # extract the numbers from the output
  # Treats "e-" in strings as something to separate the string by rather than part of the number
  getNumbers <- function(fullString) {
    
    #strings are of the following format:
    #"    \"START plate_masc STOP\" : 1.5679677389425024e-7"
    
    # split the string 
    splitString <- unlist(str_split(fullString, " : "))
    
    #return the second element (i.e. just the number)
    return(as.numeric(splitString[2]))
  }
  
  outputNumbers <- wordsAndNumbers %>% map_dbl(getNumbers)
  
  #extract the utterances
  extractUtterances <- function(oneUtterance) {
    oneUtterance <- gsub('[[:digit:]]+', '', oneUtterance)
    oneUtterance <- gsub('\" : .', '', oneUtterance)
    oneUtterance <- gsub('    \"', '', oneUtterance)
    oneUtterance <- gsub('e-', '', oneUtterance)
    return(oneUtterance)
  }
  
  outputUtterances <- map_chr(wordsAndNumbers, extractUtterances)
  return(data.frame(outputUtterances, outputNumbers))
}

# Expand the output of each scenario into the proper format and add it to the global scenarios data frame
globalScenarios$newDataFrames <- globalScenarios %>%
  select(output) %>%
  pmap(expandOutput)

#Expand the column with the newly formatted output
unnestedGlobal <- globalScenarios %>%
  unnest_longer(newDataFrames)

# Copy over those values into non-nested columns and delete the nested data
unnestedGlobal$utterance <- unnestedGlobal$newDataFrames$outputUtterances
unnestedGlobal$output <- unnestedGlobal$newDataFrames$outputNumbers
unnestedGlobal <- unnestedGlobal %>%
  select(-c(newDataFrames))

#########
# We now have a properly formatted global scenario data frame


#Merge global back in with main
scenariosFinal <- bind_rows(incrementalScenarios, unnestedGlobal)

# Output this as a csv file so that we don't have to rerun this code again and again because it takes a long time
write.csv(scenariosFinal,"stefanTestSeries1/series1Formatted.csv", row.names = FALSE)



#############################################
#############################################
#
# Section 2: Plot utterance probabilities
#
#############################################
#############################################


# In case you've already run the above code in section 1, and just want to plot the data, without rerunning
# the code, import the csv file that was written above with the following two lines of code
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
scenariosFinal <- read.csv("stefanTestSeries1/series1Formatted.csv", as.is = TRUE)

# Function that graphs utterance probabilities
# INPUT: 
# row of a dataframe with following three columns (in order):
#   String of states thata define that scenario
#     e.g. "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc']"
#   String of the target object
#     e.g. "blue_plate_masc"
#   Scenario number (i.e. identifying number of that scenario)
#
# OUTPUT:
# scenario[scenarioNumber]_ContModels.jpeg: 
#   graph that contains utterance probabilities for incremental Continuous and 
#   global continuous models for gender Noise values of {0.8, 1.0} and word
#   costs of {0, 0.1}
# scenario[scenarioNumber]_Noise1.jpeg:
#   graph that contains utterance probabilities for all four models {global boolean,
#   global continuous, incremental boolean, incremental continuous} for word costs of
#   {0, 0.1} when gender Noise is set to 1
# scenario[scenarioNumber]_Noise08.jpeg:
#   graph that contains utterance probabilities for all four models {global boolean,
#   global continuous, incremental boolean, incremental continuous} for word costs of
#   {0, 0.1} when gender Noise is set to 0.8
graphScenario <- function(inputDF) {
  # get input by column
  statesInput = inputDF[1]
  targetInput = inputDF[2]
  scenarioNum = inputDF[3]

  # Get the correct scenario from the master
  #   scenario dataframe (that contains all the utterance probabilities)
  scenario <- scenariosFinal %>%
    filter(target == targetInput & states == statesInput)

  # Graph all continous model graphs
  graphScenarioCont <-  scenario %>%
    filter(scenario$commandType == "globalCont" |
             scenario$commandType == "incCont")%>%
    group_by(commandType, genderNoise) %>%
    mutate(identifier = paste(commandType, ", cost: ", sizeCost, ", genderNoise: ", genderNoise, sep = "")) %>%
    ggplot(aes(x=utterance,y=output)) +
    geom_bar(stat="identity") +
    facet_wrap(~identifier, ncol = 4) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))


  # Graphs by genderNoise and sizeCost
  graphScenarioNoise08 <- scenario %>%
    filter(scenario$genderNoise == 0.8 |
             scenario$commandType == "globalBool" |
             scenario$commandType == "incBool") %>%
    mutate(identifier = paste("cost: ", sizeCost, ", ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
    ggplot(aes(x=utterance,y=output)) +
    geom_bar(stat="identity") +
    facet_wrap(~identifier, ncol = 4) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))

  graphScenarioNoise1 <- scenario %>%
    filter(scenario$genderNoise == 1.0 |
             scenario$commandType == "globalBool" |
             scenario$commandType == "incBool") %>%
    mutate(identifier = paste("cost: ", sizeCost, ", ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
    ggplot(aes(x=utterance,y=output)) +
    geom_bar(stat="identity") +
    facet_wrap(~identifier, ncol = 4) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))


  # Create file names with relevant paths
  contModelName <- paste("stefanTestSeries1/scenario", scenarioNum, "_ContModels.jpeg", sep = "")
  graph2Name <- paste("stefanTestSeries1/scenario", scenarioNum, "_Noise08.jpeg", sep = "")
  graph3Name <-paste("stefanTestSeries1/scenario", scenarioNum, "_Noise1.jpeg", sep = "")

  #Export the plots
  jpeg(file=contModelName, width = 1500, height = 1000)
  plot(graphScenarioCont)
  dev.off()

  jpeg(file=graph2Name, width = 1500, height = 1000)
  plot(graphScenarioNoise08)
  dev.off()

  jpeg(file=graph3Name, width = 1500, height = 1000)
  plot(graphScenarioNoise1)
  dev.off()
}


# Create data frame where each row is a single scenario that should be graphed
# Data frame should have following three columns in the given order:
# 1. String of states thata define that scenario
#     e.g. "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc']"
# 2. String of the target object
#     e.g. "blue_plate_masc"
# 3. Scenario number (i.e. identifying number of that scenario)
graphDF <- data.frame(
  scenarios = c("['blue_plate_masc', 'red_plate_masc', 'red_plate_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'red_knife_masc']",
                "['blue_plate_masc', 'blue_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc']",
                "['blue_plate_masc', 'red_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'blue_cup_fem']",
                "['blue_plate_masc', 'red_plate_masc', 'red_cup_fem']",
                "['blue_plate_masc', 'blue_knife_masc', 'blue_cup_fem']",
                "['blue_plate_masc', 'blue_knife_masc', 'red_cup_fem']",
                "['blue_plate_masc', 'red_knife_masc', 'blue_cup_fem']",
                "['blue_plate_masc', 'red_knife_masc', 'red_cup_fem']",
                "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem']",
                "['blue_plate_masc', 'red_cup_fem', 'red_cup_fem']",
                "['blue_plate_masc', 'red_cup_fem', 'blue_cup_fem']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_plate_masc']",
                "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc']",
                "['blue_plate_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc', 'blue_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_knife_masc', 'blue_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_knife_masc', 'red_knife_masc', 'blue_knife_masc']",
                "['blue_plate_masc', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem']",
                "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'blue_cup_fem', 'blue_cup_fem', 'blue_cup_fem']",
                "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem']",
                "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'blue_cup_fem', 'red_cup_fem', 'red_cup_fem']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'blue_cup_fem']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'red_cup_fem']",
                "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_cup_fem', 'blue_cup_fem', 'red_cup_fem']"
  )
)

# Since each scenario has a target object of "blue_plate_masc" we can 
#   just add that for each row as the target object
graphDF <- graphDF %>%
  add_column(target = rep("blue_plate_masc", nrow(graphDF))) %>%
  add_column(trialNum = 1:nrow(graphDF))

#Apply the graphing function to each scenario (i.e. row) in the data frame
apply(graphDF, 1, graphScenario)
