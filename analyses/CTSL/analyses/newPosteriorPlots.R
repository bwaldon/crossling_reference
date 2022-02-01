setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(gridExtra)

source("_shared/BDA_vizHelpers.R")

# CTSL 

#load("bda_ctsl/Results/ctsl_results.RData")
load("bda_ctsl/Results/ctsl_results_50000burnin.RData")


# # VANILLA

pdf("newPosteriorPlots/ctsl/vanilla.pdf", width=5.5/2,height=2.7)
grid.arrange(graphCostPosteriors(vanillaPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             # graphNoisePosteriors(vanillaPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # CONTINUOUS

pdf("newPosteriorPlots/ctsl/continuous.pdf", width=5.5,height=2.7)
grid.arrange(graphCostPosteriors(continuousPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             graphNoisePosteriors(continuousPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # INCREMENTAL

pdf("newPosteriorPlots/ctsl/incremental.pdf", width=5.5/2,height=2.7)
grid.arrange(graphCostPosteriors(incrementalPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             # graphNoisePosteriors(inrementalPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # INCREMENTAL-CONTINUOUS

pdf("newPosteriorPlots/ctsl/incrementalContinuous.pdf", width=5.5,height=2.7)
grid.arrange(graphCostPosteriors(incrementalContinuousPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             graphNoisePosteriors(incrementalContinuousPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

rm(vanillaPosteriors,continuousPosteriors,incrementalPosteriors,incrementalContinuousPosteriors)

# ENGLISH

load("bda_english/Results/eng_results.RData")

# # VANILLA

pdf("newPosteriorPlots/english/vanilla.pdf", width=5.5/2,height=2.7)
grid.arrange(graphCostPosteriors(vanillaPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             # graphNoisePosteriors(vanillaPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # CONTINUOUS

pdf("newPosteriorPlots/english/continuous.pdf", width=5.5,height=2.7)
grid.arrange(graphCostPosteriors(continuousPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             graphNoisePosteriors(continuousPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # INCREMENTAL

pdf("newPosteriorPlots/english/incremental.pdf", width=5.5/2,height=2.7)
grid.arrange(graphCostPosteriors(incrementalPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             # graphNoisePosteriors(inrementalPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # INCREMENTAL-CONTINUOUS

pdf("newPosteriorPlots/english/incrementalContinuous.pdf", width=5.5,height=2.7)
grid.arrange(graphCostPosteriors(incrementalContinuousPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             graphNoisePosteriors(incrementalContinuousPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

rm(vanillaPosteriors,continuousPosteriors,incrementalPosteriors,incrementalContinuousPosteriors)

# DEGEN ET AL. (2020) - SANITY CHECK

load("bda_english/Results/degenetal/degenetal_results.RData")

# # VANILLA

pdf("newPosteriorPlots/degen2020/vanilla.pdf", width=5.5/2,height=2.7)
grid.arrange(graphCostPosteriors(vanillaPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             # graphNoisePosteriors(vanillaPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # CONTINUOUS

pdf("newPosteriorPlots/degen2020/continuous.pdf", width=5.5,height=2.7)
grid.arrange(graphCostPosteriors(continuousPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             graphNoisePosteriors(continuousPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # INCREMENTAL

pdf("newPosteriorPlots/degen2020/incremental.pdf", width=5.5/2,height=2.7)
grid.arrange(graphCostPosteriors(incrementalPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             # graphNoisePosteriors(inrementalPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

# # INCREMENTAL-CONTINUOUS

pdf("newPosteriorPlots/degen2020/incrementalContinuous.pdf", width=5.5,height=2.7)
grid.arrange(graphCostPosteriors(incrementalContinuousPosteriors %>% filter(Parameter %in% c("sizeCost","colorCost"))),
             graphNoisePosteriors(incrementalContinuousPosteriors %>% filter(Parameter %in% c("sizeNoiseVal","colorNoiseVal"))),
             nrow=1)
dev.off()

