setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(mongolite)
library(tidyverse)
library(jsonlite)
theme_set(theme_bw())

source("../_shared/regressionHelpers.R")
source("../_shared/preprocessingHelpers.R")

# Step 1: read in raw game data

## Option (a): read in the rounds and player info info from the Mongo database

### mongoCreds contains the API key to the Mongo database (ask Brandon for credentials)
mongoCreds <- readLines("../../api_keys/mongo")

### 'Players' tells you which players played which games

players <- getPlayerGamePairs(c("Lana","Vlada"),mongoCreds)

### 'Rounds' contains the by-trial info for the games played by the players

d <- getRoundData(players$gameId,mongoCreds)

## Option (b): Read in the raw data from .rds (rather than querying database)

d <- readRDS("../../data/BCSPilot/rawData.rds")

## Cache the raw data before transforming (optional)

rawD <- d

# Step 2: get player demographic data 

## Option (a): query the database 

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

## Option (b): read in the raw data from .rds (rather than querying the database)

player_info <- readRDS("../../data/BCSPilot/rawPlayerInfo.rds")

# Step 3: do (demographic) exclusions

## Option (a): (Manually) list games that include players who are excluded by virtue of debrief survey responses

excludeGames_demographic <- c()

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

## Option (b): If list of excluded games is saved locally, read in the list (TODO)

# Step 4: massage the data into something that looks like Degen et al.'s raw format

d <- transformDataDegen2020Raw(d)

# Step 5: exclude games where accuracy is less than < 0.7 (and, optionally, plot by-game accuracy)

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "BCS Speakers")

# Step 6 (optional): plot accuracy by trial type 

plotAccuracyByTrialType(d)

# Step 7: automatically annotate dataset 

# TODO: finish these lists
colorTerms <- ""
sizeTerms <- ""
nouns <- ""
bleachedNouns <- ""
articles <- ""

d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, articles)

# Step 8: Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../data/BCSPilot/preManualTypoCorrection.tsv", delim="\t")

# Step 9: Read manually corrected dataset for further preprocessing
# Make sure file being read in is *post* manual correction ('pre' just for testing)
d <- read_delim("../../data/BCSPilot/preManualTypoCorrection.tsv", delim = "\t") %>%
  filter(grepl("color|size", condition)) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 2),
         clickedSize = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 3))

# How many trials were automatically labelled as mentioning a pre-coded level of reference?
auto_trials = sum(d$automaticallyLabelledTrial)
print(paste("percentage of automatically labelled trials: ", auto_trials*100/colsizerows)) # 95.7 in Degen 2020

# How many trials were manually labelled as mentioning a pre-coded level of reference? (overlooked by grep search due to typos or grammatical modification of the expression)
manu_trials = sum(d$manuallyAddedTrials)
print(paste("percentage of manually added trials: ", manu_trials*100/colsizerows)) # 1.9 in Degen 2020

# How often were articles omitted?
no_article_trials = colsizerows - sum(d$theMentioned)
print(paste("percentage trials where articles were omitted: ", no_article_trials*100/colsizerows)) # 71.6 in Degen 2020

# How often were nouns omitted?
d$article_mentioned = ifelse(d$oneMentioned == TRUE | d$theMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$article_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) # 88.6 in Degen 2020

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) # 1.5 in Degen 2020

# How many unique pairs?
length(unique(d$gameId)) # 64

# Step 10: final transformations on data for regression analyses and BDA 

destinationFolder <- "../../data/BCSPilot"
produceBDAandRegressionData(d, destinationFolder = destinationFolder)
