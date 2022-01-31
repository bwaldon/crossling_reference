setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("../_shared/BDA_dataprep.R")
source("../../_shared/inferenceHelpers.R")
source("../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed <- read_csv("../../data/ctsl_perTrial.csv")

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

vanillaInferenceScript <- wrapInference(model, "color_size", "vanilla_equalcost", 5000, 10, 200)

vanillaPosteriors <- webppl(vanillaInferenceScript, data = df, data_var = "df",, random_seed=3333)

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/equalcost/ctsl_vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                             "START color size STOP", 
                                             "color_size",
                                             "vanilla")

vanillaPredictives <- webppl(vanillaPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(vanillaPredictives, d_collapsed)

ggsave("results/equalcost/ctsl_vanillaPredictives.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousInferenceScript <- wrapInference(model, "color_size", "continuous", 5000, 10, 20000)

continuousPosteriors <- webppl(continuousInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/equalcost/ctsl_continuousPosteriors_5000samples_20000lag.png")


# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript <- wrapPrediction(model, continuousEstimates,
                                              "START color size STOP", 
                                              "color_size",
                                              "continuous")

continuousPredictives <- webppl(continuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(continuousPredictives, d_collapsed) + ggtitle("Continuous predictives")

ggsave("results/equalcost/ctsl_continuousPredictives.png", width = 4, height = 3, units = "in")


# MODEL 3: INCREMENTAL RSA 

incrementalInferenceScript <- wrapInference(model, "color_size", "incremental_equalcost", 5000, 10, 200)

incrementalPosteriors <- webppl(incrementalInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")


ggsave("results/equalcost/ctsl_incrementalPosteriors.png")

# PREDICTIVES

incrementalEstimates <- getEstimates(incrementalPosteriors)

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                              "START color size STOP", 
                                              "color_size",
                                              "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalPredictives, d_collapsed) + ggtitle("Incremental predictives")

ggsave("results/equalcost/ctsl_incrementalPredictives.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <- wrapInference(model, "color_size", "incrementalContinuous_equalcost", 5000, 10, 200)

incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = df, data_var = "df", random_seed=3333)

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("results/equalcost/ctsl_incrementalContinuousPosteriors.png")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, 
                                                        incrementalContinuousEstimates,
                                                        "START color size STOP", 
                                                        "color_size",
                                                        "incrementalContinuous")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalContinuousPredictives, d_collapsed)

ggsave("results/equalcost/ctsl_incrementalContinuousPredictives.png", width = 4, height = 3, units = "in")

save.image("results/equalcost/ctsl_results.RData")

# BAYESIAN MODEL COMPARISON: INCREMENTAL VS. GLOBAL 

# # STEP 1: WRAP INFERENCE COMMAND AROUND CORE MODEL

incrementalVGlobalInferenceCommand <- read_file("incrementalVGlobalComparison/inferenceCommand.txt")

# # # (TODO [LEYLA]: UP THE SAMPLE/LAG/BURN/RATE)

incrementalVGlobalInferenceCommand <- gsub("TARGET_REFERENT", "color_size", incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("NUM_SAMPLES", 5000, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("LAG", 10, incrementalVGlobalInferenceCommand, fixed = TRUE)
incrementalVGlobalInferenceCommand <- gsub("BURN_IN", 200, incrementalVGlobalInferenceCommand, fixed = TRUE)
  
incrementalVGlobalInferenceScript <- paste(read_file(model), incrementalVGlobalInferenceCommand, sep = "\n")

# # STEP 2: RUN SCRIPT AND GRAPH POSTERIORS 

incrementalVGlobalPosteriors <- webppl(incrementalVGlobalInferenceScript, data = df, data_var = "df", random_seed = 3333)

graphPosteriors(incrementalVGlobalPosteriors %>% filter(!(Parameter == "incrementalOrGlobal")) %>% mutate(value = as.numeric(value))) + ggtitle("Model parameter posteriors")

ggsave("incrementalVGlobalComparison/modelPosteriors_equalcost.png")

# # STEP 3: CALCULATE POSTERIOR PROBABILITY OF INCREMENTAL VS. GLOBAL

modelPosterior <- incrementalVGlobalPosteriors %>% filter(Parameter == "incrementalOrGlobal") %>%
  count(value) %>%
  group_by(value) %>%
  summarize(posteriorProb = n / sum(n))

View(modelPosterior)

save.image("results/equalcost/ctsl_comparison.RData")


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

#merge ctsl datasets
ctsl_merged = rbind(empirical_toplot,vanilla_toplot,continuous_toplot,incremental_toplot,incrementalContinuous_toplot) %>%
  mutate(condition=ifelse(condition=="color31","color sufficient",ifelse(condition=="size31","size sufficient",NA))) %>%
  mutate(language="CTSL")

#merge ctsl and english datasets 
english_merged = read_csv("english_modelComp.csv")

merged = rbind(ctsl_merged,english_merged)

merged$model = factor(merged$model, levels = c("empirical", "vanilla","continuous","incremental","incrementalContinuous"))

merged = merged %>%
  mutate(utterance=ifelse(utterance=="size_color", "color and size", utterance))%>%
  mutate(grp = ifelse(model=="empirical",1,0))

merged$utterance = factor(merged$utterance, levels = c("color", "size","color and size"))

library(RColorBrewer)
theme_set(theme_bw())

ggplot(merged, aes(x=utterance,y=Mean, fill=model)) +
  geom_bar(position="dodge",width=0.7, stat = "identity",) +
  facet_grid(language~condition) +
  scale_fill_brewer(palette = "Set1") +
  #scale_alpha(range = c(0.5, 1)) +
  theme(legend.position="bottom")

ggsave("results/merged_modelComparison.png", width =6 , height = 4, units = "in")
