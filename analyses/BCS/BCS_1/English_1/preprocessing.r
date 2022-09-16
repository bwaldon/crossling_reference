##################
# Stefan Pophristic
# Spring 2022
# Preprocessing script for BCS Experiment 1 English
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

###############
###############
# Automatic Annotation
###############
###############

###############
# Load in the Data
###############

# Load in Mongo DB API Key to access data base
# This step does not work unless you obtain the confidential API key from Brandon Waldon
mongoCreds <- readLines("../../../../api_keys/mongo")

# Get by-trial information for games in BCS
d <- getRoundData_byLanguage("English",mongoCreds)

# Get player email addresses for payment purposes
con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))
playerEmailAddresses <- playerEmailAddresses %>%
  filter(urlParams["batchGroupName"] == "BCSEnglishMain")
rm(con)

# Cache the raw data before transforming
rawD <- d

# exclude data from other English games
d <- d %>% 
  filter(gameId %in% unique(playerEmailAddresses$gameId))

d$gameId %>% unique() %>% length()
# 38 games total

###############
# Demographic Data
###############

# Query database to get demographic data
player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

player_info <- player_info %>%
  filter(gameId %in% playerEmailAddresses$gameId) %>%
  select(-createdAt, -gameLobbyId)

# Exclude participants
# Game Id vtYAQKseTQAPBwpwQ had a participant who was not a native English speaker
excludeGames_demographic <- c("vtYAQKseTQAPBwpwQ") # no participants to exclude

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

#############
# Wrangle the data
#############

# Get rows that have no data
for (x in 1:nrow(d)) {
  if (!grepl("text", d[x,]$data$chat)) {
    print(x)
  }
}

# Get rid of following rows since no data was recorded (a glitch)
d <- d[-c(1225),]
d <- d[-c(2354),]
d <- d %>%
  filter(!(gameId == "Gf3hcoktrwihz8vwg"))


# due to a spelling mistake, the orange_fork stimulus did not load for participants
# Exclude all trials with the "orange_fork" 
d %>% 
  filter(grepl("orange_fork", data$images)) %>% 
  nrow()
# 23 data points excluded due to this error 

toExclude <- d %>% 
  filter(grepl("orange_fork", data$images))

d <- d %>%
  filter(!(grepl("orange_fork", data$images)))

d <- transformDataDegen2020Raw(d)

#############
# Accuracy Exclusions
#############

preExclusionNumGames <- d %>% select(gameId) %>% unique() %>% nrow()

# Exclude games with < 0.7 accuracy
d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "English Participants")

d %>% select(gameId) %>% unique() %>% nrow() - preExclusionNumGames
# 0 games were excluded due to the accuracy criteria

###############
# Automatic Data Annotation
###############

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
  add_column(gender = NA) %>%
  unnest(target) %>%
  mutate(target = sub('.*_', '', name))

# only get target trials
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))

#############
# Save the annotations
#############
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-name, -id, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../../../data/BCS/BCS_1/English_1/preManualTypoCorrection.tsv", delim="\t")

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

###############
# Load in manually annotated data
###############

d <- read_delim("../../../../data/BCS/BCS_1/English_1/postManualTypoCorrection.tsv", delim = "\t") %>%
  select(gameId, language, condition, roundNumber, nameClickedObj, correct, words, target) %>%
  mutate(colorMentioned = case_when(grepl("C",words) ~ 1,
                                    TRUE ~ 0),
         nounMentioned = case_when(grepl("N",words) ~ 1,
                                   TRUE ~ 0)) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2))

colsizerows <- nrow(d)


d <- d %>%
  mutate(colorMentioned = case_when(
    grepl("C",words) ~ 1,
    TRUE ~ 0),
    nounMentioned = case_when(
      grepl("N",words) ~ 1,
      TRUE ~ 0),
    otherMethod = case_when(
      grepl("O", words) ~ 1,
      TRUE ~ 0))

# How often were nouns omitted?
d$noun_mentioned = ifelse(d$nounMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$noun_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# 23.34%
# These are primarily due to other referring strategies (e.g. "the red thing that you put around your neck")

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 51.37%

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# 0.65%

# How many unique pairs?
length(unique(d$gameId)) 
# 36

#############
# Final Transformations for Regression and BDA
#############

d <- d %>%
  select(-clickedFeatures)

allclicks <- d$clickedColor
unlisted <- unlist(d$clickedColor)

d$clickedColor <- unlist(d$clickedColor)
d$clickedType <- unlist(d$clickedType)

# How many trials had "other" naming mechanism
numOtherTrials <- d %>%
  filter(grepl('O', words)) %>%
  nrow()

numOtherTrials/nrow(d) #23% of trials contained an "other" type of referring expression

# Get rid of all of those types of trials
d <- d %>%
  filter(!grepl("O", words))

destinationFolder <- "../../../../data/BCS/BCS_1/English_1/"
write_delim(d, sprintf("%s/data_cleaned.tsv", destinationFolder),delim="\t")

# ProduceBDAandRegressionData(d, destinationFolder = destinationFolder)
