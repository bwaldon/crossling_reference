setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

source("../_shared/BDA_dataprep.R")
source("../../_shared/inferenceHelpers.R")
source("../_shared/BDA_vizhelpers.R")

# PUT IN AN "UNCOLLAPSED" DATAFILE WITH DEGEN ET AL.'S FORMAT

d_uncollapsed <- read_csv("../../data/Degen2020/bda_data.csv")

# MAKE A TIBBLE: COLUMNS CONDITION, REFERENTS IN THAT CONDITION (STATES), ALTERNATIVES IN THAT CONDITION (UTTERANCES)

statesUtterances <- makeStatesUtterances(d_uncollapsed, "english")

# 'COLLAPSE' THE DATASET (GET PROPORTIONS OF COLOR, SIZE, COLORSIZE MENTION BY CONDITION)

d_collapsed <- collapse_dataset(d_uncollapsed)

# 'df' IS INPUT TO THE BDA:

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

vanillaInferenceScript <- wrapInference(model, "color_size", "vanilla", 2500, 10, 12500)

# vanillaPosteriors <- webppl(vanillaInferenceScript, data = df, data_var = "df", random_seed = 3333)

vanillaPosteriors <- readRDS("results/vanillaPosteriors.RDS")

# saveRDS(vanillaPosteriors, "results/vanillaPosteriors.RDS")

graphPosteriors(vanillaPosteriors) + ggtitle("Vanilla posteriors")

ggsave("results/vanillaPosteriors.png")

# PREDICTIVES

vanillaEstimates <- getEstimates(vanillaPosteriors) 

vanillaPredictionScript <- wrapPrediction(model, vanillaEstimates,
                                          "START size color STOP", 
                                          "color_size",
                                          "vanilla")

vanillaPredictives <- webppl(vanillaPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(vanillaPredictives, d_collapsed)

ggsave("results/vanillaPredictives.png", width = 4, height = 3, units = "in")

# MODEL 2: CONTINUOUS RSA

# POSTERIORS

continuousInferenceScript <- wrapInference(model, "color_size", "continuous", 2500, 10, 12500)

# continuousPosteriors <- webppl(continuousInferenceScript, data = df, data_var = "df", random_seed = 3333)

continuousPosteriors <- readRDS("results/continuousPosteriors.RDS")

saveRDS(continuousPosteriors, "results/continuousPosteriors.RDS")

graphPosteriors(continuousPosteriors) + ggtitle("Continuous posteriors")

ggsave("results/continuousPosteriors.png")

# PREDICTIVES

continuousEstimates <- getEstimates(continuousPosteriors) 

continuousPredictionScript <- wrapPrediction(model, continuousEstimates,
                                             "START size color STOP", 
                                             "color_size",
                                             "continuous")

continuousPredictives <- webppl(continuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(continuousPredictives, d_collapsed)

ggsave("results/continuousPredictives.png", width = 4, height = 3, units = "in")

# MODEL 3: INCREMENTAL RSA 

incrementalInferenceScript <- wrapInference(model, "color_size", "incremental", 2500, 10, 12500)

# incrementalPosteriors <- webppl(incrementalInferenceScript, data = df, data_var = "df", random_seed = 3333)

incrementalPosteriors <- readRDS("results/incrementalPosteriors.RDS")

saveRDS(incrementalPosteriors, "results/incrementalPosteriors.RDS")

graphPosteriors(incrementalPosteriors) + ggtitle("Incremental posteriors")

ggsave("results/incrementalPosteriors.png")

# PREDICTIVES

summarize <- summarise

incrementalEstimates <- getEstimates(incrementalPosteriors) 

incrementalPredictionScript <- wrapPrediction(model, incrementalEstimates,
                                              "START size color STOP", 
                                              "color_size",
                                              "incremental")

incrementalPredictives <- webppl(incrementalPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalPredictives, d_collapsed) + ggtitle("Incremental predictives")

ggsave("results/incrementalPredictives.png", width = 4, height = 3, units = "in")

# MODEL 4: INCREMENTAL-CONTINUOUS RSA

# POSTERIORS

incrementalContinuousInferenceScript <-wrapInference(model, "color_size", "incrementalContinuous", 2500, 10, 12500)

# incrementalContinuousPosteriors <- webppl(incrementalContinuousInferenceScript, data = df, data_var = "df", random_seed = 3333)

incrementalContinuousPosteriors <- readRDS("results/incrementalContinuousPosteriors.RDS")

saveRDS(incrementalContinuousPosteriors, "results/incrementalContinuousPosteriors.RDS")

graphPosteriors(incrementalContinuousPosteriors) + ggtitle("Incremental-continuous posteriors")

ggsave("results/incrementalContinuousPosteriors.png")

# PREDICTIVES

incrementalContinuousEstimates <- getEstimates(incrementalContinuousPosteriors) 

incrementalContinuousPredictionScript <- wrapPrediction(model, 
                                                        incrementalContinuousEstimates,
                                                        "START size color STOP", 
                                                        "color_size",
                                                        "incrementalContinuous")

incrementalContinuousPredictives <- webppl(incrementalContinuousPredictionScript, data = unique(df %>%  select(condition,states,utterances)), data_var = "df")

graphPredictives(incrementalContinuousPredictives, d_collapsed)

ggsave("results/incrementalContinuousPredictives.png", width = 4, height = 3, units = "in")

save.image("results/results.RData")

# # # XPRAG

# DEGEN 2020-STYLE POSTERIOR GRAPHS 

graphNoisePosteriors(continuousPosteriors %>% filter(Parameter %in% c("colorNoiseVal","sizeNoiseVal")))
ggsave("results/continuousPosteriors_degen.pdf")

# # GRAPH PREDICTIVES BY RED EXP / BY SCENE VARIATION

source("../_shared/regressionHelpers.r")

d_regressionFormat <- read_delim("../../data/Degen2020/data_exp1.csv",delim="\t") %>%
  mutate(condition = paste(SufficientProperty,NumDistractors,NumSameDistractors,sep = ""))

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

visualize_sceneVariation_withModel = function(d, predictives1,predictives2,predictives3,predictives4) {
  agr <- d %>%
    select(redundant,RedundantProperty,NumDistractors,SceneVariation,condition) %>%
    gather(Utterance,Mentioned,-RedundantProperty,-NumDistractors,-SceneVariation,-condition) %>%
    group_by(Utterance,RedundantProperty,NumDistractors,SceneVariation,condition) %>%
    summarise(Probability=mean(Mentioned),ci.low=ci.low(Mentioned),ci.high=ci.high(Mentioned)) %>%
    ungroup() %>%
    mutate(YMin = Probability - ci.low, YMax = Probability + ci.high, Distractors=as.factor(NumDistractors)) %>%
    left_join(predictives1 %>% mutate(predictions1 = size_color) %>% select(condition,predictions1), by = c("condition")) %>%
    left_join(predictives2 %>% mutate(predictions2 = size_color) %>% select(condition,predictions2), by = c("condition")) %>%
    left_join(predictives3 %>% mutate(predictions3 = size_color) %>% select(condition,predictions3), by = c("condition")) %>%
    left_join(predictives4 %>% mutate(predictions4 = size_color) %>% select(condition,predictions4), by = c("condition"))
  # return(agr)
  ggplot(agr, aes(x=SceneVariation,y=Probability,shape=Distractors,group=1)) +
    geom_point() +
    geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
    xlab("Scene variation") +
    ylab("Probability of redundant modifier") +
    scale_shape_discrete(name = "Number of\ndistractors") +
    facet_wrap(~RedundantProperty) +
    geom_point(data = agr %>% mutate(Probability = predictions1), aes(color = "Vanilla\n(R^2 = 0.69)")) +
    geom_point(data = agr %>% mutate(Probability = predictions2), aes(color = "Continuous\n(R^2 = 0.97)")) +
    geom_point(data = agr %>% mutate(Probability = predictions3), aes(color = "Incremental\n(R^2 = 0.86)")) +
    geom_point(data = agr %>% mutate(Probability = predictions4), aes(color = "Cont.-Incr.\n(R^2 = 0.97)")) +
    theme_bw() +
    labs(colour = "Model") +
    scale_color_manual(values = cbPalette,
                       breaks = c("Continuous\n(R^2 = 0.97)",
                                  "Cont.-Incr.\n(R^2 = 0.97)",
                                  "Incremental\n(R^2 = 0.86)",
                                  "Vanilla\n(R^2 = 0.69)")) +
    ylim(0,0.85) +
    ggtitle("Results and model predictions (English)") +
    guides(color = guide_legend(order=1),
            shape = guide_legend(order=2))
}

# cont-incr: 0.985^2 = 0.97
# incr: 0.926^2 = 0.86
# cont: 0.987^2 = 0.97
# vanil: 0.830^2 = 0.69

visualize_sceneVariation_withModel(d_regressionFormat,
                                   vanillaPredictives,
                                   continuousPredictives,
                                   incrementalPredictives,
                                   incrementalContinuousPredictives)

ggsave("results/model_preds_English.png", width = 7, height = 3, units = "in")

