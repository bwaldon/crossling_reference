library(tidyverse)
library(rwebppl)
library(viridis)
library(grid)
library(cowplot)
library(magick)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# LOAD SPEAKER MODELS

source("../models/wpplfunctions.R")
speakermodels <- read_file("../models/speakermodels.txt")

# SANITY CHECKS

## COHN-GORDON ET AL. FIGURE 1 

cg_utterances <- c("START dress STOP", "START red dress STOP","START red object STOP")
cg_states <- c("R1","R2","R3")
cg_model <- makeModel("../models/CohnGordonetal/",cg_states, cg_utterances)
cg_sizeNoise = 1 # NO SIZE NOISE IN THE MODEL
cg_colorNoise = 1 # NO COLOR NOISE IN THE MODEL
cg_alpha = 1 

### STRING MEANINGS

stringMeanings <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('stringMeanings("%s", "%s")',
                           utterance, state))

stringMeanings$value <- 0

for(i in 1:nrow(stringMeanings)) {
  stringMeanings$value[i] <- runWebPPL(cg_model, stringMeanings$command[i], cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### GLOBAL LITERAL LISTENER

L0_UTT_probs <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('Math.exp(globalLiteralListener("%s", states).score("%s"))',
                           utterance, state))

L0_UTT_probs$probability <- 0

for(i in 1:nrow(L0_UTT_probs)) {
  L0_UTT_probs$probability[i] <- runWebPPL(cg_model, L0_UTT_probs$command[i], cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### GLOBAL UTTERANCE-LEVEL PREDICTIONS

S1_UTT_GP_probs <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('Math.exp(globalUtteranceSpeaker("%s", states, utterances).score("%s"))',
                           state, utterance))

S1_UTT_GP_probs$probability <- 0

for(i in 1:nrow(S1_UTT_GP_probs)) {
  S1_UTT_GP_probs$probability[i] <- runWebPPL(cg_model, S1_UTT_GP_probs$command[i], cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### INCREMENTAL UTTERANCE-LEVEL PREDICTIONS

S1_UTT_IP_probs <- expand.grid(state = cg_states, utterance = cg_utterances) %>%
  mutate(command = sprintf('incrementalUtteranceSpeaker("%s", "%s", states, utterances)',
                           utterance, state))

S1_UTT_IP_probs$probability <- 0

for(i in 1:nrow(S1_UTT_IP_probs)) {
  S1_UTT_IP_probs$probability[i] <- runWebPPL(cg_model, S1_UTT_IP_probs$command[i], cg_alpha, cg_sizeNoise, cg_colorNoise)
}

### INCREMENTAL RSA SPEAKER PREDICTIONS

S1_WORD_START_R1_cmd <- 'wordSpeaker(["START"], "R1", states, utterances)'
S1_WORD_START_R1 <- runWebPPL(cg_model, S1_WORD_START_R1_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_RED_R1_cmd <- 'wordSpeaker(["START", "red"], "R1", states, utterances)'
S1_WORD_RED_R1 <- runWebPPL(cg_model, S1_WORD_RED_R1_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_DRESS_R1_cmd <- 'wordSpeaker(["START", "dress"], "R1", states, utterances)'
S1_WORD_DRESS_R1 <- runWebPPL(cg_model, S1_WORD_DRESS_R1_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_START_R2_cmd <- 'wordSpeaker(["START"], "R2", states, utterances)'
S1_WORD_START_R2 <- runWebPPL(cg_model, S1_WORD_START_R2_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_RED_R2_cmd <- 'wordSpeaker(["START", "red"], "R2", states, utterances)'
S1_WORD_RED_R2 <- runWebPPL(cg_model, S1_WORD_RED_R2_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_DRESS_R2_cmd <- 'wordSpeaker(["START", "dress"], "R2", states, utterances)'
S1_WORD_DRESS_R2 <- runWebPPL(cg_model, S1_WORD_DRESS_R2_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_START_R3_cmd <- 'wordSpeaker(["START"], "R3", states, utterances)'
S1_WORD_START_R3 <- runWebPPL(cg_model, S1_WORD_START_R3_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_RED_R3_cmd <- 'wordSpeaker(["START", "red"], "R3", states, utterances)'
S1_WORD_RED_R3 <- runWebPPL(cg_model, S1_WORD_RED_R3_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

S1_WORD_DRESS_R3_cmd <- 'wordSpeaker(["START", "dress"], "R3", states, utterances)'
S1_WORD_DRESS_R3 <- runWebPPL(cg_model, S1_WORD_DRESS_R3_cmd, cg_alpha, cg_sizeNoise, cg_colorNoise)

## DEGEN ET AL. FORESTDB

d_utterances <- c("big pin", "small pin", "blue pin", "red pin", "big blue pin", "small blue pin", "big red pin")
d_states <- c("bigblue","bigred","smallblue")
d_model <- makeModel("../models/Degenetal/",d_states, d_utterances)
d_sizeNoise = 0.8 
d_colorNoise = 0.99 
d_alpha = 30 

### CONTINUOUS-SEMANTICS SPEAKER UTTERANCE PREDICTIONS

S1_C_probs <- expand.grid(state = d_states, utterance = d_utterances) %>%
  mutate(command = sprintf('Math.exp(globalUtteranceSpeaker("%s", states, utterances).score("%s"))',
                           state, utterance))

S1_C_probs$probability <- 0

for(i in 1:nrow(S1_C_probs)) {
  S1_C_probs$probability[i] <- runWebPPL(d_model, S1_C_probs$command[i], alpha = d_alpha, sizeNoise = d_sizeNoise, 
                                         colorNoise = d_colorNoise)
}

View(S1_C_probs %>% filter(state == "smallblue"))