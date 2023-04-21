setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

# INCREASE NODE MEMORY SIZE (FOR WEBPPL)
print(Sys.setenv(NODE_OPTIONS = "--max-old-space-size=8192"))

# # ... CONFIRM NODE OPTIONS WERE SET 
Sys.getenv("NODE_OPTIONS")

source("../../../../_shared/BDA_dataprep_nouninfo.R")
source("../../../../../_shared/inferenceHelpers.R")
source("../../../../_shared/BDA_vizhelpers.R")
source("../../../../_shared/BDA_vizhelpers_withNoun.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed_fr <- read_csv("../../../../../data/FRENCH/nounInformative/main/bda_data.csv") %>%
  rename(response = redBDAUtterance) %>% filter(!grepl("filler",condition))
d_uncollapsed_eng <- read_csv("../../../../../data/ENGLISH2022_summer/nounInformative/main/bda_data.csv") %>%
  rename(response = redBDAUtterance) %>% filter(!grepl("filler",condition))

editResponse = function(df,lang) {
  if (lang == "french"){
  df <- df %>% mutate(newResponse = case_when(
    response == "size_color" ~ "START sameSize sameType sameColor STOP",
   response == "size" ~ "START sameSize sameType STOP",
  response == "color" ~ "START sameType sameColor STOP",
  TRUE ~ "OTHER"
  )) }
  if (lang == "english"){
    df <- df %>% mutate(newResponse = case_when(
      response == "size_color" ~ "START sameSize sameColor sameType STOP",
      response == "size" ~ "START sameSize sameType STOP",
      response == "color" ~ "START sameColor sameType STOP",
      TRUE ~ "OTHER"
    )) }
  df <- df %>%
    rename(oldResponse = response)  %>%
    rename(response = newResponse)
  return(df)
}

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

#for the current version, noun omission is not included as a possible utterance for French
statesUtterances_fr <- makeStatesUtterances(d_uncollapsed_fr, "french")
statesUtterances_eng <- makeStatesUtterances(d_uncollapsed_eng, "english")

# 'COLLAPSE' THE DATASET (GET PROPORTIONS OF COLOR, SIZE, COLORSIZE MENTION BY CONDITION)

d_fr <- collapse_dataset(d_uncollapsed_fr)
d_eng <-collapse_dataset(d_uncollapsed_eng)
#what would combined dataset look like?

# 'df' IS INPUT TO THE BDA:

fr_input <- merge(d_uncollapsed_fr, statesUtterances_fr, by = "condition")
eng_input <- merge(d_uncollapsed_eng, statesUtterances_eng, by = "condition")

fr_input <- editResponse(fr_input,"french")
eng_input <- editResponse(eng_input, "english")

combined_input <- rbind(fr_input,eng_input)
#todo: gender marker = different trial types
#todo: no noun omission
#todo: lag and burn --> max acceptance ratio

# MAKE THE MODEL 

model <- makeModel("modelAndSemantics.txt")


# MODEL 1: VANILLA RSA

# POSTERIORS

vanillaInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                        "vanilla", 2500, 0, 2500)

write.table(vanillaInferenceScript, file = "vanillalook.txt", sep = "")

# # ESTIMATE USING RWEBPPL:

vanillaPosteriors_fr <- webppl(vanillaInferenceScript, data = fr_input, data_var = "df",
                               random_seed = 3333)
saveRDS(vanillaPosteriors_fr, "results/vanilla/posteriors_fr.RDS")
vanillaPosteriors_eng <- webppl(vanillaInferenceScript, data = eng_input, data_var = "df",
                                random_seed = 3333)
saveRDS(vanillaPosteriors_eng, "results/vanilla/posteriors_eng.RDS")
vanillaPosteriors_both <- webppl(vanillaInferenceScript, data = combined_input, data_var = "df",
                                 random_seed = 3333)
saveRDS(vanillaPosteriors_both, "results/vanilla/posteriors_both.RDS")

# # LOAD IN FROM SAVED:

vanillaPosteriors_fr <- readRDS("results/vanilla/posteriors_fr.RDS")
vanillaPosteriors_eng <- readRDS("results/vanilla/posteriors_eng.RDS")
vanillaPosteriors_both <- readRDS("results/vanilla/posteriors_both.RDS")

graphAlpha(vanillaPosteriors_fr) + ggtitle("Vanilla alpha posterior (French)")
ggsave("results/vanilla/alpha_fr.png")
graphCostPosteriors_withNoun(vanillaPosteriors_fr) + ggtitle("Vanilla cost posteriors (French)")
ggsave("results/vanilla/cost_fr.png")
graphNoisePosteriors_withNoun(vanillaPosteriors_fr) + ggtitle("Vanilla noise posteriors (French)")
ggsave("results/vanilla/noise_fr.png")

graphAlpha(vanillaPosteriors_eng) + ggtitle("Vanilla alpha posterior (English)")
ggsave("results/vanilla/alpha_eng.png")
graphCostPosteriors_withNoun(vanillaPosteriors_eng) + ggtitle("Vanilla cost posteriors (English)")
ggsave("results/vanilla/cost_eng.png")
graphNoisePosteriors_withNoun(vanillaPosteriors_eng) + ggtitle("Vanilla noise posteriors (English)")
ggsave("results/vanilla/noise_eng.png")

graphAlpha(vanillaPosteriors_both) + ggtitle("Vanilla alpha posterior (English+French)")
ggsave("results/vanilla/alpha_both.png")
graphCostPosteriors_withNoun(vanillaPosteriors_both) + ggtitle("Vanilla cost posteriors (English+French)")
ggsave("results/vanilla/cost_both.png")
graphNoisePosteriors_withNoun(vanillaPosteriors_both) + ggtitle("Vanilla noise posteriors (English+French)")
ggsave("results/vanilla/noise_both.png")

# RUN FORWARD TO GET PREDICTIONS FOR FRENCH DATA

vanillaEstimates_fr <- getEstimates(vanillaPosteriors_fr) 
vanillaPredictionScript_fr <- wrapPrediction(model, vanillaEstimates_fr,
                                          overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                          colorOnlyUtterance = "START sameType sameColor STOP",
                                          sizeOnlyUtterance = "START sameSize sameType STOP",
                                          "sameColor_sameSize_sameType",
                                          "vanilla")

write.table(vanillaPredictionScript_fr, file = "predlook.txt", sep = "")
vanillaPredictives_fr <- webppl(vanillaPredictionScript_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(vanillaPredictives_fr, d_fr)
ggsave("results/vanilla/predictives_french.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH DATA

vanillaEstimates_eng <- getEstimates(vanillaPosteriors_eng) 
vanillaPredictionScript_eng <- wrapPrediction(model, vanillaEstimates_eng,
                                             overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                             colorOnlyUtterance = "START sameColor sameType STOP",
                                             sizeOnlyUtterance = "START sameSize sameType STOP",
                                             "sameColor_sameSize_sameType",
                                             "vanilla")

write.table(vanillaPredictionScript_eng, file = "predlook.txt", sep = "")
vanillaPredictives_eng <- webppl(vanillaPredictionScript_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(vanillaPredictives_eng, d_eng)
ggsave("results/vanilla/predictives_english.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH AND FRENCH DATA, 
# MODEL PARAMETERS ESTIMATED FROM BOTH LANGUAGES

vanillaEstimates_both <- getEstimates(vanillaPosteriors_both) 
vanillaPredictionScript_both_fr <- wrapPrediction(model, vanillaEstimates_both,
                                             overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                             colorOnlyUtterance = "START sameType sameColor STOP",
                                             sizeOnlyUtterance = "START sameSize sameType STOP",
                                             "sameColor_sameSize_sameType",
                                             "vanilla")
write.table(vanillaPredictionScript_both_fr, file = "predlook.txt", sep = "")
vanillaPredictives_both_fr <- webppl(vanillaPredictionScript_both_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(vanillaPredictives_both_fr, d_fr)
ggsave("results/vanilla/predictives_both_fr.png", width = 4, height = 3, units = "in")

vanillaPredictionScript_both_eng <- wrapPrediction(model, vanillaEstimates_both,
                                              overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                              colorOnlyUtterance = "START sameColor sameType STOP",
                                              sizeOnlyUtterance = "START sameSize sameType STOP",
                                              "sameColor_sameSize_sameType",
                                              "vanilla")
write.table(vanillaPredictionScript_both_eng, file = "predlook.txt", sep = "")
vanillaPredictives_both_eng <- webppl(vanillaPredictionScript_both_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(vanillaPredictives_both_eng, d_eng)
ggsave("results/vanilla/predictives_both_eng.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                        "continuous", 2500, 0, 2500)

write.table(continuousInferenceScript, file = "continuouslook.txt", sep = "")

# # ESTIMATE USING RWEBPPL:

continuousPosteriors_fr <- webppl(continuousInferenceScript, data = fr_input, data_var = "df",
                               random_seed = 3333)
saveRDS(continuousPosteriors_fr, "results/continuous/posteriors_fr.RDS")
continuousPosteriors_eng <- webppl(continuousInferenceScript, data = eng_input, data_var = "df",
                                random_seed = 3333)
saveRDS(continuousPosteriors_eng, "results/continuous/posteriors_eng.RDS")
continuousPosteriors_both <- webppl(continuousInferenceScript, data = combined_input, data_var = "df",
                                 random_seed = 3333)
saveRDS(continuousPosteriors_both, "results/continuous/posteriors_both.RDS")

# # LOAD IN FROM SAVED:

continuousPosteriors_fr <- readRDS("results/continuous/posteriors_fr.RDS")
continuousPosteriors_eng <- readRDS("results/continuous/posteriors_eng.RDS")
continuousPosteriors_both <- readRDS("results/continuous/posteriors_both.RDS")

graphAlpha(continuousPosteriors_fr) + ggtitle("Continuous alpha posterior (French)")
ggsave("results/continuous/alpha_fr.png")
graphCostPosteriors_withNoun(continuousPosteriors_fr) + ggtitle("Continuous cost posteriors (French)")
ggsave("results/continuous/cost_fr.png")
graphNoisePosteriors_withNoun(continuousPosteriors_fr) + ggtitle("Continuous noise posteriors (French)")
ggsave("results/continuous/noise_fr.png")

graphAlpha(continuousPosteriors_eng) + ggtitle("Continuous alpha posterior (English)")
ggsave("results/continuous/alpha_eng.png")
graphCostPosteriors_withNoun(continuousPosteriors_eng) + ggtitle("Continuous cost posteriors (English)")
ggsave("results/continuous/cost_eng.png")
graphNoisePosteriors_withNoun(continuousPosteriors_eng) + ggtitle("Continuous noise posteriors (English)")
ggsave("results/continuous/noise_eng.png")

graphAlpha(continuousPosteriors_both) + ggtitle("Continuous alpha posterior (English+French)")
ggsave("results/continuous/alpha_both.png")
graphCostPosteriors_withNoun(continuousPosteriors_both) + ggtitle("Continuous cost posteriors (English+French)")
ggsave("results/continuous/cost_both.png")
graphNoisePosteriors_withNoun(continuousPosteriors_both) + ggtitle("Continuous noise posteriors (English+French)")
ggsave("results/continuous/noise_both.png")

# RUN FORWARD TO GET PREDICTIONS FOR FRENCH DATA

continuousEstimates_fr <- getEstimates(continuousPosteriors_fr) 
continuousPredictionScript_fr <- wrapPrediction(model, continuousEstimates_fr,
                                             overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                             colorOnlyUtterance = "START sameType sameColor STOP",
                                             sizeOnlyUtterance = "START sameSize sameType STOP",
                                             "sameColor_sameSize_sameType",
                                             "continuous")

write.table(continuousPredictionScript_fr, file = "predlook.txt", sep = "")
continuousPredictives_fr <- webppl(continuousPredictionScript_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(continuousPredictives_fr, d_fr)
ggsave("results/continuous/predictives_french.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH DATA

continuousEstimates_eng <- getEstimates(continuousPosteriors_eng) 
continuousPredictionScript_eng <- wrapPrediction(model, continuousEstimates_eng,
                                              overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                              colorOnlyUtterance = "START sameColor sameType STOP",
                                              sizeOnlyUtterance = "START sameSize sameType STOP",
                                              "sameColor_sameSize_sameType",
                                              "continuous")

write.table(continuousPredictionScript_eng, file = "predlook.txt", sep = "")
continuousPredictives_eng <- webppl(continuousPredictionScript_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(continuousPredictives_eng, d_eng)
ggsave("results/continuous/predictives_english.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH AND FRENCH DATA, 
# MODEL PARAMETERS ESTIMATED FROM BOTH LANGUAGES

continuousEstimates_both <- getEstimates(continuousPosteriors_both) 
continuousPredictionScript_both_fr <- wrapPrediction(model, continuousEstimates_both,
                                                  overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                                  colorOnlyUtterance = "START sameType sameColor STOP",
                                                  sizeOnlyUtterance = "START sameSize sameType STOP",
                                                  "sameColor_sameSize_sameType",
                                                  "continuous")
write.table(continuousPredictionScript_both_fr, file = "predlook.txt", sep = "")
continuousPredictives_both_fr <- webppl(continuousPredictionScript_both_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(continuousPredictives_both_fr, d_fr)
ggsave("results/continuous/predictives_both_fr.png", width = 4, height = 3, units = "in")

continuousPredictionScript_both_eng <- wrapPrediction(model, continuousEstimates_both,
                                                   overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                                   colorOnlyUtterance = "START sameColor sameType STOP",
                                                   sizeOnlyUtterance = "START sameSize sameType STOP",
                                                   "sameColor_sameSize_sameType",
                                                   "continuous")
write.table(continuousPredictionScript_both_eng, file = "predlook.txt", sep = "")
continuousPredictives_both_eng <- webppl(continuousPredictionScript_both_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(continuousPredictives_both_eng, d_eng)
ggsave("results/continuous/predictives_both_eng.png", width = 4, height = 3, units = "in")

# MODEL 3: INCREMENTAL RSA

# POSTERIORS

incrementalInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                        "incremental", 2500, 0, 7500)

write.table(incrementalInferenceScript, file = "incrementallook.txt", sep = "")

# # ESTIMATE USING RWEBPPL:

incrementalPosteriors_fr <- webppl(incrementalInferenceScript, data = fr_input, data_var = "df",
                               random_seed = 3333)
saveRDS(incrementalPosteriors_fr, "results/incremental/posteriors_fr.RDS")
incrementalPosteriors_eng <- webppl(incrementalInferenceScript, data = eng_input, data_var = "df",
                                random_seed = 3333)
saveRDS(incrementalPosteriors_eng, "results/incremental/posteriors_eng.RDS")
incrementalPosteriors_both <- webppl(incrementalInferenceScript, data = combined_input, data_var = "df",
                                 random_seed = 3333)
saveRDS(incrementalPosteriors_both, "results/incremental/posteriors_both.RDS")

# # LOAD IN FROM SAVED:

incrementalPosteriors_fr <- readRDS("results/incremental/posteriors_fr.RDS")
incrementalPosteriors_eng <- readRDS("results/incremental/posteriors_eng.RDS")
incrementalPosteriors_both <- readRDS("results/incremental/posteriors_both.RDS")

graphAlpha(incrementalPosteriors_fr) + ggtitle("Incremental alpha posterior (French)")
ggsave("results/incremental/alpha_fr.png")
graphCostPosteriors_withNoun(incrementalPosteriors_fr) + ggtitle("Incremental cost posteriors (French)")
ggsave("results/incremental/cost_fr.png")
graphNoisePosteriors_withNoun(incrementalPosteriors_fr) + ggtitle("Incremental noise posteriors (French)")
ggsave("results/incremental/noise_fr.png")

graphAlpha(incrementalPosteriors_eng) + ggtitle("Incremental alpha posterior (English)")
ggsave("results/incremental/alpha_eng.png")
graphCostPosteriors_withNoun(incrementalPosteriors_eng) + ggtitle("Incremental cost posteriors (English)")
ggsave("results/incremental/cost_eng.png")
graphNoisePosteriors_withNoun(incrementalPosteriors_eng) + ggtitle("Incremental noise posteriors (English)")
ggsave("results/incremental/noise_eng.png")

graphAlpha(incrementalPosteriors_both) + ggtitle("Incremental alpha posterior (English+French)")
ggsave("results/incremental/alpha_both.png")
graphCostPosteriors_withNoun(incrementalPosteriors_both) + ggtitle("Incremental cost posteriors (English+French)")
ggsave("results/incremental/cost_both.png")
graphNoisePosteriors_withNoun(incrementalPosteriors_both) + ggtitle("Incremental noise posteriors (English+French)")
ggsave("results/incremental/noise_both.png")

# RUN FORWARD TO GET PREDICTIONS FOR FRENCH DATA

incrementalEstimates_fr <- getEstimates(incrementalPosteriors_fr) 
incrementalPredictionScript_fr <- wrapPrediction(model, incrementalEstimates_fr,
                                             overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                             colorOnlyUtterance = "START sameType sameColor STOP",
                                             sizeOnlyUtterance = "START sameSize sameType STOP",
                                             "sameColor_sameSize_sameType",
                                             "incremental")

write.table(incrementalPredictionScript_fr, file = "predlook.txt", sep = "")
incrementalPredictives_fr <- webppl(incrementalPredictionScript_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(incrementalPredictives_fr, d_fr)
ggsave("results/incremental/predictives_french.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH DATA

incrementalEstimates_eng <- getEstimates(incrementalPosteriors_eng) 
incrementalPredictionScript_eng <- wrapPrediction(model, incrementalEstimates_eng,
                                              overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                              colorOnlyUtterance = "START sameColor sameType STOP",
                                              sizeOnlyUtterance = "START sameSize sameType STOP",
                                              "sameColor_sameSize_sameType",
                                              "incremental")

write.table(incrementalPredictionScript_eng, file = "predlook.txt", sep = "")
incrementalPredictives_eng <- webppl(incrementalPredictionScript_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(incrementalPredictives_eng, d_eng)
ggsave("results/incremental/predictives_english.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH AND FRENCH DATA, 
# MODEL PARAMETERS ESTIMATED FROM BOTH LANGUAGES

incrementalEstimates_both <- getEstimates(incrementalPosteriors_both) 
incrementalPredictionScript_both_fr <- wrapPrediction(model, incrementalEstimates_both,
                                                  overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                                  colorOnlyUtterance = "START sameType sameColor STOP",
                                                  sizeOnlyUtterance = "START sameSize sameType STOP",
                                                  "sameColor_sameSize_sameType",
                                                  "incremental")
write.table(incrementalPredictionScript_both_fr, file = "predlook.txt", sep = "")
incrementalPredictives_both_fr <- webppl(incrementalPredictionScript_both_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(incrementalPredictives_both_fr, d_fr)
ggsave("results/incremental/predictives_both_fr.png", width = 4, height = 3, units = "in")

incrementalPredictionScript_both_eng <- wrapPrediction(model, incrementalEstimates_both,
                                                   overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                                   colorOnlyUtterance = "START sameColor sameType STOP",
                                                   sizeOnlyUtterance = "START sameSize sameType STOP",
                                                   "sameColor_sameSize_sameType",
                                                   "incremental")
write.table(incrementalPredictionScript_both_eng, file = "predlook.txt", sep = "")
incrementalPredictives_both_eng <- webppl(incrementalPredictionScript_both_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(incrementalPredictives_both_eng, d_eng)
ggsave("results/incremental/predictives_both_eng.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                        "incrementalContinuous", 2500, 0, 7500)

write.table(incrementalContinuousInferenceScript, file = "incrementalContinuouslook.txt", sep = "")

# # ESTIMATE USING RWEBPPL:

incrementalContinuousPosteriors_fr <- webppl(incrementalContinuousInferenceScript, data = fr_input, data_var = "df",
                               random_seed = 3333)
saveRDS(incrementalContinuousPosteriors_fr, "results/incrementalContinuous/posteriors_fr.RDS")
incrementalContinuousPosteriors_eng <- webppl(incrementalContinuousInferenceScript, data = eng_input, data_var = "df",
                                random_seed = 3333)
saveRDS(incrementalContinuousPosteriors_eng, "results/incrementalContinuous/posteriors_eng.RDS")
incrementalContinuousPosteriors_both <- webppl(incrementalContinuousInferenceScript, data = combined_input, data_var = "df",
                                 random_seed = 3333)
saveRDS(incrementalContinuousPosteriors_both, "results/incrementalContinuous/posteriors_both.RDS")

# # LOAD IN FROM SAVED:

incrementalContinuousPosteriors_fr <- readRDS("results/incrementalContinuous/posteriors_fr.RDS")
incrementalContinuousPosteriors_eng <- readRDS("results/incrementalContinuous/posteriors_eng.RDS")
incrementalContinuousPosteriors_both <- readRDS("results/incrementalContinuous/posteriors_both.RDS")

graphAlpha(incrementalContinuousPosteriors_fr) + ggtitle("Incremental-continuous alpha posterior (French)")
ggsave("results/incrementalContinuous/alpha_fr.png")
graphCostPosteriors_withNoun(incrementalContinuousPosteriors_fr) + ggtitle("Incremental-continuous cost posteriors (French)")
ggsave("results/incrementalContinuous/cost_fr.png")
graphNoisePosteriors_withNoun(incrementalContinuousPosteriors_fr) + ggtitle("Incremental-continuous noise posteriors (French)")
ggsave("results/incrementalContinuous/noise_fr.png")

graphAlpha(incrementalContinuousPosteriors_eng) + ggtitle("Incremental-continuous alpha posterior (English)")
ggsave("results/incrementalContinuous/alpha_eng.png")
graphCostPosteriors_withNoun(incrementalContinuousPosteriors_eng) + ggtitle("Incremental-continuous cost posteriors (English)")
ggsave("results/incrementalContinuous/cost_eng.png")
graphNoisePosteriors_withNoun(incrementalContinuousPosteriors_eng) + ggtitle("Incremental-continuous noise posteriors (English)")
ggsave("results/incrementalContinuous/noise_eng.png")

graphAlpha(incrementalContinuousPosteriors_both) + ggtitle("Incremental-continuous alpha posterior (English+French)")
ggsave("results/incrementalContinuous/alpha_both.png")
graphCostPosteriors_withNoun(incrementalContinuousPosteriors_both) + ggtitle("Incremental-continuous cost posteriors (English+French)")
ggsave("results/incrementalContinuous/cost_both.png")
graphNoisePosteriors_withNoun(incrementalContinuousPosteriors_both) + ggtitle("Incremental-continuous noise posteriors (English+French)")
ggsave("results/incrementalContinuous/noise_both.png")

# RUN FORWARD TO GET PREDICTIONS FOR FRENCH DATA

incrementalContinuousEstimates_fr <- getEstimates(incrementalContinuousPosteriors_fr) 
incrementalContinuousPredictionScript_fr <- wrapPrediction(model, incrementalContinuousEstimates_fr,
                                             overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                             colorOnlyUtterance = "START sameType sameColor STOP",
                                             sizeOnlyUtterance = "START sameSize sameType STOP",
                                             "sameColor_sameSize_sameType",
                                             "incrementalContinuous")

write.table(incrementalContinuousPredictionScript_fr, file = "predlook.txt", sep = "")
incrementalContinuousPredictives_fr <- webppl(incrementalContinuousPredictionScript_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(incrementalContinuousPredictives_fr, d_fr)
ggsave("results/incrementalContinuous/predictives_french.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH DATA

incrementalContinuousEstimates_eng <- getEstimates(incrementalContinuousPosteriors_eng) 
incrementalContinuousPredictionScript_eng <- wrapPrediction(model, incrementalContinuousEstimates_eng,
                                              overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                              colorOnlyUtterance = "START sameColor sameType STOP",
                                              sizeOnlyUtterance = "START sameSize sameType STOP",
                                              "sameColor_sameSize_sameType",
                                              "incrementalContinuous")

write.table(incrementalContinuousPredictionScript_eng, file = "predlook.txt", sep = "")
incrementalContinuousPredictives_eng <- webppl(incrementalContinuousPredictionScript_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(incrementalContinuousPredictives_eng, d_eng)
ggsave("results/incrementalContinuous/predictives_english.png", width = 4, height = 3, units = "in")

# RUN FORWARD TO GET PREDICTIONS FOR ENGLISH AND FRENCH DATA, 
# MODEL PARAMETERS ESTIMATED FROM BOTH LANGUAGES

incrementalContinuousEstimates_both <- getEstimates(incrementalContinuousPosteriors_both) 
incrementalContinuousPredictionScript_both_fr <- wrapPrediction(model, incrementalContinuousEstimates_both,
                                                  overmodifyingUtterance = "START sameSize sameType sameColor STOP", 
                                                  colorOnlyUtterance = "START sameType sameColor STOP",
                                                  sizeOnlyUtterance = "START sameSize sameType STOP",
                                                  "sameColor_sameSize_sameType",
                                                  "incrementalContinuous")
write.table(incrementalContinuousPredictionScript_both_fr, file = "predlook.txt", sep = "")
incrementalContinuousPredictives_both_fr <- webppl(incrementalContinuousPredictionScript_both_fr, data = statesUtterances_fr, data_var = "df")
graphPredictives(incrementalContinuousPredictives_both_fr, d_fr)
ggsave("results/incrementalContinuous/predictives_both_fr.png", width = 4, height = 3, units = "in")

incrementalContinuousPredictionScript_both_eng <- wrapPrediction(model, incrementalContinuousEstimates_both,
                                                   overmodifyingUtterance = "START sameSize sameColor sameType STOP", 
                                                   colorOnlyUtterance = "START sameColor sameType STOP",
                                                   sizeOnlyUtterance = "START sameSize sameType STOP",
                                                   "sameColor_sameSize_sameType",
                                                   "incrementalContinuous")
write.table(incrementalContinuousPredictionScript_both_eng, file = "predlook.txt", sep = "")
incrementalContinuousPredictives_both_eng <- webppl(incrementalContinuousPredictionScript_both_eng, data = statesUtterances_eng, data_var = "df")
graphPredictives(incrementalContinuousPredictives_both_eng, d_eng)
ggsave("results/incrementalContinuous/predictives_both_eng.png", width = 4, height = 3, units = "in")

# # # # XPRAG GRAPHING

theme_set(theme_bw(13))

predictions_agr <- rbind(vanillaPredictives_both_eng %>% mutate(model = "vanilla", language = "english"),
                         vanillaPredictives_both_fr %>% mutate(model = "vanilla", language = "french"),
                         continuousPredictives_both_eng %>% mutate(model = "continuous", language = "english"),
                         continuousPredictives_both_fr %>% mutate(model = "continuous", language = "french"),
                         incrementalPredictives_both_eng %>% mutate(model = "incremental", language = "english"),
                         incrementalPredictives_both_fr %>% mutate(model = "incremental", language = "french"),
                         incrementalContinuousPredictives_both_eng %>% mutate(model = "incrementalContinuous", language = "english"),
                         incrementalContinuousPredictives_both_fr %>% mutate(model = "incrementalContinuous", language = "french")) %>%
  pivot_longer(cols = c("size_color","color","size"),
               names_to = "utterance",
               values_to = "prediction")

df_agr <- rbind(d_eng %>% mutate(language = "english"),
                d_fr %>% mutate(language = "french")) %>% 
  pivot_longer(cols = c("size_color","color","size"),
               names_to = "utterance",
               values_to = "observation")
 
agr %>% group_by(model) %>%
  summarise(rsq = cor(prediction,observation)^2)

agr <- predictions_agr %>%
  left_join(df_agr, by = c("condition","language","utterance")) %>%
  mutate(bestModel = case_when(model == "continuous" ~ 1,
                               TRUE ~ 0),
         model = fct_relevel(model, "continuous", "vanilla", "incrementalContinuous", "incremental"),
         model = fct_recode(model, "Continuous" = "continuous",
                            "Vanilla" = "vanilla",
                            "Continuous-incr." = "incrementalContinuous",
                            "Incremental" = "incremental"),
         language = fct_recode(language, "English" = "english",
                               "French" = "french")) %>%
  mutate(scene = ifelse(grepl("size", condition, fixed = TRUE), "Size redundant", "Color redundant"))
  
ggplot(agr, aes(x = prediction, y = observation, # color = model, alpha = bestModel,
                shape = language, color = scene)) +
  facet_wrap(~model) +
  scale_alpha_continuous(range = c(1, 1)) +
  geom_point() +
  # guides(alpha="none") +
  guides(color=guide_legend(ncol=1, title.position = "top")) +
  guides(shape=guide_legend(ncol=1, title.position = "top")) +
  theme(legend.position = "bottom") +
  scale_color_viridis(discrete = TRUE, end = 0.75, name = "Scene type") +
  labs(shape = "Language") +
  xlab("Predicted utterance proportion") +
  ylab("Observed proportion") 
  
ggsave(file="../graphs/model_predictions_xprag.pdf",width=4,height=6)
ggsave(file="../graphs/model_predictions_xprag.png",width=4,height=4)

posteriors_toplot <- continuousPosteriors_both %>% filter(Parameter %in% c("colorNoiseVal","sizeNoiseVal","typeNoiseVal"))
posteriors_toplot$Parameter <- relevel(posteriors_toplot$Parameter, ref = "colorNoiseVal")
labels <- c(colorNoiseVal = "color", sizeNoiseVal = "size", typeNoiseVal = "type")
scale_value=1
ggplot(posteriors_toplot, aes(x = value)) +
         geom_histogram(aes(y=..density..),
                        data=subset(posteriors_toplot, Parameter == "colorNoiseVal"),
                        binwidth = .01, colour="black", fill="white") +
         geom_histogram(aes(y=..density..),
                        data =subset(posteriors_toplot, Parameter == "sizeNoiseVal" ),
                        binwidth = .01, colour="black", fill="white") +
         geom_histogram(aes(y=..density..),
                        data =subset(posteriors_toplot, Parameter == "typeNoiseVal" ),
                        binwidth = .01, colour="black", fill="white") +
         geom_density(aes(y=..density..), alpha=.5,
                      data=subset(posteriors_toplot, Parameter == "colorNoiseVal"),
                      adjust = 2, fill="#FF6666") +
         geom_density(aes(y=..density..), alpha=.5,
                      data=subset(posteriors_toplot, Parameter == "sizeNoiseVal"),
                      adjust = 2, fill="#FF6666") + 
         geom_density(aes(y=..density..), alpha=.5,
                      data=subset(posteriors_toplot, Parameter == "typeNoiseVal"),
                      adjust = 2, fill="#FF6666") + 
         ylab("Density") +
         xlab("Semantic Value") +
         xlim(0,1) +
         facet_grid(Parameter ~. , scales = 'free', labeller=labeller(Parameter = labels)) +
         theme(panel.border = element_rect(size=.2),
               plot.margin = unit(x = c(0.05, 0.02, 0.05, 0.05), units = "in"),
               panel.grid = element_line(size = .4),
               axis.line        = element_line(colour = "black", size = .2),
               axis.ticks       = element_line(colour = "black", size = .2),
               axis.ticks.length = unit(2, "pt"),
               # axis.text.x        = element_text(size = 10 * scale_value, colour = "black",vjust=2),
               # axis.text.y        = element_text(size = 10 * scale_value, colour = "black",margin = margin(r = 0.3)),#,hjust=-5),
               # axis.title.x       = element_text(size = 10 * scale_value, margin = margin(t = .5)),
               # axis.title.y       = element_text(size = 10 * scale_value, margin = margin(r = .5)),
               strip.text      = element_text(size = 10 * scale_value,margin=margin(t=4,r=4,b=4,l=4,unit="pt"))) +
  xlim(0.75,1) # +
  # ggtitle("Posterior parameter estimates")

ggsave(file="../graphs/model_posteriors_xprag.png",width=4,height=4)


# # # 

source("../../../../_shared/regressionHelpers.r")
library(viridis)


d <- bind_rows(read_delim("../../../../../data/FRENCH/nounInformative/main/data_exp1.tsv", delim = "\t") %>% mutate(Language = "French"),
               read_delim("../../../../../data/ENGLISH2022_summer/nounInformative/main/main_data_exp1.tsv", delim = "\t") %>% mutate(Language = "English"))

condition_info = read_csv("../../../data/condition-information.csv")

d = d %>% 
  left_join(condition_info,by=c("condition","NumDistractors")) %>%
  mutate(NounMentioned = case_when(typeMentioned == TRUE ~ "noun",
                                   TRUE ~ "no noun")) %>% 
  mutate(RedundantProperty = fct_recode(RedundantProperty, "color"="color redundant","size"="size redundant"))

d$DiffSize = d$NumDistractors - d$SameSize
d$DiffColor = d$NumDistractors - d$SameColor
d$DiffNoun = d$NumDistractors - d$SameNoun

# proportion of distractors with different noun (one proxy for redundant property informativeness)
d$propDiffNoun = round(d$DiffNoun / d$NumDistractors,2)
# proportion of distractors with different redundant property value (a second proxy for redundant property informativeness)
d = d %>% 
  mutate(propDiffRedundant = case_when(RedundantProperty == "color" ~ DiffColor / NumDistractors,
                                       RedundantProperty == "size" ~ DiffSize / NumDistractors,
                                       TRUE ~ 555))

# prepare joint dataset for analysis
# prepare english dataset for analysis
dm <- d %>% 
  filter(TrialType == "target") %>% 
  droplevels() %>% 
  mutate(RedundantProperty=fct_relevel(RedundantProperty,"size")) %>% 
  mutate(Language=fct_relevel(as.factor(Language),"French")) %>% 
  mutate(redUtterance = as.factor(redUtterance), # outcome variable
         cRedundantProperty = as.numeric(as.factor(RedundantProperty)) - mean(as.numeric(as.factor(RedundantProperty))),
         cpropDiffNoun = propDiffNoun - mean(propDiffNoun),
         cpropDiffRedundant = propDiffRedundant - mean(propDiffRedundant),
         gameid = factor(gameid),
         cLanguage = as.numeric(as.factor(Language)) - mean(as.numeric(as.factor(Language))),
         Item = as.factor(ItemID)) # edited:

contrasts(dm$redUtterance) # contrasts set to predict redundancy
contrasts(as.factor(dm$RedundantProperty)) # ref level: size redundant
contrasts(as.factor(dm$Language)) # ref level: French

# plot both languages in one figure for xprag
# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY
agr <- dm %>%
  group_by(RedundantProperty,propDiffNoun,propDiffRedundant,Language) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high)

ggplot(agr, aes(x=propDiffRedundant,y=Probability,color=propDiffNoun)) +
  # geom_point(position=dodge) +
  geom_point(size=2) +
  # geom_text(aes(label=numCondition)) +
  # geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03,position=dodge) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03) +
  # xlab("Proportion of distractors with different redundant property value") +
  xlab("Informativeness of redundant property") +
  ylab("Proportion of redundant modifiers") +
  # scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  # scale_color_viridis(name="Proportion of distractors with different noun",begin=.8,end=0,breaks = c(.2,.4,.6)) +
  scale_color_viridis(name="Informativeness of noun",begin=.8,end=0,breaks = c(.2,.4,.6)) +  
  # scale_shape_manual(name="Proportion of\ndistractors with\ndifferent noun",values=c(0,7,15))
  # scale_alpha_continuous(range=c(.3,1))
  facet_grid(Language~RedundantProperty) +
  theme(legend.position="top",legend.margin=margin(b=-10))

ggsave(file="../graphs/redundant_proportions_xprag.pdf",width=8,height=6)
ggsave(file="../graphs/redundant_proportions_xprag.png",width=4,height=4)
