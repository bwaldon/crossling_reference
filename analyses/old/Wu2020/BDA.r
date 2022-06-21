setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("helpers/wpplHelpers_wu.R")
source("helpers/vizhelpers_wu.R")

# LOAD IN WU & GIBSON'S DATA

number_eng <- read_csv("studies/WuGibson/data_number_eng_CODED_anon.csv")
color_eng <- read_csv("studies/WuGibson/data_color_eng_CODED_anon.csv")
number_sp <- read_csv("studies/WuGibson/data_number_spa_CODED_anon.csv")
color_sp <- read_csv("studies/WuGibson/data_color_spa_CODED_anon.csv")

number_uncollapsed <- rbind(number_eng,number_sp) %>%
  rename(language = lang, condition = figure) %>%
  mutate(language = recode(language, eng = "english", spa = "spanish"))
  
color_uncollapsed <- rbind(color_eng,color_sp) %>%
  rename(language = lang, condition = figure) %>%
  mutate(language = recode(language, eng = "english", spa = "spanish"))

# LOAD IN TRIAL KEY

key_color <- read_csv("studies/WuGibson/key_color.csv") %>%
  rename(condition = number)
key_number <- read_csv("studies/WuGibson/key_number.csv") %>%
  rename(condition = number)

# MAKE THE STATES (REFERENTS ASSOCIATED WITH EACH CONDITION TYPE)

getStates = function(condRow) {
  
  return(unlist(c(condRow$stimuli1,condRow$stimuli2,condRow$stimuli3,condRow$stimuli4)))
  
}

# MAKE THE UTTERANCES FOR EACH CONDITION 

getUtterances = function(states, language) {
  
  utterances = c()
  
  for(state in states) {
    
    words <- str_split(state, "-")[[1]]
    number <- words[1]
    color <- words[2]
    noun <- words[3]
    
    utterances = append(utterances,noun)
    
    if(language == "spanish") {
      complex_noun = paste(number, noun, color, sep = " ")
      utterances = append(utterances, complex_noun)
      
      noun_color = paste(noun, color, sep = " ")
      utterances = append(utterances, noun_color)
      
      number_noun = paste(number, noun, sep = " ")
      utterances = append(utterances, number_noun)
      
    } else if (language == "english") {
      complex_noun = paste(number, color, noun, sep = " ")
      utterances = append(utterances, complex_noun)
      
      color_noun = paste(color, noun, sep = " ")
      utterances = append(utterances, color_noun)
      
      number_noun = paste(number, noun, sep = " ")
      utterances = append(utterances, number_noun)
    }
    
  }
  
  # print(utterances)
  
  utterances <- lapply(unique(utterances), function(utterance) { 
    
    utterance <- paste("START", utterance, sep = " ")
    utterance <- paste(utterance, "STOP", sep = " ")
    
    return(utterance)
    
  })
  
  return(unlist(utterances))
  
}

makeStatesUtterances = function(key, language) {
  
  states <- c()
  utterances <- c()
  for (i in seq(nrow(key))) {
    states <- append(states, list(getStates(key[i,])))
    utterances <- append(utterances, list(getUtterances(getStates(key[i,]),language)))
  }
  
  key$states <- states
  key$utterances <- utterances
  
  return(key) %>% 
    mutate(language = language) %>%
          select(condition, states, utterances, target, language)
  
}

collapse_dataset <- function(d_uncollapsed) {
  d_uncollapsed %>% 
    group_by(condition,language) %>%
    mutate(n = n()) %>%
    mutate(observedMention = sum(use)/n) %>%
    select(condition, language, observedMention) %>%
    distinct(condition, .keep_all = TRUE)
}

# NUMBER

numberStatesUtterancesEnglish <- makeStatesUtterances(key_number,"english")

numberStatesUtterancesSpanish <- makeStatesUtterances(key_number,"spanish")

numberStatesUtterances <- rbind(numberStatesUtterancesEnglish, numberStatesUtterancesSpanish)

numberStatesUtterances$overmod_1 <- ""
numberStatesUtterances$overmod_2 <- ""

for(i in seq(nrow(numberStatesUtterances))) {
  
  language = numberStatesUtterances[i,]$language
  target_features <- str_split(numberStatesUtterances[i,]$target, "-")[[1]]
  if(language == "english") {
    numberStatesUtterances[i,]$overmod_1 <- sprintf("START %s %s %s STOP",
                                                    target_features[1],
                                                    target_features[2],
                                                    target_features[3])
    numberStatesUtterances[i,]$overmod_2 <- sprintf("START %s %s STOP",
                                                    target_features[1],
                                                    target_features[3])
    
  } else if (language == "spanish") {
    numberStatesUtterances[i,]$overmod_1 <- sprintf("START %s %s %s STOP",
                                                    target_features[1],
                                                    target_features[3],
                                                    target_features[2]
                                                    )
    numberStatesUtterances[i,]$overmod_2 <- sprintf("START %s %s STOP",
                                                    target_features[1],
                                                    target_features[3])
  }
}
  
numberCollapsed <- collapse_dataset(number_uncollapsed)
numberDF <- cbind(numberStatesUtterances, numberCollapsed) 
 
# COLOR

colorStatesUtterances <- rbind(makeStatesUtterances(key_color,"english"),
                                makeStatesUtterances(key_color,"spanish"))

colorStatesUtterances$overmod_1 <- ""
colorStatesUtterances$overmod_2 <- ""

for(i in seq(nrow(colorStatesUtterances))) {
  
  language = colorStatesUtterances[i,]$language
  target_features <- str_split(colorStatesUtterances[i,]$target, "-")[[1]]
  if(language == "english") {
    colorStatesUtterances[i,]$overmod_1 <- sprintf("START %s %s %s STOP",
                                                    target_features[1],
                                                    target_features[2],
                                                    target_features[3])
    colorStatesUtterances[i,]$overmod_2 <- sprintf("START %s %s STOP",
                                                    target_features[2],
                                                    target_features[3])
    
  } else if (language == "spanish") {
    colorStatesUtterances[i,]$overmod_1 <- sprintf("START %s %s %s STOP",
                                                    target_features[1],
                                                    target_features[3],
                                                    target_features[2]
    )
    colorStatesUtterances[i,]$overmod_2 <- sprintf("START %s %s STOP",
                                                    target_features[3],
                                                    target_features[2])
  }
}

colorCollapsed <- collapse_dataset(color_uncollapsed)
colorDF <- cbind(colorStatesUtterances,colorCollapsed)

# MAKE THE MODEL 

model <- paste(read_file("studies/WuGibson/modelAndSemantics.txt"),
               read_file("../_shared/engine.txt"), sep = "\n")

colorDF$kind <- "color"
numberDF$kind <- "number"

DF <- rbind(colorDF,numberDF)

# INFERENCE SCRIPTS

vanillaInferenceScript <- paste(model, read_file("inferenceCommands/WuGibson/vanilla.txt"),
                                sep = "\n")
continuousInferenceScript <- paste(model, read_file("inferenceCommands/WuGibson/continuous.txt"),
                                sep = "\n")
incrementalInferenceScript <- paste(model, read_file("inferenceCommands/WuGibson/incremental.txt"),
                                   sep = "\n")
incrementalContinuousInferenceScript <- paste(model, read_file("inferenceCommands/WuGibson/incrementalContinuous.txt"),
                                   sep = "\n")

# MODEL 1: VANILLA RSA

# POSTERIORS

# write_file(vanillaInferenceScript,"vis.txt")

vanillaPosteriors <- webppl(vanillaInferenceScript, data = DF, data_var = "df")

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/WuGibson/vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                             "vanilla")

vanillaPredictives <- webppl(vanillaPredictionScript, data = DF, data_var = "df")

graphPredictives(vanillaPredictives, DF)

ggsave("results/wuGibson/vanillaPredictives.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousPosteriors <- webppl(continuousInferenceScript, data = DF, data_var = "df")

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/WuGibson/continuousPosteriors_color.png")

# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript <- wrapPrediction(model, continuousEstimates,
                                                  "continuous")

continuousPredictives <- webppl(continuousPredictionScript, data = DF, data_var = "df")

graphPredictives(continuousPredictives, DF)

ggsave("results/wuGibson/continuousPredictives_color.png", width = 4, height = 3, units = "in")

# MODEL 3: INCREMENTAL RSA 

# POSTERIORS

incrementalPosteriors <- webppl(incrementalInferenceScript, data = colorDF, data_var = "df",
                                random_seed = 123)

graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

ggsave("results/WuGibson/incrementalPosteriors.png")

# PREDICTIVES

incrementalEstimates <- getEstimates(incrementalPosteriors) 

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                                     "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = DF, data_var = "df")

graphPredictives(incrementalPredictives, DF)

ggsave("results/wuGibson/incrementalPredictives_color.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = DF, data_var = "df")

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Continuous-incremental posteriors")

ggsave("results/WuGibson/incrementalContinuousPosteriors.png")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, incrementalContinuousEstimates,
                                                      "incremental")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = DF, data_var = "df")

graphPredictives(incrementalContinuousPredictives, DF)

ggsave("results/wuGibson/incrementalContinuousPredictives.png", width = 4, height = 3, units = "in")

save.image("results/Degenetal/results.RData")
