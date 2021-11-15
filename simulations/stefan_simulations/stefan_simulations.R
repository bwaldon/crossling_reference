install.packages('varhandle')
library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)

library('varhandle')

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# RUN WEBPPL FROM A V8 JS ENGINE (FASTER WHEN YOU NEED TO RUN MANY, MANY CALLS TO WEBPPL)
source("../../_shared/V8wppl.R")

# SOURCE SOME HELPER SCRIPTS

# contains runModel function that interacts with V8 engine and runs the code
source("stefanSimulationHelpers.R")

# Source the engine
# Engine = basic RSA model in webppl code (all the speaker and listener functions)
engine <- read_file("../../_shared/engine.txt")

# load the functions that are required for the Serbo-Croatian semantics function to run
semanticHelperFunctions <- read_file("stefanModels/stefanSemanticHelperFunctions.txt")

# load in csv file with conditions to run
scenariosToRun <- read.csv("stefanModels/stefanScenarios.csv", as.is = TRUE)

# scenariosToRun <- lapply(scenariosToRun, as.character)

params_test <- c(7, .8, 0.99, 1, 0.99, 0.1, 0.1, 0)


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
runModelWrapper <- function(states, commandType, command, target, utterance, allUtterances, model, semantics) {
  ####### ADD THE BOOLEAN SEMANTICS TO THIS ONCE YOU IMPLEMENT PARAMETERS CORRECTLY
  
  runModel('V8', engine, model, semantics, semanticHelperFunctions, command, states, allUtterances,
          alpha = 1, sizeNoiseVal =1, colorNoiseVal = 1, 
           genderNoiseVal = 1, nounNoiseVal = 1,
           colorCost = 0, sizeCost = 0, nounCost = 0)
}

scenarios <- data.frame(scenariosToRun)
scenarios <- unfactor(test)

#runModelWrapper(test[1,1], test[1,2], test[1,3], test[1,4], test[1,5], test[1,6], test[1,7], test[1,8])

# Run the function on all the scenarios
scenarios <- scenarios %>%
  mutate(output = sapply(
  split(scenarios, 1:nrow(scenarios)),
  function(x) do.call(runModelWrapper, x)
))

#Get globalCont and globalBool scenarios
globalScenarios <- scenarios %>%
  filter(scenarios$commandType == "globalBool" | scenarios$commandType == "globalCont")

#Expand the output of the global variables
expandOutput <- function(output) {
  
  #tester <- globalScenarios[1,9]
  
  #split up the input
  outputformatted <- unlist(str_split(output, "\n"))
  
  # get rid of the string "Marginal:"
  outputformatted <- outputformatted[-1]

  # extract the numbers from the output
  outputNumbers <- as.numeric(unlist(regmatches(outputformatted,gregexpr("[[:digit:]]+\\.*[[:digit:]]*",outputformatted))))
  
  #extract the utterances
  extractUtterances <- function(oneUtterance) {
    oneUtterance <- gsub('[[:digit:]]+', '', oneUtterance)
    oneUtterance <- gsub('\" : .', '', oneUtterance)
    oneUtterance <- gsub('    \"', '', oneUtterance)
    return(oneUtterance)
  }
  
  ############
  # THIS ISN"T WORKING SO I"M JUST GOING TO LOOP
  #outputformatted <- lapply(outputformatted, extractUtterances())
  
  utteranceList <- c()
  for (i in 1:length(outputformatted)) {
    utteranceList <- append(utteranceList, extractUtterances(outputformatted[i]))
  }
  
  
  # combine them into a data frame
  # return data structure
  print("______")
  print(length(utteranceList))
  # print(utteranceList)
  print(length(outputNumbers))
  # print(outputNumbers)
  
  return(data.frame(utteranceList, outputNumbers))
}

#lapply expandOutput function to every row 
allGlobalUtterances <- apply(globalScenarios$output, 1, expandOutput())
  
bran_test <- globalScenarios[1:9]

bran_new <- bran_test %>%
  rowwise() %>%
  expandOutput()

#add new columns based on utterances and outputs
#merge that back in with the main dataframe




# run the model
runModelWrapper <- function(targetState, states, utterances, command, params) {
  #create command using the targetState input
  cmd <- paste(cmd_test[1], targetState, cmd_test[2], sep="\"")
  #run model
  runModel('V8', engine, modelAndSemantics, cmd, states, utterances, params[1], sizeNoiseVal = params[2], colorNoiseVal = params[3], genderNoiseVal = params[4], nounNoiseVal = params[5],
           colorCost = params[6], sizeCost = params[7], nounCost = params[8])
}

#1 = apply function to columns
apply(matrix1, 1, function1)
# I think 2 = apply function to rows?

#Run the model

#genderNoiseVal = 1, nounNoiseVal = 0.99,
model1 <- runModel('V8', engine, modelAndSemantics, cmd_main, states_main, utterances_main, 7, sizeNoiseVal = .8, colorNoiseVal = 0.99, genderNoiseVal = 1, nounNoiseVal = 0.99,
         colorCost = 0.1, sizeCost = 0.1, nounCost = 0)



#############
# Old stefan code to be deleted once everything works



# #method where I add things in by columns
# stefanDF <- data.frame(c("model1", "model1", "model1", "model1","model1","model1", "model1"))
# stefanDF <- stefanDF %>% mutate(c("big_blue_plate_masc", "big_blue_plate_masc","big_blue_plate_masc","big_blue_plate_masc","big_blue_plate_masc","big_blue_plate_masc", "big_blue_plate_masc"))
# stefanDF <- stefanDF %>% mutate(c(toJSON(states_test), toJSON(states_test),toJSON(states_test),toJSON(states_test),toJSON(states_test),toJSON(states_test),toJSON(states_test)))
# stefanDF <- stefanDF %>% mutate(c(toJSON(params_test), toJSON(params_test),toJSON(params_test),toJSON(params_test),toJSON(params_test),toJSON(params_test),toJSON(params_test)))
# stefanDF <- stefanDF %>% mutate(utterances_test)
# 
# # 
# 
# stefanDF <- data.frame(c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))

# Tibble Method to data frame
#Create first row model
stefanDF <- tibble(Name="model1", Target="big_blue_plate_masc", StateList=toJSON(states_test), Parameters=toJSON(params_test), Utterances=NA)
# stefanDF <- stefanDF %>% add_row(Name="model1", Target="big_blue_plate_masc", StateList=toJSON(states_test), Parameters=toJSON(params_test))
utterancesModel1 <- makeUtterances(states_test)
#Add utterances to Utterances column and otherwise just copy the row exactly as it is


#Janky way of doing this
stefanDF <- stefanDF %>% slice(rep(1:n(), length.out = length(utterancesModel1))) 
stefanDF <- stefanDF %>% add_column(utterancesModel1)

#add second scenario
stefanDF <- add_row(stefanDF, Name = "model2", Target = "blue_plate_masc", StateList=toJSON(states_two), Parameters=toJSON(params_test))
utterancesModel2 <- makeUtterances(states_two)
# Figure out way to duplicate the second model now

stefanDF <- rep(stefanDF[16,], length.out=length(utterancesModel1) + length(utterancesModel2))
stefanDF <- stefanDF %>% replace_na(utterancesModel2)

# # Try a method where I add rows
# stefanDF <- data.frame(matrix(ncol = 5, nrow = 0))
# colnames(stefanDF) <- c("Name", "Target", "StateList", "Utterances", "Parameters")
# stefanDF <- as_tibble(stefanDF)
# 
# 
# stefanDF <- add_row(stefanDF, list("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- rbind(stefanDF, list("model2", "blue_plate_masc", toJSON(states_two), toJSON(params_test)), stringsAsFactors = FALSE)
# 

# 
# 
# stefanDF <- rbind(stefanDF, c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- rbind(stefanDF, c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- rbind(stefanDF, c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- rbind(stefanDF, c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- rbind(stefanDF, c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- rbind(stefanDF, c("model1", "big_blue_plate_masc", toJSON(states_test), toJSON(params_test)))
# stefanDF <- mutate(stefanDF, utterances_test)
# stefanDF <- rbind(stefanDF, c("model2", "blue_plate_masc", toJSON(states_two), toJSON(utterances_two), toJSON(params_test)), stringsAsFactors = FALSE)
# 
# 
# stefanDF <- stefanDF %>%
#   expand(utterances_test)
# 


# toJSON --> converts vector to a string
# fromJSON --> converts vector from a string

#Can't get this to work
#Should print one line at a time
#I literally got it to work before idk why it's being weird.
modelPrint <- function(modelForPrint) {
  modelForPrint <- modelForPrint %>% strsplit("\n")
  print(modelForPrint)
  foo <- function(x) {
    str_remove(x, "   \"")
  }
  foo2 <- function(x) {
    str_remove(x, "\"")
  }
  modelForPrint <- lapply(modelForPrint, foo) %>% lapply(foo2)
  return(modelForPrint)
}

###########
# VALDF FOR SCIL PAPER

valDF <- data.frame("colorNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "sizeNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "alpha" = c(1,2.5,15,10,20,30))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha) %>%
  filter(alpha %in% c(5,10,15,20))

# VALDF FOR SCIL APP

valDF <- data.frame("colorNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "sizeNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "alpha" = c(1,2.5,5,10,15,20))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha)

# COLOR-SUFFICIENT SCENARIO 

## English


english_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_cs, utterances_eng_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

english_sizeOvermodification$language <- "English"

## Spanish-split

sp_split_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_split, states_cs, utterances_sp_split_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_split_sizeOvermodification$language <- "Spanish\n-split"

## Spanish-conj

sp_conj_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_conj, states_cs, utterances_sp_conj_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_conj_sizeOvermodification$language <- "Spanish\n-postnom.\n-conj."

## Spanish-postnom.

sp_postnom_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_postnom, states_cs, utterances_sp_postnom_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_postnom_sizeOvermodification$language <- "Spanish\n-postnom."

sizeOvermodification <- rbind(english_sizeOvermodification, rbind(sp_split_sizeOvermodification,rbind(sp_conj_sizeOvermodification,sp_postnom_sizeOvermodification)))

# SIZE-SUFFICIENT SCENARIO 

## English

english_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_ss, utterances_eng_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

english_colorOvermodification$language <- "English"

## Spanish-split

sp_split_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_split, states_ss, utterances_sp_split_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_split_colorOvermodification$language <- "Spanish\n-split"

## Spanish-conj

sp_conj_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_conj, states_ss, utterances_sp_conj_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_conj_colorOvermodification$language <- "Spanish\n-postnom.\n-conj."

## Spanish-postnom.

sp_postnom_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_postnom, states_ss, utterances_sp_postnom_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_postnom_colorOvermodification$language <- "Spanish\n-postnom."

colorOvermodification <- rbind(english_colorOvermodification, rbind(sp_split_colorOvermodification,rbind(sp_conj_colorOvermodification,sp_postnom_colorOvermodification)))

# PREDICTIONS PLOTS

plot <- function(probDF) {
  probDF$speakerProb <- as.numeric(probDF$speakerProb)
  p <- ggplot(probDF, aes(x=sizeNoise,y=colorNoise,color=speakerProb)) +
    geom_point(size=5,shape=15) +
    scale_x_continuous(limits=c(.45,1.0),breaks=seq(.475,1.0,.525),labels=c(0.5,1)) +
    scale_y_continuous(limits=c(.45,1.0),breaks=seq(.475,1.0,.525),labels=c(0.5,1)) +
    scale_colour_viridis(limits=c(0,1), name="Probability of\nutterance") +
    facet_grid(alpha~language) +
    xlab("Semantic value of size") +
    ylab("Semantic value of color") +
    theme(panel.spacing=unit(.25, "lines"),
          panel.border = element_rect(color = "black", fill = NA, size = 1),
          # axis.text.x = element_text(angle = 20, hjust=1),
          axis.text.y = element_text(hjust=0.5)) +
    xlab(element_blank()) +
    ylab(element_blank())
  return(p)
}

color_plot <- plot(colorOvermodification) + 
  theme(strip.text.y = element_blank(),
        legend.position = "none") +
  ggtitle("Redundant color modification")

size_plot <- plot(sizeOvermodification) +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "none") +
  ylab(element_blank()) +
  ggtitle("Redundant size modification")

legend <- plot_grid(get_legend(color_plot + theme(legend.position = "right")))

graphs <- arrangeGrob(grobs = list(color_plot, size_plot), ncol = 2, bottom = 'Semantic value of size', left = 'Semantic value of color', right = 'Alpha')

g <- arrangeGrob(graphs, legend, ncol = 2, widths = c(0.85, 0.15))

ggsave(g, filename = "scilpreds.pdf", height = 4, width = 8, units = "in", dpi = 1000)

### SCIL MODEL COMPARISON

base = 6
expand = 3

graph <- function(probArray) {
  
  toGraph <- data.frame(matrix(NA, nrow = 4, ncol = 3))
  colnames(toGraph) <- c("language", "behavior", "probability")
  toGraph$language <- c("English", "English", "Spanish-postnom.", "Spanish-postnom.")
  # toGraph$behavior <- c("Redundant color adjective (SS)", "Redundant size adjective (CS)", 
                        # "Redundant color adjective (SS)", "Redundant size adjective (CS)")
  # LABELS FOR POSTER
  toGraph$behavior <- c("Redundant color adjective", "Redundant size adjective", 
                        "Redundant color adjective", "Redundant size adjective") 
  toGraph$probability <- probArray
  
  p <- ggplot(toGraph, aes(x=language, y=probability, fill = behavior)) +
    theme_bw() +
    theme(text = element_text(size = base * expand / 2, face = "bold")) +
    ylab(element_blank()) +
    xlab(element_blank()) +
    geom_bar(stat="identity",position = "dodge") +
    # scale_fill_viridis(discrete = TRUE) +
    # color for the poster
    scale_fill_manual(values=c("#4287f5","#fff200")) +
    # for hypothetical graphs
    theme(legend.title = element_blank(), legend.position="none", # axis.text.x = element_blank(),
          axis.text.x = element_text(angle = 20, hjust=1),
    )
  
  return(p)
  
}

globalalpha <- 30 #30
incalpha <- 7
sizeCost <- 0.1
colorCost <- 0.1

cmd_eng_global <- 'Math.exp(globalUtteranceSpeaker("smallblue", model, params, semantics).score("START small blue pin STOP"))'
cmd_sp_postnom_global <- 'Math.exp(globalUtteranceSpeaker("smallblue", model, params, semantics).score("START pin blue small STOP"))'

cmd_eng_inc <- cmd_eng
cmd_sp_postnom_inc <- cmd_sp_postnom

## standard RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_ss, utterances_eng_ss, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))
  
v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_cs, utterances_eng_cs, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_ss, utterances_sp_postnom_ss, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global,states_cs, utterances_sp_postnom_cs, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

standardGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Standard RSA")

## continuous RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_ss, utterances_eng_ss, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_cs, utterances_eng_cs, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_ss, utterances_sp_postnom_ss, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_cs, utterances_sp_postnom_cs, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

crsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous RSA")

## inc RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_cs, utterances_eng_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_ss, utterances_sp_postnom_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

incGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Incremental RSA")

## continuous inc RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_cs, utterances_eng_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95,  
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_ss, utterances_sp_postnom_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95,  
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

cincrsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous\n-incremental RSA") 

graphs <- arrangeGrob(grobs = list(standardGraph,crsaGraph,incGraph,cincrsaGraph), ncol = 2, left = 'Probability of utterance')
legend <- plot_grid(get_legend(standardGraph + theme(legend.position = "bottom")))

g <- arrangeGrob(graphs, legend, ncol = 1, heights=c(0.9, 0.1))

ggsave(g, file = "modelcomparison_poster.pdf", height = 4, width = 4, units = "in", dpi = 1000)

cincrsaGraph + theme(legend.position = "bottom")

# TRANSITIONAL PROBABILITIES (FIGURE 3 OF PAPER)

# CI-RSA ENGLISH (SS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                    colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","small"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","big"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

# CI-RSA SPANISH (CS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","blue"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","red"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

# I-RSA ENGLISH (SS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","small"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","big"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

# I-RSA SPANISH (CS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","blue"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","red"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)
