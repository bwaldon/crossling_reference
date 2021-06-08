setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("../_shared/BDA_dataprep.R")
source("../_shared/wpplHelpers.R")
source("../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed <- read_csv("../../data/EnglishPilot/bda_data.csv") %>%
  rename(response = redBDAUtterance)

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

statesUtterances <- makeStatesUtterances(d_uncollapsed, "english")

# 'COLLAPSE' THE DATASET (GET PROPORTIONS OF COLOR, SIZE, COLORSIZE MENTION BY CONDITION)

d <- collapse_dataset(d_uncollapsed)

# 'df' IS INPUT TO THE BDA:

df <- merge(d, statesUtterances, by = "condition")

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
