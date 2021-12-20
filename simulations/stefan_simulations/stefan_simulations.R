library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)
library('varhandle')

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
engine <- read_file("../../_shared/engine.txt")

# Load all the extra semantic functions that are required for the main Serbo-Croatian
#   semantics function to run, but that are not found in the csv file created by stefanAllScenarios.py
semanticHelperFunctions <- read_file("stefanModels/stefanSemanticHelperFunctions.txt")

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
scenariosToRun <- read.csv("stefanModels/stefanScenarioSeries1.csv", as.is = TRUE)

# Do to a bug in the python script, we have duplicates of boolean semantic rows
# therefore we only want to get the unique rows
scenariosToRun <- unique(scenariosToRun)

#For testing cost function
# scenariosToRun <- scenariosToRun %>%
#   filter(scenariosToRun$commandType == 'globalCont' & scenariosToRun$target == 'blue_cup_fem')

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

# Turn the contents of the csv file into a data frame
scenarios <- data.frame(scenariosToRun)


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


#######
# In case you've already run the above code, and just want to analyze the data, without rerunning
# the code, import the csv file that was written above with the following two lines of code
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
scenariosFinal <- read.csv("stefanTestSeries1/series1Formatted.csv", as.is = TRUE)

###############
# SCENARIO 1
# objects: ['blue_plate_masc', 'red_plate_masc', 'red_plate_masc']
# target: 'blue_plate_masc'
# alpha: 19, same for all models
# cost: {0, 0.1}, same for all words
# sizeNoise: 0.8
# colorNoise: 0.95
# nounNoise: 0.9
# genderNoise: {0.8, 1.0}
###############

###############
# SCENARIO 2
# objects: ["blue_plate_masc","red_knife_masc", "red_knife_masc"]
# target: 'blue_plate_masc'
# alpha: 19, same for all models
# cost: {0, 0.1}, same for all words
# sizeNoise: 0.8
# colorNoise: 0.95
# nounNoise: 0.9
# genderNoise: {0.8, 1.0}
###############


graphScenario <- function(targetInput, statesInput, scenarioNum) {
  
  # Get the correct Scenario
  scenario <- scenariosFinal %>%
    filter(target == targetInput & states == statesInput)
  
  # Scenario 1; all continous graphs; cost = 0
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
  

  # Scenario 1; Graphs by genderNoise and sizeCost
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
  
  
  # EXPORT THE SCENARIO 1 PLOTS
  
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


graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc']", 1)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc']", 2)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'blue_knife_masc']", 3)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'blue_cup_fem']", 4)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_cup_fem']", 5)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'blue_knife_masc', 'red_cup_fem']", 6)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'blue_cup_fem']", 7)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'red_cup_fem']", 8)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem']", 9)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_cup_fem', 'red_cup_fem']", 10)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_cup_fem', 'blue_cup_fem']", 11)

graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc']", 12)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc', 'blue_knife_masc', 'blue_knife_masc']", 13)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_knife_masc', 'red_knife_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc']", 14)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_knife_masc', 'red_knife_masc', 'red_knife_masc']", 15)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'blue_knife_masc', 'blue_knife_masc', 'blue_knife_masc']", 16)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_knife_masc', 'red_knife_masc', 'blue_knife_masc']", 17)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem']", 18)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem']", 19)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'blue_cup_fem', 'red_cup_fem', 'red_cup_fem']", 20)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_cup_fem', 'red_cup_fem', 'red_cup_fem']", 21)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'blue_cup_fem', 'blue_cup_fem', 'red_cup_fem']", 22)
graphScenario("blue_plate_masc", "['blue_plate_masc', 'red_plate_masc', 'red_plate_masc', 'red_cup_fem', 'blue_cup_fem', 'red_cup_fem']", 23)





###############
# SCENARIO 3
# objects: ["blue_plate_masc","red_knife_masc", "blue_knife_masc"]
# target: 'blue_plate_masc'
# alpha: 19, same for all models
# cost: {0, 0.1}, same for all words
# sizeNoise: 0.8
# colorNoise: 0.95
# nounNoise: 0.9
# genderNoise: {0.8, 1.0}
###############

# Get the correct Scenario
scenario2 <- scenariosFinal %>%
  filter(scenariosFinal$target == "blue_plate_masc" & scenariosFinal$states == "")

# Scenario 1; all continous graphs; cost = 0
graphScenario2Cont <-  scenario2 %>%
  filter(scenario2$commandType == "globalCont" |
           scenario2$commandType == "incCont")%>%
  group_by(commandType, genderNoise) %>%
  mutate(identifier = paste(commandType, ", cost: ", sizeCost, ", genderNoise: ", genderNoise, sep = "")) %>%
  ggplot(aes(x=utterance,y=output)) +
  geom_bar(stat="identity") +
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))

# Scenario 1; Graphs by genderNoise and sizeCost
graphScenario2Noise08 <- scenario2 %>%
  filter(scenario2$genderNoise == 0.8 |
           scenario2$commandType == "globalBool" |
           scenario2$commandType == "incBool") %>%
  mutate(identifier = paste("cost: ", sizeCost, ", ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
  ggplot(aes(x=utterance,y=output)) +
  geom_bar(stat="identity") +
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))

graphScenario2Noise1 <- scenario2 %>%
  filter(scenario2$genderNoise == 1.0 |
           scenario2$commandType == "globalBool" |
           scenario2$commandType == "incBool") %>%
  mutate(identifier = paste("cost: ", sizeCost, ", ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
  ggplot(aes(x=utterance,y=output)) +
  geom_bar(stat="identity") +
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))


# EXPORT THE SCENARIO 1 PLOTS

#Export the plots
jpeg(file="stefanTestSeries1/scenario2_ContModels.jpeg", width = 1500, height = 1000)
plot(graphScenario2Cont)
dev.off()

jpeg(file="stefanTestSeries1/scenario2_Noise08.jpeg", width = 1500, height = 1000)
plot(graphScenario2Noise)
dev.off()

jpeg(file="stefanTestSeries1/scenario2_Noise1.jpeg", width = 1500, height = 1000)
plot(graphScenario2Noise1)
dev.off()







# SENARIOS for Test Scenarios
# ###############
# # SCENARIO 1
# # objects: ['blue_plate_masc', 'red_plate_masc', 'blue_cup_fem']
# # target: 'blue_cup_fem'
# # alpha: 19, same for all models
# # cost: {0, 0.1}, same for all words
# # sizeNoise: 0.8
# # colorNoise: 0.95
# # nounNoise: 0.9
# # genderNoise: {0.7, 0.8, 0.9, 1.0}
# ###############
# 
# # Get the correct Scenario
# scenario1 <- scenariosFinal %>%
#   filter(scenariosFinal$target == "blue_cup_fem" & scenariosFinal$states == "['blue_plate_masc', 'red_plate_masc', 'blue_cup_fem']")
# 
# # Scenario 1; all continous graphs; cost = 0
# graphScenario1Cost0Cont <-  scenario1 %>%
#   filter(scenario1$sizeCost == 0 & (
#     scenario1$commandType == "globalCont" | 
#     scenario1$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 1; all continous graphs; cost = 0.1
# graphScenario1Cost01Cont <-  scenario1 %>%
#   filter(scenario1$sizeCost == 0.1 & (
#       scenario1$commandType == "globalCont" | 
#       scenario1$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 1; Graphs by genderNoise and sizeCost
# graphScenario1Cost0GenderNoise07 <- scenario1 %>%
#   filter(scenario1$genderNoise == 0.7 | 
#            scenario1$commandType == "globalBool" | 
#            scenario1$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario1Cost0GenderNoise08 <- scenario1 %>%
#   filter(scenario1$genderNoise == 0.8 | 
#            scenario1$commandType == "globalBool" | 
#            scenario1$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario1Cost0GenderNoise09 <- scenario1 %>%
#   filter(scenario1$genderNoise == 0.9 | 
#            scenario1$commandType == "globalBool" | 
#            scenario1$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario1Cost0GenderNoise1 <- scenario1 %>%
#   filter(scenario1$genderNoise == 1.0 | 
#            scenario1$commandType == "globalBool" | 
#            scenario1$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # EXPORT THE SCENARIO 1 PLOTS
# 
# #Export the plots
# jpeg(file="stefanTestScenarios/scenario1_ContModels_Cost0.jpeg", width = 1500, height = 1000)
# plot(graphScenario1Cost0Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario1_ContModels_Cost01.jpeg", width = 1500, height = 1000)
# plot(graphScenario1Cost01Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario1_ModelComparison_GenderNoise07.jpeg", width = 1500, height = 1000)
# plot(graphScenario1Cost0GenderNoise07)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario1_ModelComparison_GenderNoise08.jpeg", width = 1500, height = 1000)
# plot(graphScenario1Cost0GenderNoise08)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario1_ModelComparison_GenderNoise09.jpeg", width = 1500, height = 1000)
# plot(graphScenario1Cost0GenderNoise09)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario1_ModelComparison_GenderNoise1.jpeg", width = 1500, height = 1000)
# plot(graphScenario1Cost0GenderNoise1)
# dev.off()
# 
# 
# 
# ###############
# # SCENARIO 2
# # objects: ['big_blue_plate_masc', 'big_red_plate_masc', 'small_blue_plate_masc']
# # target: 'small_blue_plate_masc'
# # alpha: 19, same for all models
# # cost: {0, 0.1}, same for all words
# # sizeNoise: 0.8
# # colorNoise: 0.95
# # nounNoise: 0.9
# # genderNoise: {0.7, 0.8, 0.9, 1.0}
# ###############
# 
# # Get the correct Scenario
# scenario2 <- scenariosFinal %>%
#   filter(scenariosFinal$target == "small_blue_plate_masc" & scenariosFinal$states == "['big_blue_plate_masc', 'big_red_plate_masc', 'small_blue_plate_masc']")
# 
# # Scenario 2; all continous graphs; cost = 0
# graphScenario2Cost0Cont <-  scenario2 %>%
#   filter(scenario2$sizeCost == 0 & (
#     scenario2$commandType == "globalCont" | 
#       scenario2$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 2; all continous graphs; cost = 0.1
# graphScenario2Cost01Cont <-  scenario2 %>%
#   filter(scenario2$sizeCost == 0.1 & (
#     scenario2$commandType == "globalCont" | 
#       scenario2$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 2; Graphs by genderNoise and sizeCost
# graphScenario2Cost0GenderNoise07 <- scenario2 %>%
#   filter(scenario2$genderNoise == 0.7 | 
#            scenario2$commandType == "globalBool" | 
#            scenario2$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario2Cost0GenderNoise08 <- scenario2 %>%
#   filter(scenario2$genderNoise == 0.8 | 
#            scenario2$commandType == "globalBool" | 
#            scenario2$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario2Cost0GenderNoise09 <- scenario2 %>%
#   filter(scenario2$genderNoise == 0.9 | 
#            scenario2$commandType == "globalBool" | 
#            scenario2$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario2Cost0GenderNoise1 <- scenario2 %>%
#   filter(scenario2$genderNoise == 1.0 | 
#            scenario2$commandType == "globalBool" | 
#            scenario2$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # EXPORT THE SCENARIO 2 PLOTS
# 
# #Export the plots
# jpeg(file="stefanTestScenarios/scenario2_ContModels_Cost0.jpeg", width = 1500, height = 1000)
# plot(graphScenario2Cost0Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario2_ContModels_Cost01.jpeg", width = 1500, height = 1000)
# plot(graphScenario2Cost01Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario2_ModelComparison_GenderNoise07.jpeg", width = 1500, height = 1000)
# plot(graphScenario2Cost0GenderNoise07)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario2_ModelComparison_GenderNoise08.jpeg", width = 1500, height = 1000)
# plot(graphScenario2Cost0GenderNoise08)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario2_ModelComparison_GenderNoise09.jpeg", width = 1500, height = 1000)
# plot(graphScenario2Cost0GenderNoise09)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario2_ModelComparison_GenderNoise1.jpeg", width = 1500, height = 1000)
# plot(graphScenario2Cost0GenderNoise1)
# dev.off()
# 
# 
# 
# ###############
# # SCENARIO 3
# # objects: ["small_red_plate_masc", "big_red_plate_masc", "small_blue_plate_masc"]
# # target: 'small_blue_plate_masc'
# # alpha: 19, same for all models
# # cost: {0, 0.1}, same for all words
# # sizeNoise: 0.8
# # colorNoise: 0.95
# # nounNoise: 0.9
# # genderNoise: {0.7, 0.8, 0.9, 1.0}
# ###############
# 
# # Get the correct Scenario
# scenario3 <- scenariosFinal %>%
#   filter(scenariosFinal$target == "small_blue_plate_masc" & scenariosFinal$states == "['small_red_plate_masc', 'big_red_plate_masc', 'small_blue_plate_masc']")
# 
# # Scenario 3; all continous graphs; cost = 0
# graphScenario3Cost0Cont <-  scenario3 %>%
#   filter(scenario3$sizeCost == 0 & (
#     scenario3$commandType == "globalCont" | 
#       scenario3$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 3; all continous graphs; cost = 0.1
# graphScenario3Cost01Cont <-  scenario3 %>%
#   filter(scenario3$sizeCost == 0.1 & (
#     scenario3$commandType == "globalCont" | 
#       scenario3$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 3; Graphs by genderNoise and sizeCost
# graphScenario3Cost0GenderNoise07 <- scenario3 %>%
#   filter(scenario3$genderNoise == 0.7 | 
#            scenario3$commandType == "globalBool" | 
#            scenario3$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario3Cost0GenderNoise08 <- scenario3 %>%
#   filter(scenario3$genderNoise == 0.8 | 
#            scenario3$commandType == "globalBool" | 
#            scenario3$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario3Cost0GenderNoise09 <- scenario3 %>%
#   filter(scenario3$genderNoise == 0.9 | 
#            scenario3$commandType == "globalBool" | 
#            scenario3$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario3Cost0GenderNoise1 <- scenario3 %>%
#   filter(scenario3$genderNoise == 1.0 | 
#            scenario3$commandType == "globalBool" | 
#            scenario3$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # EXPORT THE SCENARIO 3 PLOTS
# 
# #Export the plots
# jpeg(file="stefanTestScenarios/scenario3_ContModels_Cost0.jpeg", width = 1500, height = 1000)
# plot(graphScenario3Cost0Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario3_ContModels_Cost01.jpeg", width = 1500, height = 1000)
# plot(graphScenario3Cost01Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario3_ModelComparison_GenderNoise07.jpeg", width = 1500, height = 1000)
# plot(graphScenario3Cost0GenderNoise07)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario3_ModelComparison_GenderNoise08.jpeg", width = 1500, height = 1000)
# plot(graphScenario3Cost0GenderNoise08)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario3_ModelComparison_GenderNoise09.jpeg", width = 1500, height = 1000)
# plot(graphScenario3Cost0GenderNoise09)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario3_ModelComparison_GenderNoise1.jpeg", width = 1500, height = 1000)
# plot(graphScenario3Cost0GenderNoise1)
# dev.off()
# 
# 
# ###############
# # SCENARIO 4
# # objects: ['blue_plate_masc', 'red_plate_masc', 'blue_cup_fem', 'red_cup_fem']
# # target: 'blue_cup_fem'
# # alpha: 19, same for all models
# # cost: {0, 0.1}, same for all words
# # sizeNoise: 0.8
# # colorNoise: 0.95
# # nounNoise: 0.9
# # genderNoise: {0.7, 0.8, 0.9, 1.0}
# ###############
# 
# # Get the correct Scenario
# scenario4 <- scenariosFinal %>%
#   filter(scenariosFinal$target == "blue_cup_fem" & scenariosFinal$states == "['blue_plate_masc', 'red_plate_masc', 'blue_cup_fem', 'red_cup_fem']")
# 
# # Scenario 4; all continous graphs; cost = 0
# graphScenario4Cost0Cont <-  scenario4 %>%
#   filter(scenario4$sizeCost == 0 & (
#     scenario4$commandType == "globalCont" | 
#       scenario4$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 4; all continous graphs; cost = 0.1
# graphScenario4Cost01Cont <-  scenario4 %>%
#   filter(scenario4$sizeCost == 0.1 & (
#     scenario4$commandType == "globalCont" | 
#       scenario4$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 4; Graphs by genderNoise and sizeCost
# graphScenario4Cost0GenderNoise07 <- scenario4 %>%
#   filter(scenario4$genderNoise == 0.7 | 
#            scenario4$commandType == "globalBool" | 
#            scenario4$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario4Cost0GenderNoise08 <- scenario4 %>%
#   filter(scenario4$genderNoise == 0.8 | 
#            scenario4$commandType == "globalBool" | 
#            scenario4$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario4Cost0GenderNoise09 <- scenario4 %>%
#   filter(scenario4$genderNoise == 0.9 | 
#            scenario4$commandType == "globalBool" | 
#            scenario4$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario4Cost0GenderNoise1 <- scenario4 %>%
#   filter(scenario4$genderNoise == 1.0 | 
#            scenario4$commandType == "globalBool" | 
#            scenario4$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # EXPORT THE SCENARIO 4 PLOTS
# 
# #Export the plots
# jpeg(file="stefanTestScenarios/scenario4_ContModels_Cost0.jpeg", width = 1500, height = 1000)
# plot(graphScenario4Cost0Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario4_ContModels_Cost01.jpeg", width = 1500, height = 1000)
# plot(graphScenario4Cost01Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario4_ModelComparison_GenderNoise07.jpeg", width = 1500, height = 1000)
# plot(graphScenario4Cost0GenderNoise07)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario4_ModelComparison_GenderNoise08.jpeg", width = 1500, height = 1000)
# plot(graphScenario4Cost0GenderNoise08)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario4_ModelComparison_GenderNoise09.jpeg", width = 1500, height = 1000)
# plot(graphScenario4Cost0GenderNoise09)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario4_ModelComparison_GenderNoise1.jpeg", width = 1500, height = 1000)
# plot(graphScenario4Cost0GenderNoise1)
# dev.off()
# 
# 
# 
# ###############
# # SCENARIO 5
# # objects: ['big_plate_masc', 'small_plate_masc', 'big_cup_fem', 'small_cup_fem']
# # target: 'big_cup_fem'
# # alpha: 19, same for all models
# # cost: {0, 0.1}, same for all words
# # sizeNoise: 0.8
# # colorNoise: 0.95
# # nounNoise: 0.9
# # genderNoise: {0.7, 0.8, 0.9, 1.0}
# ###############
# 
# # Get the correct Scenario
# scenario5 <- scenariosFinal %>%
#   filter(scenariosFinal$target == "big_cup_fem" & scenariosFinal$states == "['big_plate_masc', 'small_plate_masc', 'big_cup_fem', 'small_cup_fem']")
# 
# # Scenario 5; all continous graphs; cost = 0
# graphScenario5Cost0Cont <-  scenario5 %>%
#   filter(scenario5$sizeCost == 0 & (
#     scenario5$commandType == "globalCont" | 
#       scenario5$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 5; all continous graphs; cost = 0.1
# graphScenario5Cost01Cont <-  scenario5 %>%
#   filter(scenario5$sizeCost == 0.1 & (
#     scenario5$commandType == "globalCont" | 
#       scenario5$commandType == "incCont")) %>%
#   group_by(commandType, genderNoise) %>%
#   mutate(identifier = paste("commandType: ", commandType, ", genderNoise: ", genderNoise, ", cost: ", sizeCost, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # Scenario 5; Graphs by genderNoise and sizeCost
# graphScenario5Cost0GenderNoise07 <- scenario5 %>%
#   filter(scenario5$genderNoise == 0.7 | 
#            scenario5$commandType == "globalBool" | 
#            scenario5$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario5Cost0GenderNoise08 <- scenario5 %>%
#   filter(scenario5$genderNoise == 0.8 | 
#            scenario5$commandType == "globalBool" | 
#            scenario5$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario5Cost0GenderNoise09 <- scenario5 %>%
#   filter(scenario5$genderNoise == 0.9 | 
#            scenario5$commandType == "globalBool" | 
#            scenario5$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# graphScenario5Cost0GenderNoise1 <- scenario5 %>%
#   filter(scenario5$genderNoise == 1.0 | 
#            scenario5$commandType == "globalBool" | 
#            scenario5$commandType == "incBool") %>%
#   mutate(identifier = paste("cost: ", sizeCost, ", commandType: ", commandType, ", genderNoise: ", genderNoise, sep = "")) %>%
#   ggplot(aes(x=utterance,y=output)) + 
#   geom_bar(stat="identity") + 
#   facet_wrap(~identifier, ncol = 4) +
#   theme_bw() + 
#   theme(axis.text.x = element_text(angle = 90), text = element_text(size = 16))
# 
# 
# # EXPORT THE SCENARIO 5 PLOTS
# 
# #Export the plots
# jpeg(file="stefanTestScenarios/scenario5_ContModels_Cost0.jpeg", width = 1500, height = 1000)
# plot(graphScenario5Cost0Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario5_ContModels_Cost01.jpeg", width = 1500, height = 1000)
# plot(graphScenario5Cost01Cont)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario5_ModelComparison_GenderNoise07.jpeg", width = 1500, height = 1000)
# plot(graphScenario5Cost0GenderNoise07)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario5_ModelComparison_GenderNoise08.jpeg", width = 1500, height = 1000)
# plot(graphScenario5Cost0GenderNoise08)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario5_ModelComparison_GenderNoise09.jpeg", width = 1500, height = 1000)
# plot(graphScenario5Cost0GenderNoise09)
# dev.off()
# 
# jpeg(file="stefanTestScenarios/scenario5_ModelComparison_GenderNoise1.jpeg", width = 1500, height = 1000)
# plot(graphScenario5Cost0GenderNoise1)
# dev.off()
