setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)
source("helpers.R")

source("../_shared/BDA_dataprep.R")
source("../../_shared/inferenceHelpers.R")
source("../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed <- read_csv("../../data/english_perTrial.csv")
#d_uncollapsed <- read_csv("../../data/degen_bda_data.csv")

# COLLAPSE DATA (STILL NECESSARY FOR VISUALIZATIONS)

d_collapsed <- collapse_dataset(d_uncollapsed)

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

statesUtterances <- makeStatesUtterances(d_uncollapsed, "english")

# MAKE INPUT DATA TO BDA: EACH DATUM INCLUDES RESPONSE, STATES, UTTERANCES

df <- d_uncollapsed %>%
  merge(statesUtterances) %>%
  mutate(response = case_when(response == "color" ~ "START color STOP",
                              response == "size" ~ "START size STOP",
                              response == "size_color" ~ "START size color STOP")) %>%
  select(response, states, utterances, condition)

# MAKE THE MODEL 

model <- makeModel("modelAndSemantics.txt")

# MODEL 1: VANILLA RSA

# POSTERIORS

# # lower number of samples (for testing)

vanillaInferenceScript <- wrapInference(model, "color_size", "vanilla", 5000, 10, 50000)

vanillaPosteriors <- webppl(vanillaInferenceScript, data = df, data_var = "df", random_seed = 3333)

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/eng_vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                             "START size color STOP", 
                                             "color_size",
                                             "vanilla")

vanillaPredictives <- webppl(vanillaPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(vanillaPredictives, d_collapsed)

ggsave("results/eng_vanillaPredictives.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

<<<<<<< HEAD
continuousInferenceScript <- wrapInference(model, "color_size", "continuous", 5000, 10, 50000)
=======
continuousInferenceScript <- wrapInference(model, "color_size", "continuous", 8000, 10, 15000)
>>>>>>> master

continuousPosteriors <- webppl(continuousInferenceScript, data = df, data_var = "df", random_seed = 3333)

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/eng_continuousPosteriors_8000samples_15000burn.png")

# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript <- wrapPrediction(model, continuousEstimates,
                                              "START size color STOP", 
                                              "color_size",
                                              "continuous")

continuousPredictives <- webppl(continuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(continuousPredictives, d_collapsed) + ggtitle("Continuous predictives")

<<<<<<< HEAD
ggsave("results/eng_continuousPredictives.png", width = 4, height = 3, units = "in")
=======
ggsave("results/eng_continuousPredictives_8000samples_15000burn.png", width = 4, height = 3, units = "in")
>>>>>>> master


# MODEL 3: INCREMENTAL RSA 

incrementalInferenceScript <- wrapInference(model, "color_size", "incremental", 5000, 10, 50000)

incrementalPosteriors <- webppl(incrementalInferenceScript, data = df, data_var = "df",  random_seed = 3333)

graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

ggsave("results/eng_incrementalPosteriors.png")

# PREDICTIVES

incrementalEstimates <- getEstimates(incrementalPosteriors)

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                              "START size color STOP", 
                                              "color_size",
                                              "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalPredictives, d_collapsed) + ggtitle("Incremental predictives")

ggsave("results/eng_incrementalPredictives_8000samples_15000burn.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

<<<<<<< HEAD
incrementalContinuousInferenceScript <- wrapInference(model, "color_size", "incrementalContinuous", 5000, 10, 50000)
=======
incrementalContinuousInferenceScript <- wrapInference(model, "color_size", "incrementalContinuous", 8000, 10, 15000)
>>>>>>> master

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = df, data_var = "df",random_seed = 3333)

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("results/eng_incrementalContinuousPosteriors_8000samples_15000burn.png")

save.image("results/eng_results_50000burn.RData")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, 
                                                        incrementalContinuousEstimates,
                                                        "START size color STOP", 
                                                        "color_size",
                                                        "incrementalContinuous")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalContinuousPredictives, d_collapsed)

ggsave("results/eng_incrementalContinuousPredictives_8000samples_15000burn.png", width = 4, height = 3, units = "in")

save.image("results/eng_results50000burn.RData")

#save.image("results/eng_results.RData")


# BAYESIAN MODEL COMPARISON: INCREMENTAL VS. GLOBAL 

# # STEP 1: WRAP INFERENCE COMMAND AROUND CORE MODEL

incrementalVGlobalInferenceCommand <- read_file("incrementalVGlobalComparison/inferenceCommand.txt")

# # # (TODO [LEYLA]: UP THE SAMPLE/LAG/BURN/RATE)

incrementalVGlobalInferenceCommand <- gsub("TARGET_REFERENT", "color_size", incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("NUM_SAMPLES", 5000, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("LAG", 10, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("BURN_IN", 50000, incrementalVGlobalInferenceCommand, fixed = TRUE)
  
incrementalVGlobalInferenceScript <- paste(read_file(model), incrementalVGlobalInferenceCommand, sep = "\n")

# # STEP 2: RUN SCRIPT AND GRAPH POSTERIORS 

incrementalVGlobalPosteriors <- webppl(incrementalVGlobalInferenceScript, data = df, data_var = "df",random_seed = 3333)

graphPosteriors(incrementalVGlobalPosteriors %>% filter(!(Parameter == "incrementalOrGlobal")) %>% mutate(value = as.numeric(value))) + ggtitle("Model parameter posteriors")

ggsave("incrementalVGlobalComparison/modelPosteriors.png")

# # STEP 3: CALCULATE POSTERIOR PROBABILITY OF INCREMENTAL VS. GLOBAL

modelPosterior <- incrementalVGlobalPosteriors %>% filter(Parameter == "incrementalOrGlobal") %>%
  count(value) %>%
  group_by(value) %>%
  summarize(posteriorProb = n / sum(n))

View(modelPosterior)


######################################################
# PLOTS FOR THE COGSCI PAPER
######################################################
# modification type
empirical_toplot = d_uncollapsed %>%
  mutate(size = ifelse(response=="size",1,0)) %>%
  mutate(color = ifelse(response=="color",1,0)) %>%
  mutate(size_color = ifelse(response=="size_color",1,0)) %>%
  select(gameId,roundNumber,condition,response,size,color,size_color) %>%
  gather(utterance,value,size:size_color) %>%
  group_by(utterance,condition) %>%
  summarize(Mean=mean(value)) %>%
  #summarise(Mean=mean(value),CILow=ci.low(value),CIHigh=ci.high(value)) %>%
  #ungroup() %>%
  #mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(model="empirical")

vanilla_toplot = vanillaPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="vanilla")

continuous_toplot = continuousPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="continuous")

incremental_toplot = incrementalPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="incremental")

incrementalContinuous_toplot = incrementalContinuousPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="incrementalContinuous")

#merge all datasets
merged = rbind(empirical_toplot,vanilla_toplot,continuous_toplot,incremental_toplot,incrementalContinuous_toplot) %>%
  mutate(condition=ifelse(condition=="color31","color sufficient",ifelse(condition=="size31","size sufficient",NA))) %>%
  mutate(language="English")

merged$model = factor(merged$model, levels = c("empirical", "vanilla","continuous","incremental","incrementalContinuous"))

ggplot(merged, aes(x=utterance,y=Mean, fill=model)) +
  geom_bar(position="dodge", stat = "identity") +
  facet_grid(~condition)

write.csv(merged, "english_modelComp.csv", row.names=TRUE)
ggsave("results/modelComparison.png")

