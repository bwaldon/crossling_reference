library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# faster than RWebPPL for this particular task, only because you get a persistent js 
# environment in the background (rather than re-initializing js over and over agin)
source("../_shared/runwppl_fromweb.R")

engine <- read_file("../_shared/engine.txt")

# MODEL SEMANTICS (SHARED ACROSS SIMULATIONS)

modelAndSemantics <- read_file("models/pins/modelAndSemantics.txt")

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

cmd_eng = 'incrementalUtteranceSpeaker("START small blue pin STOP", "smallblue", model, params, semantics(params))'
cmd_sp_split = 'incrementalUtteranceSpeaker("START small pin blue STOP", "smallblue", model, params, semantics(params))'
cmd_sp_conj = 'incrementalUtteranceSpeaker("START pin blue small STOP", "smallblue", model, params, semantics(params)) + incrementalUtteranceSpeaker("START pin small blue STOP", "smallblue", model, params, semantics(params))'
cmd_sp_postnom = 'incrementalUtteranceSpeaker("START pin blue small STOP", "smallblue", model, params, semantics(params))'

# GET WEBPPL OUTPUT

modelout <- function(cmd, alpha, sizeNoiseVal, colorNoiseVal, sizeCost, colorCost, nounCost, states, utterances) {
  
  preamble <- sprintf("var params = {
    alpha : %f,
    sizeNoiseVal : %f,
    colorNoiseVal : %f,
    sizeCost : %f,
    colorCost : %f,
    nounCost : %f
    } \n
    var model = extend(model(params), \n {states : %s, utterances : %s}) 
                 ", alpha, sizeNoiseVal, colorNoiseVal, sizeCost, colorCost, nounCost, toJSON(states), toJSON(utterances))
  
  code <- paste(modelAndSemantics, preamble, engine, cmd, sep = "\n")
  
  return(evalWebPPL_V8(code))
  
}

# modelout(cmd_eng, 1, 1, 1, 0, 0, 0, states_ss, utterances_eng_ss)

# write_file(m_test, "test_model.txt")

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
  mutate(speakerProb = modelout(cmd_eng, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_cs, utterances_eng_cs))

english_sizeOvermodification$language <- "English"

## Spanish-split

sp_split_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_sp_split, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_cs, utterances_sp_split_cs))

sp_split_sizeOvermodification$language <- "Spanish\n-split"

## Spanish-conj

sp_conj_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_sp_conj, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_cs, utterances_sp_conj_cs))

sp_conj_sizeOvermodification$language <- "Spanish\n-postnom.\n-conj."

## Spanish-postnom.

sp_postnom_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_sp_postnom, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_cs, utterances_sp_postnom_cs))

sp_postnom_sizeOvermodification$language <- "Spanish\n-postnom."

sizeOvermodification <- rbind(english_sizeOvermodification, rbind(sp_split_sizeOvermodification,rbind(sp_conj_sizeOvermodification,sp_postnom_sizeOvermodification)))

# SIZE-SUFFICIENT SCENARIO 

## English

english_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_eng, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_ss, utterances_eng_ss))

english_colorOvermodification$language <- "English"

## Spanish-split

sp_split_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_sp_split, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_ss, utterances_sp_split_ss))

sp_split_colorOvermodification$language <- "Spanish\n-split"

## Spanish-conj

sp_conj_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_sp_conj, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_ss, utterances_sp_conj_ss))

sp_conj_colorOvermodification$language <- "Spanish\n-postnom.\n-conj."

## Spanish-postnom.

sp_postnom_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = modelout(cmd_sp_postnom, alpha, sizeNoise = sizeNoise, colorNoise = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0,
                                states_ss, utterances_sp_postnom_ss))

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

cmd_eng_global <- 'Math.exp(globalUtteranceSpeaker("smallblue", model, params, semantics(params)).score("START small blue pin STOP"))'
cmd_sp_postnom_global <- 'Math.exp(globalUtteranceSpeaker("smallblue", model, params, semantics(params)).score("START pin blue small STOP"))'

cmd_eng_inc <- cmd_eng
cmd_sp_postnom_inc <- cmd_sp_postnom

## standard RSA

v1 <- as.numeric(modelout(cmd_eng_global, globalalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_ss, utterances_eng_ss))
  
v2 <- as.numeric(modelout(cmd_eng_global, globalalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_cs, utterances_eng_cs))

v3 <- as.numeric(modelout(cmd_sp_postnom_global, globalalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_ss, utterances_sp_postnom_ss))

v4 <- as.numeric(modelout(cmd_sp_postnom_global, globalalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_cs, utterances_sp_postnom_cs))

standardGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Standard RSA")

## continuous RSA

v1 <- as.numeric(modelout(cmd_eng_global, globalalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_ss, utterances_eng_ss))

v2 <- as.numeric(modelout(cmd_eng_global, globalalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_cs, utterances_eng_cs))

v3 <- as.numeric(modelout(cmd_sp_postnom_global, globalalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_ss, utterances_sp_postnom_ss))

v4 <- as.numeric(modelout(cmd_sp_postnom_global, globalalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                          colorCost = 0, sizeCost = 0, nounCost = 0,
                          states_cs, utterances_sp_postnom_cs))

crsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous RSA")

## inc RSA

v1 <- as.numeric(modelout(cmd_eng_inc, incalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_ss, utterances_eng_ss))

v2 <- as.numeric(modelout(cmd_eng_inc, incalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_cs, utterances_eng_cs))

v3 <- as.numeric(modelout(cmd_sp_postnom_inc, incalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_ss, utterances_sp_postnom_ss))

v4 <- as.numeric(modelout(cmd_sp_postnom_inc, incalpha, sizeNoise = 1, colorNoise = 1, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_cs, utterances_sp_postnom_cs))

incGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Incremental RSA")

## continuous inc RSA

v1 <- as.numeric(modelout(cmd_eng_inc, incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_ss, utterances_eng_ss))

v2 <- as.numeric(modelout(cmd_eng_inc, incalpha, sizeNoise = 0.8, colorNoise = 0.95,  
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_cs, utterances_eng_cs))

v3 <- as.numeric(modelout(cmd_sp_postnom_inc, incalpha, sizeNoise = 0.8, colorNoise = 0.95,  
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_ss, utterances_sp_postnom_ss))

v4 <- as.numeric(modelout(cmd_sp_postnom_inc, incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                          colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                          states_cs, utterances_sp_postnom_cs))

cincrsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous\n-incremental RSA") 

graphs <- arrangeGrob(grobs = list(standardGraph,crsaGraph,incGraph,cincrsaGraph), ncol = 2, left = 'Probability of utterance')
legend <- plot_grid(get_legend(standardGraph + theme(legend.position = "bottom")))

g <- arrangeGrob(graphs, legend, ncol = 1, heights=c(0.9, 0.1))

ggsave(g, file = "modelcomparison_poster.pdf", height = 4, width = 4, units = "in", dpi = 1000)

cincrsaGraph + theme(legend.position = "bottom")

# TRANSITIONAL PROBABILITIES (FIGURE 3)

# CI-RSA ENGLISH (SS SCENE)

modelout('wordSpeaker(["START"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
                    colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
                    states_ss, utterances_eng_ss)

modelout('wordSpeaker(["START","small"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_ss, utterances_eng_ss)

modelout('wordSpeaker(["START","big"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_ss, utterances_eng_ss)

# CI-RSA SPANISH (CS SCENE)

modelout('wordSpeaker(["START","pin"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_cs, utterances_sp_postnom_cs)

modelout('wordSpeaker(["START","pin","blue"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_cs, utterances_sp_postnom_cs)

modelout('wordSpeaker(["START","pin","red"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 0.8, colorNoise = 0.95, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_cs, utterances_sp_postnom_cs)

# I-RSA ENGLISH (SS SCENE)

modelout('wordSpeaker(["START"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 1, colorNoise = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_ss, utterances_eng_ss)

modelout('wordSpeaker(["START","small"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 1, colorNoise = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_ss, utterances_eng_ss)

modelout('wordSpeaker(["START","big"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 1, colorNoise = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_ss, utterances_eng_ss)

# I-RSA SPANISH (CS SCENE)

modelout('wordSpeaker(["START","pin"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 1, colorNoise = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_cs, utterances_sp_postnom_cs)

modelout('wordSpeaker(["START","pin","blue"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 1, colorNoise = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_cs, utterances_sp_postnom_cs)

modelout('wordSpeaker(["START","pin","red"], "smallblue", model, params, semantics(params))', incalpha, sizeNoise = 1, colorNoise = 1, 
         colorCost = colorCost, sizeCost = sizeCost, nounCost = 0,
         states_cs, utterances_sp_postnom_cs)