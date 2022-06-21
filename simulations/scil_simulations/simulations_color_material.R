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

source("../models/bottles/simulationHelpers.R")

# SOURCE THE ENGINE

engine <- read_file("../models/bottles/engine.txt")

modelAndSemantics <- read_file("../models/bottles/modelAndSemantics.txt")

# STATES

states_cs = c("plasticblue", "glassblue", "plasticgreen")
states_ms = c("glassgreen", "glassblue", "plasticgreen")

# UTTERANCES: material SUFFICIENT

utterances_eng_ms <- c("START green bottle STOP", "START blue bottle STOP", 
                       "START glass bottle STOP", "START plastic bottle STOP",
                       "START green glass bottle STOP", 
                       "START blue glass bottle STOP",
                       "START green plastic bottle STOP") 

utterances_sp_postnom_ms <- c("START bottle green STOP", "START bottle blue STOP", 
                              "START bottle glass STOP", "START bottle plastic STOP",
                              "START bottle glass green STOP",
                              "START bottle glass blue STOP",
                              "START bottle plastic green STOP")

# UTTERANCES: COLOR SUFFICIENT

utterances_eng_cs <- c("START green bottle STOP", "START blue bottle STOP", 
                       "START glass bottle STOP", "START plastic bottle STOP",
                       "START blue plastic bottle STOP", 
                       "START blue glass bottle STOP",
                       "START green plastic bottle STOP")


utterances_sp_postnom_cs <- c("START bottle green STOP", "START bottle blue STOP", 
                              "START bottle glass STOP", "START bottle plastic STOP",
                              "START bottle plastic blue STOP",
                              "START bottle glass blue STOP",
                              "START bottle plastic green STOP")


# COMMANDS

cmd_eng = 'incrementalUtteranceSpeaker("START green plastic bottle STOP", "plasticgreen", model, params, semantics)'
cmd_sp_postnom = 'incrementalUtteranceSpeaker("START bottle plastic green STOP", "plasticgreen", model, params, semantics)'

### SCIL MODEL COMPARISON

base = 6
expand = 3

graph <- function(probArray) {
  
  toGraph <- data.frame(matrix(NA, nrow = 4, ncol = 3))
  colnames(toGraph) <- c("language", "behavior", "probability")
  toGraph$language <- c("English", "English", "Spanish-postnom.", "Spanish-postnom.")

  # LABELS FOR POSTER
  toGraph$behavior <- c("Redundant color adjective", "Redundant material adjective", 
                        "Redundant color adjective", "Redundant material adjective") 
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
materialCost <- 0.1
colorCost <- 0.1

cmd_eng_global <- 'Math.exp(globalUtteranceSpeaker("plasticgreen", model, params, semantics).score("START green plastic bottle STOP"))'
cmd_sp_postnom_global <- 'Math.exp(globalUtteranceSpeaker("plasticgreen", model, params, semantics).score("START bottle plastic green STOP"))'

cmd_eng_inc <- cmd_eng
cmd_sp_postnom_inc <- cmd_sp_postnom

## standard RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_ms, utterances_eng_ms, globalalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, materialCost = 0, nounCost = 0))
  
v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_cs, utterances_eng_cs, globalalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_ms, utterances_sp_postnom_ms, globalalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global,states_cs, utterances_sp_postnom_cs, globalalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

standardGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Standard RSA")

## continuous RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_ms, utterances_eng_ms, globalalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_global, states_cs, utterances_eng_cs, globalalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_ms, utterances_sp_postnom_ms, globalalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_global, states_cs, utterances_sp_postnom_cs, globalalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = 0, materialCost = 0, nounCost = 0))

crsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous RSA")

## inc RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_cs, utterances_eng_cs, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_ms, utterances_sp_postnom_ms, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

incGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Incremental RSA")

## continuous inc RSA

v1 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

v2 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_eng_inc, states_cs, utterances_eng_cs, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95,  
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

v3 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_ms, utterances_sp_postnom_ms, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95,  
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

v4 <- as.numeric(runModel('V8', engine, modelAndSemantics, cmd_sp_postnom_inc, states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
                          colorCost = colorCost, materialCost = materialCost, nounCost = 0))

cincrsaGraph <- graph(c(v1,v2,v3,v4)) + ggtitle("Continuous\n-incremental RSA") 

graphs <- arrangeGrob(grobs = list(standardGraph,crsaGraph,incGraph,cincrsaGraph), ncol = 2, left = 'Probability of utterance')
legend <- plot_grid(get_legend(standardGraph + theme(legend.position = "bottom")))

g <- arrangeGrob(graphs, legend, ncol = 1, heights=c(0.9, 0.1))

ggsave(g, file = "modelcomparison_material.pdf", height = 4, width = 4, units = "in", dpi = 1000)

cincrsaGraph + theme(legend.position = "bottom")

# TRANSITIONAL PROBABILITIES (FIGURE 3 OF PAPER)

# CI-RSA ENGLISH (MS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","green"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","green", "plastic"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","blue"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

# CI-RSA SPANISH (CS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","bottle"], "plasticgreen", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","bottle","plastic"], "plasticgreen", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","bottle","glass"], "plasticgreen", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 0.8, colorNoiseVal = 0.95, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

# I-RSA ENGLISH (MS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","green"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","green", "plastic"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","blue"], "plasticgreen", model, params, semantics)', states_ms, utterances_eng_ms, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

# I-RSA SPANISH (CS SCENE)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","bottle"], "plasticgreen", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","bottle","plastic"], "plasticgreen", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)

runModel('V8', engine, modelAndSemantics, 
         'wordSpeaker(["START","bottle","glass"], "plasticgreen", model, params, semantics)', states_cs, utterances_sp_postnom_cs, incalpha, materialNoiseVal = 1, colorNoiseVal = 1, 
         colorCost = colorCost, materialCost = materialCost, nounCost = 0)
