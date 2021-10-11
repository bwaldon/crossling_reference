library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# RUN WEBPPL FROM A V8 JS ENGINE (FASTER WHEN YOU NEED TO RUN MANY, MANY CALLS TO WEBPPL)

source("../../_shared/V8wppl.R")

# SOURCE SOME HELPER SCRIPTS

source("../../_shared/simulationHelpers.R")

# SOURCE THE ENGINE

engine <- read_file("../../_shared/engine.txt")

modelAndSemantics <- read_file("../models/pins/modelAndSemantics.txt")

# STATES

states_cs = c("bigred", "smallblue", "smallred")
states_ss = c("bigblue", "bigred", "smallblue")

# UTTERANCES: SIZE SUFFICIENT

utterances_eng_ss <- c("START red pin STOP", "START blue pin STOP", 
                       "START big pin STOP", "START small pin STOP",
                       "START big blue pin STOP", 
                       "START big red pin STOP",
                       "START small blue pin STOP") 

utterances_sp_split_ss <- c("START pin red STOP", "START pin blue STOP", 
                            "START pin big STOP", "START pin small STOP",
                            "START big pin blue STOP", 
                            "START big pin red STOP",
                            "START small pin blue STOP") 

utterances_sp_conj_ss <- c("START pin red STOP", "START pin blue STOP", 
                           "START pin big STOP", "START pin small STOP",
                           "START pin blue big STOP",
                           "START pin big blue STOP",
                           "START pin red big STOP",
                           "START pin big red STOP",
                           "START pin blue small STOP", 
                           "START pin small blue STOP")

utterances_sp_postnom_ss <- c("START pin red STOP", "START pin blue STOP", 
                              "START pin big STOP", "START pin small STOP",
                              "START pin blue big STOP",
                              "START pin red big STOP",
                              "START pin blue small STOP")

# UTTERANCES: COLOR SUFFICIENT

utterances_eng_cs <- c("START red pin STOP", "START blue pin STOP", 
                       "START big pin STOP", "START small pin STOP",
                       "START big red pin STOP",
                       "START small blue pin STOP",
                       "START small red pin STOP")

utterances_sp_split_cs <- c("START pin red STOP", "START pin blue STOP", 
                            "START pin big STOP", "START pin small STOP",
                            "START big pin red STOP",
                            "START small pin blue STOP", 
                            "START small pin red STOP")

utterances_sp_conj_cs <- c("START pin red STOP", "START pin blue STOP", 
                           "START pin big STOP", "START pin small STOP",
                           "START pin red big STOP",
                           "START pin big red STOP",
                           "START pin blue small STOP", 
                           "START pin small blue STOP", 
                           "START pin red small STOP",
                           "START pin small red STOP")

utterances_sp_postnom_cs <- c("START pin red STOP", "START pin blue STOP", 
                              "START pin big STOP", "START pin small STOP",
                              "START pin red big STOP",
                              "START pin blue small STOP", 
                              "START pin red small STOP")


# COMMANDS

cmd_eng = 'incrementalUtteranceSpeaker("START small blue pin STOP", "smallblue", model, params, semantics)'
cmd_sp_split = 'incrementalUtteranceSpeaker("START small pin blue STOP", "smallblue", model, params, semantics)'
cmd_sp_conj = 'incrementalUtteranceSpeaker("START pin blue small STOP", "smallblue", model, params, semantics) + incrementalUtteranceSpeaker("START pin small blue STOP", "smallblue", model, params, semantics)'
cmd_sp_postnom = 'incrementalUtteranceSpeaker("START pin blue small STOP", "smallblue", model, params, semantics)'

# VALDF FOR SCIL PAPER

valDF <- data.frame("colorNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "sizeNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "alpha" = c(1,2.5,15,10,20,30))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha) %>%
  filter(alpha %in% c(5,10,15,20))

# VALDF FOR SCIL APP

valDF <- data.frame("colorNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "sizeNoise" = c(0.5,0.6,0.7,0.8,0.9,1), "alpha" = c(1,2.5,5,10,15,20))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha)

# COLOR-SUFFICIENT SCENARIO 

## English

english_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_cs, utterances_eng_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

english_sizeOvermodification$language <- "English"

## Spanish-split

sp_split_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_split, states_cs, utterances_sp_split_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_split_sizeOvermodification$language <- "Spanish\n-split"

## Spanish-conj

sp_conj_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_conj, states_cs, utterances_sp_conj_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_conj_sizeOvermodification$language <- "Spanish\n-postnom.\n-conj."

## Spanish-postnom.

sp_postnom_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_postnom, states_cs, utterances_sp_postnom_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_postnom_sizeOvermodification$language <- "Spanish\n-postnom."

sizeOvermodification <- rbind(english_sizeOvermodification, rbind(sp_split_sizeOvermodification,rbind(sp_conj_sizeOvermodification,sp_postnom_sizeOvermodification)))

# SIZE-SUFFICIENT SCENARIO 

## English

english_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_ss, utterances_eng_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

english_colorOvermodification$language <- "English"

## Spanish-split

sp_split_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_split, states_ss, utterances_sp_split_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_split_colorOvermodification$language <- "Spanish\n-split"

## Spanish-conj

sp_conj_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_conj, states_ss, utterances_sp_conj_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_conj_colorOvermodification$language <- "Spanish\n-postnom.\n-conj."

## Spanish-postnom.

sp_postnom_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp_postnom, states_ss, utterances_sp_postnom_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0))

sp_postnom_colorOvermodification$language <- "Spanish\n-postnom."

colorOvermodification <- rbind(english_colorOvermodification, rbind(sp_split_colorOvermodification,rbind(sp_conj_colorOvermodification,sp_postnom_colorOvermodification)))

# PREDICTIONS PLOTS

plot <- function(probDF) {
  probDF$speakerProb <- as.numeric(probDF$speakerProb)
  p <- ggplot(probDF, aes(x=sizeNoise,y=colorNoise,color=speakerProb)) +
    geom_point(size=5,shape=15) +
    scale_x_continuous(limits=c(.45,1.0),breaks=seq(.475,1.0,.525),labels=c(0.5,1)) +
    scale_y_continuous(limits=c(.45,1.0),breaks=seq(.475,1.0,.525),labels=c(0.5,1)) +
    scale_colour_viridis(limits=c(0,1), name="Probability of\nutterance") +
    facet_grid(alpha~language) +
    xlab("Semantic value of size") +
    ylab("Semantic value of color") +
    theme(panel.spacing=unit(.25, "lines"),
          panel.border = element_rect(color = "black", fill = NA, size = 1),
          # axis.text.x = element_text(angle = 20, hjust=1),
          axis.text.y = element_text(hjust=0.5)) +
    xlab(element_blank()) +
    ylab(element_blank())
  return(p)
}

color_plot <- plot(colorOvermodification) + 
  theme(strip.text.y = element_blank(),
        legend.position = "none") +
  ggtitle("Redundant color modification")

size_plot <- plot(sizeOvermodification) +
  theme(axis.text.y = element_blank(), 
        axis.ticks.y = element_blank(),
        legend.position = "none") +
  ylab(element_blank()) +
  ggtitle("Redundant size modification")

legend <- plot_grid(get_legend(color_plot + theme(legend.position = "right")))

graphs <- arrangeGrob(grobs = list(color_plot, size_plot), ncol = 2, bottom = 'Semantic value of size', left = 'Semantic value of color', right = 'Alpha')

g <- arrangeGrob(graphs, legend, ncol = 2, widths = c(0.85, 0.15))

ggsave(g, filename = "scilpreds.pdf", height = 4, width = 8, units = "in", dpi = 1000)

### SCIL MODEL COMPARISON

base = 6
expand = 3

graph <- function(probArray) {
  
  toGraph <- data.frame(matrix(NA, nrow = 4, ncol = 3))
  colnames(toGraph) <- c("language", "behavior", "probability")
  toGraph$language <- c("English", "English", "Spanish-postnom.", "Spanish-postnom.")
  # toGraph$behavior <- c("Redundant color adjective (SS)", "Redundant size adjective (CS)", 
                        # "Redundant color adjective (SS)", "Redundant size adjective (CS)")
  # LABELS FOR POSTER
  toGraph$behavior <- c("Redundant color adjective", "Redundant size adjective", 
                        "Redundant color adjective", "Redundant size adjective") 
  toGraph$probability <- probArray
  
  p <- ggplot(toGraph, aes(x=language, y=probability, fill = behavior)) +
    theme_bw() +
    theme(text = element_text(size = base * expand / 2, face = "bold")) +
    ylab(element_blank()) +
    xlab(element_blank()) +
    geom_bar(stat="identity",position = "dodge") +
    # scale_fill_viridis(discrete = TRUE) +
    # color for the poster
    scale_fill_manual(values=c("#4287f5","#fff200")) +
    # for hypothetical graphs
    theme(legend.title = element_blank(), legend.position="none", # axis.text.x = element_blank(),
          axis.text.x = element_text(angle = 20, hjust=1),
    )
  
  return(p)
  
}

globalalpha <- 30 #30
incalpha <- 7
sizeCost <- 0.1
colorCost <- 0.1

cmd_eng_global <- 'Math.exp(globalUtteranceSpeaker("smallblue", model, params, semantics).score("START small blue pin STOP"))'
cmd_sp_postnom_global <- 'Math.exp(globalUtteranceSpeaker("smallblue", model, params, semantics).score("START pin blue small STOP"))'

cmd_eng_inc <- cmd_eng
cmd_sp_postnom_inc <- cmd_sp_postnom

## standard RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_ss, utterances_eng_ss, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))
  
v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_cs, utterances_eng_cs, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_ss, utterances_sp_postnom_ss, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global,states_cs, utterances_sp_postnom_cs, globalalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

standardGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Standard RSA")

## continuous RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_ss, utterances_eng_ss, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_cs, utterances_eng_cs, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_ss, utterances_sp_postnom_ss, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_cs, utterances_sp_postnom_cs, globalalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0))

crsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous RSA")

## inc RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_cs, utterances_eng_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_ss, utterances_sp_postnom_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

incGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Incremental RSA")

## continuous inc RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_cs, utterances_eng_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95,  
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_ss, utterances_sp_postnom_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95,  
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0))

cincrsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous\n-incremental RSA") 

graphs <- arrangeGrob(grobs = list(standardGraph,crsaGraph,incGraph,cincrsaGraph), ncol = 2, left = 'Probability of utterance')
legend <- plot_grid(get_legend(standardGraph + theme(legend.position = "bottom")))

g <- arrangeGrob(graphs, legend, ncol = 1, heights=c(0.9, 0.1))

ggsave(g, file = "modelcomparison_poster.pdf", height = 4, width = 4, units = "in", dpi = 1000)

cincrsaGraph + theme(legend.position = "bottom")

# TRANSITIONAL PROBABILITIES (FIGURE 3 OF PAPER)

# CI-RSA ENGLISH (SS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
                    colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","small"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","big"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

# CI-RSA SPANISH (CS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","blue"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","red"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

# I-RSA ENGLISH (SS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","small"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","big"], "smallblue", model, params, semantics)', states_ss, utterances_eng_ss, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

# I-RSA SPANISH (CS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","blue"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","pin","red"], "smallblue", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, sizeNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0)
