library(tidyverse)
library(rwebppl)
library(viridis)
library(grid)
library(cowplot)
library(magick)
library(jsonlite)
library(rwebppl)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# RUN WEBPPL FROM A V8 JS ENGINE (FASTER WHEN YOU NEED TO RUN MANY, MANY CALLS TO WEBPPL)

source("../../_shared/V8wppl.R")

# SOURCE SOME HELPER SCRIPTS

source("../../_shared/simulationHelpers.R")

# SOURCE THE ENGINE

engine <- read_file("../../_shared/engine.txt")

# SANITY CHECKS

## COHN-GORDON ET AL. FIGURE 1 

cg_utterances <- c("START dress STOP", "START red dress STOP","START red object STOP")
cg_states <- c("R1","R2","R3")
cg_modelAndSemantics <- read_file("../models/CohnGordonetal/modelAndSemantics.txt")
cg_sizeNoise = 1 # NO SIZE NOISE IN THE MODEL (ALREADY A PARAMETER DEFAULT FOR 'runModel' command)
cg_colorNoise = 1 # NO COLOR NOISE IN THE MODEL (ALREADY A PARAMETER DEFAULT FOR 'runModel' command)
cg_alpha = 1 # (ALREADY A PARAMETER DEFAULT FOR 'runModel' command)

### STRING MEANINGS

cg_stringMeanings <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('stringMeanings("%s", "%s", model, semantics)',
                           utterance, state))

cg_stringMeanings$value <- 0

for(i in 1:nrow(cg_stringMeanings)) {
  cg_stringMeanings$value[i] <- runModel('V8', engine, cg_modelAndSemantics, cg_stringMeanings$command[i], cg_states,
                                       cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### GLOBAL LITERAL LISTENER

L0_UTT_probs <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('Math.exp(globalLiteralListener("%s", model, params, semantics).score("%s"))',
                           utterance, state))

L0_UTT_probs$probability <- 0

for(i in 1:nrow(L0_UTT_probs)) {
  L0_UTT_probs$probability[i] <- runModel('V8', engine, cg_modelAndSemantics, L0_UTT_probs$command[i], cg_states,
                                          cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### GLOBAL UTTERANCE-LEVEL PREDICTIONS

S1_UTT_GP_probs <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('Math.exp(globalUtteranceSpeaker("%s", model, params, semantics).score("%s"))',
                           state, utterance))

S1_UTT_GP_probs$probability <- 0

for(i in 1:nrow(S1_UTT_GP_probs)) {
  S1_UTT_GP_probs$probability[i] <- runModel('V8', engine, cg_modelAndSemantics, S1_UTT_GP_probs$command[i],  cg_states,
                                              cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### INCREMENTAL UTTERANCE-LEVEL PREDICTIONS

S1_UTT_IP_probs <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('incrementalUtteranceSpeaker("%s", "%s",  model, params, semantics)',
                           utterance, state))

S1_UTT_IP_probs$probability <- 0

for(i in 1:nrow(S1_UTT_IP_probs)) {
  S1_UTT_IP_probs$probability[i] <- runModel('V8', engine, cg_modelAndSemantics, S1_UTT_IP_probs$command[i], cg_states,
                                             cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### INCREMENTAL RSA SPEAKER PREDICTIONS

S1_WORD_START_R1_cmd <- 'wordSpeaker(["START"], "R1", model, params, semantics)'
S1_WORD_START_R1 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_START_R1_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_RED_R1_cmd <- 'wordSpeaker(["START", "red"], "R1", model, params, semantics)'
S1_WORD_RED_R1 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_RED_R1_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_DRESS_R1_cmd <- 'wordSpeaker(["START", "dress"], "R1", model, params, semantics)'
S1_WORD_DRESS_R1 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_DRESS_R1_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_START_R2_cmd <- 'wordSpeaker(["START"], "R2", model, params, semantics)'
S1_WORD_START_R2 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_START_R2_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_RED_R2_cmd <- 'wordSpeaker(["START", "red"], "R2", model, params, semantics)'
S1_WORD_RED_R2 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_RED_R2_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_DRESS_R2_cmd <- 'wordSpeaker(["START", "dress"], "R2", model, params, semantics)'
S1_WORD_DRESS_R2 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_DRESS_R2_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_START_R3_cmd <- 'wordSpeaker(["START"], "R3", model, params, semantics)'
S1_WORD_START_R3 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_START_R3_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_RED_R3_cmd <- 'wordSpeaker(["START", "red"], "R3", model, params, semantics)'
S1_WORD_RED_R3 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_RED_R3_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_DRESS_R3_cmd <- 'wordSpeaker(["START", "dress"], "R3", model, params, semantics)'
S1_WORD_DRESS_R3 <- runModel('V8', engine, cg_modelAndSemantics, S1_WORD_DRESS_R3_cmd, cg_states, cg_utterances, cg_alpha, cg_sizeNoise, cg_colorNoise)

## DEGEN ET AL. FORESTDB

d_utterances <- c("big pin", "small pin", "blue pin", "red pin", "big blue pin", "small blue pin", "big red pin")
d_states <- c("bigblue","bigred","smallblue")
d_modelAndSemantics <- read_file("../models/Degenetal/modelAndSemantics.txt")
d_sizeNoise = 0.8 
d_colorNoise = 0.99 
d_alpha = 30 

### CONTINUOUS-SEMANTICS SPEAKER UTTERANCE PREDICTIONS

S1_C_probs <- expand.grid(state = d_states, utterance = d_utterances) %>%
  mutate(command = sprintf('Math.exp(globalUtteranceSpeaker("%s", model, params, semantics).score("%s"))',
                           state, utterance))

S1_C_probs$probability <- 0

for(i in 1:nrow(S1_C_probs)) {
  S1_C_probs$probability[i] <- runModel('V8', engine, d_modelAndSemantics, S1_C_probs$command[i], d_states, d_utterances, 
                                        d_alpha, d_sizeNoise, d_colorNoise)
}

View(S1_C_probs %>% filter(state == "smallblue"))