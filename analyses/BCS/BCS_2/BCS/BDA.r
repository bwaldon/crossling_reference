setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("../../_shared/BDA_dataprep.R")
source("../../../_shared/inferenceHelpers.R")
source("../../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed <- read_csv("../../../data/BCS/BCSMain/bda_data.csv") %>%
  rename(response = redBDAUtterance)

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

# Replication of makeStatesUtterances() function, but for BCS

scene1_utterances <- c("START color_gender STOP", "START otherColor_gender STOP", 
                       "START object_gender STOP", "START otherObject_gender STOP",
                       "START color_gender object_gender STOP", "START otherColor_gender object_gender STOP", 
                       "START color_gender otherObject_gender STOP")

scene2_utterances <- c("START color_gender STOP", "START otherColor_gender STOP", 
                       "START object_gender STOP", "START otherObject_gender STOP",
                       "START color_gender object_gender STOP", "START color_gender otherObject_gender STOP", 
                       "START otherColor_gender otherObject_gender STOP")

scene3_utterances <- c("START color_gender STOP", "START color_otherGender STOP", "START otherColor_otherGender STOP",
                       "START object_gender STOP", "START otherObject_otherGender STOP",
                       "START color_gender object_gender STOP", "START color_otherGender otherObject_otherGender STOP", 
                       "START otherColor_otherGender otherObject_otherGender STOP")

scene4_utterances <- c("START color_gender STOP", "START otherColor_gender STOP", "START otherColor_otherGender STOP",
                       "START object_gender STOP", "START otherObject_otherGender STOP",
                       "START color_gender object_gender STOP", "START otherColor_gender object_gender STOP",
                       "START otherColor_otherGender otherObject_otherGender STOP")

scene1_states <- d_uncollapsed %>% 
  filter(condition == "scene1")
scene1_states <- scene1_states$response

scene2_states <- d_uncollapsed %>% 
  filter(condition == "scene2")
scene2_states <- scene2_states$response

scene3_states <- d_uncollapsed %>% 
  filter(condition == "scene3")
scene3_states <- scene3_states$response

scene4_states <- d_uncollapsed %>% 
  filter(condition == "scene4")
scene4_states <- scene4_states$response


statesUtterances <- tibble(
  condition = c("scene1", "scene2", "scene3", "scene4"),
  states = NA,
  utterances = NA
)

statesUtterances[1, "states"][[1]] <- list(scene1_states)
statesUtterances[2, "states"][[1]] <- list(scene2_states)
statesUtterances[3, "states"][[1]] <- list(scene3_states)
statesUtterances[4, "states"][[1]] <- list(scene4_states)

statesUtterances[1, "utterances"][[1]] <- list(scene1_utterances)
statesUtterances[2, "utterances"][[1]] <- list(scene2_utterances)
statesUtterances[3, "utterances"][[1]] <- list(scene3_utterances)
statesUtterances[4, "utterances"][[1]] <- list(scene4_utterances)

# 'COLLAPSE' THE DATASET (GET PROPORTIONS OF COLOR, SIZE, COLORSIZE MENTION BY CONDITION)

d_count <- d_uncollapsed %>%
  group_by(condition, response) %>%
  count()

d_total <- d_uncollapsed %>%
  group_by(condition) %>%
  count()

d <- merge(d_count, d_total, by = c("condition")) %>%
  mutate(percent = n.x/n.y) %>%
  select(-n.x, -n.y) %>%
  pivot_wider(names_from = response,
              values_from = percent) %>%
  replace(is.na(.), 0)

# 'df' IS INPUT TO THE BDA:

df <- merge(d, statesUtterances, by = "condition")


##### STOPPED HERE

# MAKE THE MODEL 

model <- makeModel("modelAndSemantics.txt")

# MODEL 1: VANILLA RSA

# POSTERIORS

vanillaInferenceScript <- wrapInference(model, "START size color STOP", 
                                           "color_size",
                                           "vanilla")

vanillaPosteriors <- webppl(vanillaInferenceScript, data = df, data_var = "df")

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                             "START size color STOP", 
                                             "color_size",
                                             "vanilla")

vanillaPredictives <- webppl(vanillaPredictionScript, data = df, data_var = "df")

graphPredictives(vanillaPredictives, df)

ggsave("results/vanillaPredictives.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousInferenceScript <- wrapInference(model, "START size color STOP", 
                                            "color_size",
                                            "continuous")

continuousPosteriors <- webppl(continuousInferenceScript, data = df, data_var = "df")

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/continuousPosteriors.png")

# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript <- wrapPrediction(model, continuousEstimates,
                                              "START size color STOP", 
                                              "color_size",
                                              "continuous")

continuousPredictives <- webppl(continuousPredictionScript, data = df, data_var = "df")

graphPredictives(continuousPredictives, df) + ggtitle("Continuous predictives")

ggsave("results/continuousPredictives.png", width = 4, height = 3, units = "in")

# MODEL 3: INCREMENTAL RSA 

incrementalInferenceScript <- wrapInference(model, "START size color STOP", 
                                                      "color_size",
                                                      "incremental")

incrementalPosteriors <- webppl(incrementalInferenceScript, data = df, data_var = "df")


graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

ggsave("results/incrementalPosteriors.png")

# PREDICTIVES

summarize <- summarise

incrementalEstimates <- getEstimates(incrementalPosteriors) 

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                                        "START size color STOP", 
                                                        "color_size",
                                                        "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = df, data_var = "df")

graphPredictives(incrementalPredictives, df) + ggtitle("Incremental predictives")

ggsave("results/incrementalPredictives.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <- wrapInference(model, 
                                                      "START size color STOP", 
                                                      "color_size",
                                                      "incrementalContinuous")

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = df, data_var = "df")

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("results/incrementalContinuousPosteriors.png")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, 
                                                        incrementalContinuousEstimates,
                                                        "START size color STOP", 
                                                        "color_size",
                                                        "incrementalContinuous")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = df, data_var = "df")

graphPredictives(incrementalContinuousPredictives, df)

ggsave("results/incrementalContinuousPredictives.png", width = 4, height = 3, units = "in")

save.image("results/results.RData")
