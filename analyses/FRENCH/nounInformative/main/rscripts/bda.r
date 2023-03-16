setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(devtools)
library(rwebppl)
#install_github("mhtess/rwebppl")

source("../../../../_shared/BDA_dataprep_nouninfo.R")
source("../../../../../_shared/inferenceHelpers.R")
source("../../../../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed_fr <- read_csv("../../../../../data/FRENCH/nounInformative/main/bda_data.csv") %>%
  rename(response = redBDAUtterance) %>% filter(!grepl("filler",condition))
#d_uncollapsed_eng <- read_csv("../../../../../data/ENGLISH2022_summer/nounInformative/main/bda_data.csv")


editResponse = function(df) {
  df <- df %>% mutate(newResponse = case_when(
    response == "size_color" ~ "START sameSize sameType sameColor STOP",
   response == "size" ~ "START sameSize sameType STOP",
  response == "color" ~ "START sameType sameColor STOP",
  TRUE ~ "OTHER"
  )) %>%
    rename(oldResponse = response)  %>%
    rename(response = newResponse)
  return(df)
}

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

#for the current version, noun omission is not included as a possible utterance for French
statesUtterances_fr <- makeStatesUtterances(d_uncollapsed_fr, "french")
#statesUtterances_eng <- makeStatesUtterances(d_uncollapsed_eng, "english")


# 'COLLAPSE' THE DATASET (GET PROPORTIONS OF COLOR, SIZE, COLORSIZE MENTION BY CONDITION)

d_fr <- collapse_dataset(d_uncollapsed_fr)
#d_eng <-collapse_dataset(d_uncollapsed_eng)
#what would combined dataset look like?

# 'df' IS INPUT TO THE BDA:

fr_input <- merge(d_uncollapsed_fr, statesUtterances_fr, by = "condition")

fr_input <- editResponse(fr_input)
#todo: gender marker = different trial types
#todo: no noun omission

# MAKE THE MODEL 

model <- makeModel("modelAndSemantics.txt")


# MODEL 1: VANILLA RSA

# POSTERIORS

#testing file bc this doesn't work aaaaa
#tester<- paste(read_file("tester.txt"))
#test <- webppl(tester,data = df, data_var = "df")
#view(test)


vanillaInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                        "vanilla", 2500, 0,0)
#so u can see the code ur making and despair
write.table(vanillaInferenceScript, file = "vanillalook.txt", sep = "")

vanillaPosteriors <- webppl(vanillaInferenceScript, data = fr_input, data_var = "df")

view(vanillaPosteriors)

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("../graphs/bda_results/vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                          "START sameSize sameType sameColor STOP", 
                                          "sameColor_sameSize_sameType",
                                          "vanilla")
write.table(vanillaPredictionScript, file = "predlook.txt", sep = "")

vanillaPredictives <- webppl(vanillaPredictionScript, data = fr_input, data_var = "df")

graphPredictives(vanillaPredictives, d_fr)

ggsave("results/vanillaPredictives.png", width = 4, height = 3, units = "in")





# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                                                     "continuous", 2500, 0,0)

continuousPosteriors <- webppl(continuousInferenceScript, data = fr_input, data_var = "df")

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("../graphs/bda_results/continuousPosteriors.png")

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

incrementalInferenceScript <- wrapInference(model, "sameColor_sameSize_sameType", 
                                                                         "incremental", 2500, 0,0)
incrementalPosteriors <- webppl(incrementalInferenceScript, data = fr_input, data_var = "df")



graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

ggsave("../graphs/bda_results/incrementalPosteriors.png")

# PREDICTIVES

summarize <- summarise

incrementalEstimates <- getEstimates(incrementalPosteriors) 

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                              "START size color STOP", 
                                              "color_size",
                                              "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = df, data_var = "df")

graphPredictives(incrementalPredictives, df) + ggtitle("Incremental predictives")

ggsave("../graphs/bda_results/incrementalPredictives.png", width = 4, height = 3, units = "in")



# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <- wrapInference(model, 
                                                      "sameColor_sameSize_sameType", 
                                                      "incrementalContinuous", 2500, 0, 0)

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = fr_input, data_var = "df")

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("../graphs/bda_results/incrementalContinuousPosteriors.png")

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