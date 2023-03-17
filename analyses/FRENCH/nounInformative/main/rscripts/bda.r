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

vanillaPosteriors_fr <- webppl(vanillaInferenceScript, data = fr_input, data_var = "df")
vanillaPosteriors_eng <- webppl(vanillaInferenceScript, data = eng_input, data_var = "df")
vanillaPosteriors_both <- webppl(vanillaInferenceScript, data = combined_input, data_var = "df")

#view(vanillaPosteriors)

graphPosteriors(vanillaPosteriors_fr) + ggtitle("Vanilla posteriors")
ggsave("../graphs/bda_results/vanillaPosteriors_fr.png")

graphPosteriors(vanillaPosteriors_eng) + ggtitle("Vanilla posteriors")
ggsave("../graphs/bda_results/vanillaPosteriors_eng.png")

graphPosteriors(vanillaPosteriors_both) + ggtitle("Vanilla posteriors")
ggsave("../graphs/bda_results/vanillaPosteriors_both.png")

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

continuousPosteriors_fr <- webppl(continuousInferenceScript, data = fr_input, data_var = "df")
continuousPosteriors_eng <- webppl(continuousInferenceScript, data = eng_input, data_var = "df")
continuousPosteriors_both <- webppl(continuousInferenceScript, data = combined_input, data_var = "df")

graphPosteriors(continuousPosteriors_fr) + ggtitle("Continuous posteriors")
ggsave("../graphs/bda_results/continuousPosteriors_fr.png")
#0.366

graphPosteriors(continuousPosteriors_eng) + ggtitle("Continuous posteriors")
ggsave("../graphs/bda_results/continuousPosteriors_eng.png")
#0.34

graphPosteriors(continuousPosteriors_both) + ggtitle("Continuous posteriors")
ggsave("../graphs/bda_results/continuousPosteriors_both.png")
#0.345

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

incrementalPosteriors_fr <- webppl(incrementalInferenceScript, data = fr_input, data_var = "df")
incrementalPosteriors_eng <- webppl(incrementalInferenceScript, data = eng_input, data_var = "df")
incrementalPosteriors_both <- webppl(incrementalInferenceScript, data = combined_input, data_var = "df")


graphPosteriors(incrementalPosteriors_fr) + ggtitle("Incremental posteriors")
ggsave("../graphs/bda_results/incrementalPosteriors_fr.png")
#0.2212

graphPosteriors(incrementalPosteriors_eng) + ggtitle("Incremental posteriors")
ggsave("../graphs/bda_results/incrementalPosteriors_eng.png")
#0.2136
graphPosteriors(incrementalPosteriors_both) + ggtitle("Incremental posteriors")
ggsave("../graphs/bda_results/incrementalPosteriors_both.png")
#0.2704

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

incrementalContinuousPosteriors_fr <- webppl(incrementalContinuousInferenceScript, data = fr_input, data_var = "df")
incrementalContinuousPosteriors_eng <- webppl(incrementalContinuousInferenceScript, data = eng_input, data_var = "df")
incrementalContinuousPosteriors_both <- webppl(incrementalContinuousInferenceScript, data = combined_input, data_var = "df")

graphPosteriors(incrementalContinuousPosteriors_fr) + ggtitle("Incremental-continuous posteriors")
ggsave("../graphs/bda_results/incrementalContinuousPosteriors_fr.png")
#0.3156

graphPosteriors(incrementalContinuousPosteriors_eng) + ggtitle("Incremental-continuous posteriors")
ggsave("../graphs/bda_results/incrementalContinuousPosteriors_eng.png")
#0.380

graphPosteriors(incrementalContinuousPosteriors_both) + ggtitle("Incremental-continuous posteriors")
ggsave("../graphs/bda_results/incrementalContinuousPosteriors_both.png")
#0.2624

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