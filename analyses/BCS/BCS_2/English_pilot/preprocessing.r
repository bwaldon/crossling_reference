setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(mongolite)
library(tidyverse)
library(jsonlite)
theme_set(theme_bw())

source("../../_shared/regressionHelpers.R")
source("../../_shared/preprocessingHelpers.R")

#############
# Read in Raw Data
#############

# mongoCreds contains the API key to the Mongo database (ask Brandon for credentials)
mongoCreds <- readLines("../../../api_keys/mongo")

#'Rounds' contains the by-trial info for the games played by the players
d <- getRoundData_byLanguage("English",mongoCreds)

# Get prolific IDs
con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))
rm(con)


players <- playerEmailAddresses %>%
  unnest(cols = c(urlParams, exitStepsDone, data, lastLogin)) %>%
  filter(batchGroupName == "BCSEng2Pilot") %>%
  select(id) %>%
  unique()


playerEmailAddresses <- playerEmailAddresses %>%
  filter(id %in% players$id)

# Cache the raw data before transforming
rawD <- d

#############
# Player Demographics
#############

# query the database 
player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds) 

playerIds <- playerEmailAddresses %>%
  unnest(cols = c(urlParams, exitStepsDone, data, lastLogin)) %>%
  select(avatar) %>%
  mutate(id = str_remove(avatar, "/avatars/jdenticon/")) %>%
  select(id) %>%
  unique()

player_info <- player_info %>%
  filter(playerId %in% playerIds$id)
  

# Exclude participants
excludeGames_demographic <- c("NQ3rTtjLe9WXseqjv") # no participants to exclude

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

gameIds <- playerEmailAddresses %>%
  unnest(cols = c(urlParams, exitStepsDone, data, lastLogin)) %>%
  select(gameId) %>%
  unique()


d <- d %>%
  filter(gameId %in% gameIds$gameId)
  

#############
# Wrangle the data
#############

# Get rid of following rows since no data was recorded (a glitch)
d <- transformDataDegen2020Raw(d)

# #############
# # Accuracy Exclusions
# #############

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "English Participants")

#############
# Plot
#############

plotAccuracyByTrialType(d)

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

# We don't have articles, but we do have demonstratives. I assume these demonstratives will only appear
# with missing nouns, and make something comparable to a bleached noun construction: That blue --> the blue one
demonstratives <- "the|a"

sizeTerms <- "big|small"

# There are no bleached nouns in BCS
bleachedNouns <- "one"

d$directorFirstMessage <- as.character(d$directorFirstMessage)

d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, demonstratives)

allCriticalTargets <- d_preManualTypoCorrection %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))
  
allCriticalTargets <- allCriticalTargets[,3]$name

allCriticalTargets <- unlist(strsplit(allCriticalTargets, split = "_"))
remove <- c("blue", "red", "yellow", "white", "black", "orange", "purple", "green")
allCriticalTargets <- allCriticalTargets[! allCriticalTargets %in% remove]

d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  add_column(gender = NA)

# only get target trials
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))

#############
# Save the annotations
#############
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../../data/BCS/BCS2EngPilot/preManualTypoCorrection.tsv", delim="\t")

#############
# I fixed the annotations manually in excel
#############

#############
# Upload manual annotations
#############


d <- read_delim("../../../data/BCS/BCS2EngPilot/postManualTypoCorrection.tsv", delim = "\t") %>%
  filter(!(grepl("ENGLISH", words))) %>%
  mutate(colorMentioned = case_when(grepl("C",words) ~ TRUE,
                                    TRUE ~ FALSE),
         sizeMentioned = case_when(grepl("S",words) ~ TRUE,
                                   TRUE ~ FALSE),
         typeMentioned = case_when(grepl("N",words) ~ TRUE,
                                   TRUE ~ FALSE),
         oneMentioned = case_when(grepl("B",words) ~ TRUE,
                                  TRUE ~ FALSE),
         theMentioned = case_when(grepl("A",words) ~ TRUE,
                                  TRUE ~ FALSE)) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 2),
         clickedSize = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 3))
colsizerows <- nrow(d)


# add in target values
d <- d %>%
  add_column(target = allCriticalTargets)

# How often were nouns omitted?
d$noun_mentioned = ifelse(d$typeMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$noun_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# 34.4%

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 74%

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# 7.7%

# How many unique pairs?
length(unique(d$gameId)) 
# 10


#############
# Final Transformations for Regression and BDA
#############

d <- d %>%
  select(-clickedFeatures)

allclicks <- d$clickedColor
unlisted <- unlist(d$clickedColor)

d$clickedColor <- unlist(d$clickedColor)
d$clickedSize <- unlist(d$clickedSize)
d$clickedType <- unlist(d$clickedType)

# Rename columns that were mislabeled with the automatic functions
d <- d %>%
  rename(color = clickedSize, type = clickedColor)%>%
  rename(clickedColor = color, clickedType = type)

# Delete all trials that had an "other" naming mechanism
numOtherTrials <- d %>%
  filter(grepl('O', words)) %>%
  nrow()

numOtherTrials/nrow(d) #15.8% of trials contained an "other" type of referring expression

# Get rid of all of those types of trials
d <- d %>%
  filter(!grepl("O", words))

destinationFolder <- "../../../data/BCS/BCS2EngPilot"
write_delim(d, sprintf("%s/data_exp1.tsv", destinationFolder),delim="\t")

ProduceBDAandRegressionData(d, destinationFolder = destinationFolder)
