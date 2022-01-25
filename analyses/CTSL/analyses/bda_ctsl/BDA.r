setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("../_shared/BDA_dataprep.R")
source("../../_shared/inferenceHelpers.R")
source("../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed <- read_csv("../../data/bda_data.csv")

# COLLAPSE DATA (STILL NECESSARY FOR VISUALIZATIONS)

d_collapsed <- collapse_dataset(d_uncollapsed)

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

statesUtterances <- makeStatesUtterances(d_uncollapsed, "spanish")

# MAKE INPUT DATA TO BDA: EACH DATUM INCLUDES RESPONSE, STATES, UTTERANCES

df <- d_uncollapsed %>%
  merge(statesUtterances) %>%
  mutate(response = case_when(response == "color" ~ "START color STOP",
                              response == "size" ~ "START size STOP",
                              response == "size_color" ~ "START color size STOP")) %>%
  select(response, states, utterances, condition)

# MAKE THE MODEL 

model <- makeModel("modelAndSemantics.txt")

# MODEL 1: VANILLA RSA

# POSTERIORS

vanillaInferenceScript <- wrapInference(model, "color_size", "vanilla", 20000, 10, 1000)

vanillaPosteriors <- webppl(vanillaInferenceScript, data = df, data_var = "df")

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/ctsl_vanillaPosteriors_4.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                             "START color size STOP", 
                                             "color_size",
                                             "vanilla")

vanillaPredictives <- webppl(vanillaPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(vanillaPredictives, d_collapsed)

ggsave("results/ctsl_vanillaPredictives_4.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousInferenceScript <- wrapInference(model, "color_size", "continuous", 20000, 10, 1000)

continuousPosteriors <- webppl(continuousInferenceScript, data = df, data_var = "df")

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/ctsl_continuousPosteriors_4.png")

# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript <- wrapPrediction(model, continuousEstimates,
                                              "START color size STOP", 
                                              "color_size",
                                              "continuous")

continuousPredictives <- webppl(continuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(continuousPredictives, d_collapsed) + ggtitle("Continuous predictives")

ggsave("results/ctsl_continuousPredictives_4.png", width = 4, height = 3, units = "in")

# MODEL 3: INCREMENTAL RSA 

incrementalInferenceScript <- wrapInference(model, "color_size", "incremental", 20000, 10, 1000)

incrementalPosteriors <- webppl(incrementalInferenceScript, data = df, data_var = "df")

graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

#View(incrementalPosteriors)

ggsave("results/ctsl_incrementalPosteriors_4.png")

# PREDICTIVES

incrementalEstimates <- getEstimates(incrementalPosteriors)

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                              "START color size STOP", 
                                              "color_size",
                                              "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalPredictives, d_collapsed) + ggtitle("Incremental predictives")

ggsave("results/ctsl_incrementalPredictives_4.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <- wrapInference(model, "color_size", "incrementalContinuous", 20000, 10, 1000)

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = df, data_var = "df")

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("results/ctsl_incrementalContinuousPosteriors_4.png")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, 
                                                        incrementalContinuousEstimates,
                                                        "START color size STOP", 
                                                        "color_size",
                                                        "incrementalContinuous")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalContinuousPredictives, d_collapsed)

ggsave("results/ctsl_incrementalContinuousPredictives_4.png", width = 4, height = 3, units = "in")

save.image("results/ctsl_results_4.RData")

# BAYESIAN MODEL COMPARISON: INCREMENTAL VS. GLOBAL 

# # STEP 1: WRAP INFERENCE COMMAND AROUND CORE MODEL

incrementalVGlobalInferenceCommand <- read_file("incrementalVGlobalComparison/inferenceCommand.txt")

# # # (TODO [LEYLA]: UP THE SAMPLE/LAG/BURN/RATE)

incrementalVGlobalInferenceCommand <- gsub("TARGET_REFERENT", "color_size", incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("NUM_SAMPLES", 1000, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("LAG", 10, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("BURN_IN", 100, incrementalVGlobalInferenceCommand, fixed = TRUE)
  
incrementalVGlobalInferenceScript <- paste(read_file(model), incrementalVGlobalInferenceCommand, sep = "\n")

# # STEP 2: RUN SCRIPT AND GRAPH POSTERIORS 

incrementalVGlobalPosteriors <- webppl(incrementalVGlobalInferenceScript, data = df, data_var = "df")

graphPosteriors(incrementalVGlobalPosteriors %>% filter(!(Parameter == "incrementalOrGlobal"))) + ggtitle("Model parameter posteriors")

ggsave("incrementalVGlobalComparison/modelPosteriors_4.png")

# # STEP 3: CALCULATE POSTERIOR PROBABILITY OF INCREMENTAL VS. GLOBAL

modelPosterior <- incrementalVGlobalPosteriors %>% filter(Parameter == "incrementalOrGlobal") %>%
  count(value) %>%
  group_by(value) %>%
  summarize(posteriorProb = n / sum(n))
