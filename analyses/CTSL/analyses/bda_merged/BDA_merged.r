setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("../_shared/BDA_dataprep.R")
source("../../_shared/inferenceHelpers.R")
source("../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed_ctsl <- read_csv("../../data/ctsl_perTrial.csv")
d_uncollapsed_english <- read_csv("../../data/english_perTrial.csv")

d_uncollapsed_merged = rbind(d_uncollapsed_ctsl,d_uncollapsed_english)

# COLLAPSE DATA (STILL NECESSARY FOR VISUALIZATIONS)

d_collapsed_ctsl <- collapse_dataset(d_uncollapsed_ctsl)
d_collapsed_english <- collapse_dataset(d_uncollapsed_english)

d_collapsed_merged = collapse_dataset(d_uncollapsed_merged)

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

statesUtterances_ctsl <- makeStatesUtterances(d_uncollapsed_ctsl, "spanish")
statesUtterances_english <- makeStatesUtterances(d_uncollapsed_english, "english")

# MAKE INPUT DATA TO BDA: EACH DATUM INCLUDES RESPONSE, STATES, UTTERANCES

df_ctsl <- d_uncollapsed_ctsl %>%
  merge(statesUtterances_ctsl) %>%
  mutate(response = case_when(response == "color" ~ "START color STOP",
                              response == "size" ~ "START size STOP",
                              response == "size_color" ~ "START color size STOP")) %>%
  mutate(language="CTSL") %>%
  select(response, states, utterances, condition, language)


df_english <- d_uncollapsed_english %>%
  merge(statesUtterances_english) %>%
  mutate(response = case_when(response == "color" ~ "START color STOP",
                              response == "size" ~ "START size STOP",
                              response == "size_color" ~ "START size color STOP")) %>%
  mutate(language = "English") %>%
  select(response, states, utterances, condition, language)

df_merged = rbind(df_ctsl,df_english)

df = df_merged

# MAKE THE MODEL 

model <- makeModel("modelAndSemantics.txt")

# MODEL 1: VANILLA RSA

# POSTERIORS

vanillaInferenceScript <- wrapInference(model, "color_size", "vanilla", 5000, 10, 10000)

vanillaPosteriors <- webppl(vanillaInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/merged_vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript_ctsl <- wrapPrediction(model, vanillaEstimates,
                                             "START color size STOP", 
                                             "color_size",
                                             "vanilla")
df = df_ctsl

vanillaPredictives_ctsl <- webppl(vanillaPredictionScript_ctsl, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(vanillaPredictives_ctsl, d_collapsed_ctsl)

ggsave("results/merged_ctsl_vanillaPredictives.png", width = 4, height = 3, units = "in")

vanillaPredictionScript_english <- wrapPrediction(model, vanillaEstimates,
                                               "START size color STOP", 
                                               "color_size",
                                               "vanilla")
df = df_english

vanillaPredictives_english <- webppl(vanillaPredictionScript_english, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(vanillaPredictives_english, d_collapsed_english)

ggsave("results/merged_english_vanillaPredictives.png", width = 4, height = 3, units = "in")


# MODEL 2: CONTINUOUS RSA

# POSTERIORS

df = df_merged

continuousInferenceScript <- wrapInference(model, "color_size", "continuous", 5000, 10, 10000)

continuousPosteriors <- webppl(continuousInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/merged_continuousPosteriors.png")


# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript_ctsl <- wrapPrediction(model, continuousEstimates,
                                              "START color size STOP", 
                                              "color_size",
                                              "continuous")
df = df_ctsl

continuousPredictives_ctsl <- webppl(continuousPredictionScript_ctsl, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(continuousPredictives_ctsl, d_collapsed_ctsl) + ggtitle("Continuous predictives")

ggsave("results/merged_ctsl_continuousPredictives.png", width = 4, height = 3, units = "in")

continuousPredictionScript_english <- wrapPrediction(model, continuousEstimates,
                                                  "START size color STOP", 
                                                  "color_size",
                                                  "continuous")
df = df_english

continuousPredictives_english <- webppl(continuousPredictionScript_english, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(continuousPredictives_english, d_collapsed_english) + ggtitle("Continuous predictives")

ggsave("results/merged_english_continuousPredictives.png", width = 4, height = 3, units = "in")


# MODEL 3: INCREMENTAL RSA 

df = df_merged

incrementalInferenceScript <- wrapInference(model, "color_size", "incremental", 5000, 10, 10000)

incrementalPosteriors <- webppl(incrementalInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

ggsave("results/merged_incrementalPosteriors.png")

# PREDICTIVES

incrementalEstimates <- getEstimates(incrementalPosteriors)

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                              "START color size STOP", 
                                              "color_size",
                                              "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalPredictives, d_collapsed) + ggtitle("Incremental predictives")

ggsave("results/merged_incrementalPredictives.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <- wrapInference(model, "color_size", "incrementalContinuous", 5000, 10, 10000)

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("results/merged_incrementalContinuousPosteriors.png")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, 
                                                        incrementalContinuousEstimates,
                                                        "START color size STOP", 
                                                        "color_size",
                                                        "incrementalContinuous")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalContinuousPredictives, d_collapsed)

ggsave("results/merged_incrementalContinuousPredictives.png", width = 4, height = 3, units = "in")

save.image("results/merged_results.RData")

# BAYESIAN MODEL COMPARISON: INCREMENTAL VS. GLOBAL 

# # STEP 1: WRAP INFERENCE COMMAND AROUND CORE MODEL

incrementalVGlobalInferenceCommand <- read_file("incrementalVGlobalComparison/inferenceCommand.txt")

# # # (TODO [LEYLA]: UP THE SAMPLE/LAG/BURN/RATE)

incrementalVGlobalInferenceCommand <- gsub("TARGET_REFERENT", "color_size", incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("NUM_SAMPLES", 5000, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("LAG", 10, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("BURN_IN", 10000, incrementalVGlobalInferenceCommand, fixed = TRUE)
  
incrementalVGlobalInferenceScript <- paste(read_file(model), incrementalVGlobalInferenceCommand, sep = "\n")

# # STEP 2: RUN SCRIPT AND GRAPH POSTERIORS 

incrementalVGlobalPosteriors <- webppl(incrementalVGlobalInferenceScript, data = df, data_var = "df", random_seed = 3333)

graphPosteriors(incrementalVGlobalPosteriors %>% filter(!(Parameter == "incrementalOrGlobal")) %>% mutate(value = as.numeric(value))) + ggtitle("Model parameter posteriors")

ggsave("incrementalVGlobalComparison/modelPosteriors.png")

# # STEP 3: CALCULATE POSTERIOR PROBABILITY OF INCREMENTAL VS. GLOBAL

modelPosterior <- incrementalVGlobalPosteriors %>% filter(Parameter == "incrementalOrGlobal") %>%
  count(value) %>%
  group_by(value) %>%
  summarize(posteriorProb = n / sum(n))

View(modelPosterior)

save.image("results/merged_comparison.RData")
