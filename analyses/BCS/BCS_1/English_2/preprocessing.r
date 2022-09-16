##################
# Stefan Pophristic
# Spring 2022
# Preprocessing script for BCS Experiment 1 English Familiar
# Crosslinguistic Reference Project
# ALPS
##################
#
# The script takes in raw data from the Mongo DB, automatically tags key words
# and saves the data file as "preManualTypoCorrection.tsv" in the data folder of
# this repo. 
#
# This file is then automatically anotated and saved as "postManualTypoCorrection.tsv"
#
# Meta-inforamtion about the data is printed in this file, and saved in the data
# folder of the repo as "data_exp1.tsv". 
#
# Please note, the original data found in the Mongo DB contains personal 
# indentifying data of participants, and is not publicly available. Therefore,
# if you are trying to run this script, skip the "Automatic Annotation" section. 

###############
###############
# Load Everything
###############
###############


setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(mongolite)
library(tidyverse)
library(jsonlite)
theme_set(theme_bw())

source("../../../_shared/regressionHelpers.R")
source("../../../_shared/preprocessingHelpers.R")

#############
# Read in Raw Data
#############

# mongoCreds contains the API key to the Mongo database (ask Brandon for credentials)
mongoCreds <- readLines("../../../../api_keys/mongo")

#'Rounds' contains the by-trial info for the games played by the players
d <- getRoundData_byLanguage("English",mongoCreds)

# Get prolific IDs
con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))

# Get data from just this experiment
playerEmailAddresses <- playerEmailAddresses %>%
  filter(urlParams["batchGroupName"] == "EngCS")

rm(con)

# Cache the raw data before transforming
rawD <- d


# exclude data from other English games
d <- d %>% 
  filter(gameId %in% unique(playerEmailAddresses$gameId))

d$gameId %>% unique() %>% length()
# 16 games total

#############
# Player Demographics
#############


# Query database to get demographic data
player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

player_info <- player_info %>%
  filter(gameId %in% playerEmailAddresses$gameId) %>%
  select(-createdAt, -gameLobbyId)

# Exclude participants
# Game Id kJnmAG85q9t6DAkBT had a participant who was colorblind
# Game Ids  nRTonYiAT4itMQrki & 6DE6pJJRpHeymGnPn had non-native English speakers

excludeGames_demographic <- c("kJnmAG85q9t6DAkBT", "nRTonYiAT4itMQrki", "6DE6pJJRpHeymGnPn")

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

d$gameId %>% unique() %>% length()
# 13 dyads 

#############
# Wrangle the data
#############

# Get rows that have no data
for (x in 1:nrow(d)) {
  if (!grepl("text", d[x,]$data$chat)) {
    print(x)
  }
}

# No missing data

d <- transformDataDegen2020Raw(d)

# #############
# # Accuracy Exclusions
# #############

preExclusionNumGames <- d %>% select(gameId) %>% unique() %>% nrow()

# Exclude games with < 0.7 accuracy
d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "English Participants")

d %>% select(gameId) %>% unique() %>% nrow() - preExclusionNumGames
# 0 games were excluded due to the accuracy criteria

#############
# Annotate Data Set
#############

# Annotate Color Terms
colorTerms <- paste("red", "yellow", "blue", "white", "black", "green", "purple", "orange", sep="|")

nouns <- paste("belt", "tie", "pencil", "butterfly", "bowl", "binoculars",
           "fence", "mask", "robot", "helicopter", "guitar", "knife", 
           "crown", "necklace", "scarf", "truck", "lock", "calculator",
           "door", "die", "fork", "drum", "phone", "basket", "comb", 
           "chair", "slipper", "bed", "ring", "hammer", "calendar", 
           "fish", "book", "ribbon", "wallet", "screwdriver", "iron", 
           "candle", "flower", "shell", "dress", "sock", "mug", "balloon",
           "microscope", "glove", "cushion", "sock", "bow", "suitcase", "calender", sep="|")

demonstratives <- "the|a"

sizeTerms <- "big|small"

bleachedNouns <- "one"

d$directorFirstMessage <- as.character(d$directorFirstMessage)

d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, demonstratives)

d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  unnest(target) %>%
  mutate(target = sub('.*_', '', name))

# only get target trials
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))

#############
# Save the annotations
#############
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../../../data/BCS/BCS_1/English_2/preManualTypoCorrection.tsv", delim="\t")


###############
###############
# Manual Annotation
###############
###############

# File was manually annotated by Stefan Pophristic

###############
###############
# Final Transformations
###############
###############

#############
# Upload manual annotations
#############
d <- read_delim("../../../../data/BCS/BCS_1/English_2/postManualTypoCorrection.tsv", delim = "\t") %>%
  select(gameId, language, condition, roundNumber, nameClickedObj, correct, words, target) %>%
  mutate(colorMentioned = case_when(grepl("C",words) ~ 1,
                                    TRUE ~ 0),
         nounMentioned = case_when(grepl("N",words) ~ 1,
                                   TRUE ~ 0),
         otherMentioned = case_when(grepl("O", words) ~ 1,
                                    TRUE ~ 0)) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2))

colsizerows <- nrow(d)

# How often were "other" refering expressions used 
other_strategy_trials = colsizerows - sum(d$nounMentioned)
print(paste("percentage of trials where other strategies were used: ", other_strategy_trials*100/colsizerows)) 
# [1] "percentage of trials where other strategies were used:  41.025641025641"

# How often were nouns omitted?
no_noun_trials = colsizerows - sum(d$nounMentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# [1] "percentage of trials where nouns were omitted:  41.025641025641"
# These are primarily due to other referring strategies (e.g. "the red thing that you put around your neck")

# How often were colors used?
print(paste("percentage of trials where colors were mentioned: ", sum(d$colorMentioned)*100/colsizerows))
# [1] "percentage of trials where colors were mentioned:  46.6346153846154"

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# [1] "1.28205128205128 % of cases of non-target choices"


# How many unique pairs?
length(unique(d$gameId)) 
# 13

#how many dyads had majority "other" referring expressions
d %>%
  group_by(gameId) %>%
  select(gameId, otherMentioned) %>%
  summarise(otherRef = sum(otherMentioned)) %>%
  mutate(percent_other = otherRef/48) %>%
  view()

#############
# Final Transformations for Regression and BDA
#############

d <- d %>%
  select(-clickedFeatures)

allclicks <- d$clickedColor
unlisted <- unlist(d$clickedColor)

d$clickedColor <- unlist(d$clickedColor)
d$clickedType <- unlist(d$clickedType)

# Delete all trials that had an "other" naming mechanism
numOtherTrials <- d %>%
  filter(grepl('O', words)) %>%
  nrow()

numOtherTrials/nrow(d) #43.36% of trials contained an "other" type of referring expression

# Get rid of all of those types of trials
d <- d %>%
  filter(!grepl("O", words))

destinationFolder <- "../../../../data/BCS/BCS_1/English_2/"
write_delim(d, sprintf("%s/data_cleaned.tsv", destinationFolder),delim="\t")

# ProduceBDAandRegressionData(d, destinationFolder = destinationFolder)

