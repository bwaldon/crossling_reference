setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(mongolite)
library(tidyverse)
library(jsonlite)
theme_set(theme_bw())

source("../_shared/regressionHelpers.R")
source("../_shared/preprocessingHelpers.R")
source("BCSPreprocessingHelpers.R")

# Step 1: read in raw game data

### mongoCreds contains the API key to the Mongo database (ask Brandon for credentials)
mongoCreds <- readLines("../../api_keys/mongo")

### 'Rounds' contains the by-trial info for the games played by the players

d <- getRoundData_byLanguage("English",mongoCreds)


# Get how long the game takes
gameLength <- d %>%
  select(gameId, updatedAt) %>%
  mutate(trial = rep(1:72, (nrow(d))/72)) %>%
  filter(trial %in% c(1, 72)) %>%
  mutate(time = as.integer(updatedAt))

averageTime <- (((1648057339-1648056737) + (1648057789-1648056979) + (1648058229-1648057163))/3)/60
# 13.7 minutes

### 'Users' contains the email addresses

con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))$id
rm(con)

## Cache the raw data before transforming (optional)

rawD <- d

# Step 2: get player demographic data 

## Option (a): query the database 

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

# Step 3: do (demographic) exclusions

## Option (a): (Manually) list games that include players who are excluded by virtue of debrief survey responses

excludeGames_demographic <- c()

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

# Step 4: massage the data into something that looks like Degen et al.'s raw format

d <- transformDataDegen2020Raw(d)

# Step 5: exclude games where accuracy is less than < 0.7 (and, optionally, plot by-game accuracy)

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "BCS Speakers")

# Step 6 (optional): plot accuracy by trial type 

plotAccuracyByTrialType(d)

# Step 7: automatically annotate dataset 

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
# Step 8: Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../data/BCSEnglishPilot/preManualTypoCorrection.tsv", delim="\t")


# kajis
#kamijon
#kockica
#klupica
# zavrtac
# rulavica
#narukvica
# ribica
# dobos
# digiron
# taraba (ograda)
#all the nouns in Accuastiave
#POJAS

# Redo this whole part
# create your own T/F functions based on the NCS type stuff
# Include gender column where you type in the gender


# Step 9: Read manually corrected dataset for further preprocessing
# Make sure file being read in is *post* manual correction ('pre' just for testing)
d <- read_delim("../../data/BCSEnglishPilot/postManualTypoCorrection.tsv", delim = "\t") %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2),
         clickedSize = rep("0", length(clickedFeatures)))

# add in target values

d <- d %>%
  add_column(target = allCriticalTargets)
colsizerows <- nrow(d)

# How many trials were automatically labelled as mentioning a pre-coded level of reference?
auto_trials = sum(d$automaticallyLabelledTrial)
print(paste("percentage of automatically labelled trials: ", auto_trials*100/colsizerows)) # 95.7 in Degen 2020

# How many trials were manually labelled as mentioning a pre-coded level of reference? (overlooked by grep search due to typos or grammatical modification of the expression)
manu_trials = sum(d$manuallyAddedTrials)
print(paste("percentage of manually added trials: ", manu_trials*100/colsizerows)) # 1.9 in Degen 2020

# How often were nouns omitted?
d$noun_mentioned = ifelse(d$typeMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$noun_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# 11.8%
# These are primarily due to other referring strategies (e.g. "the red thing that you put around your neck")

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 68.75%

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# 0%

# How many unique pairs?
length(unique(d$gameId)) # 3

# Step 10: final transformations on data for regression analyses and BDA 


d <- d %>%
  select(-clickedFeatures)

d$clickedColor <- unlist(d$clickedColor)
d$clickedType <- unlist(d$clickedType)

destinationFolder <- "../../data/BCSEnglishPilot"
write_delim(d, sprintf("%s/data_exp1.tsv", destinationFolder),delim="\t")
# 
# 
# BCSProduceBDAandRegressionData(d, destinationFolder = destinationFolder)
