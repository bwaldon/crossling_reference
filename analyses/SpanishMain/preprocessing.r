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

### 'Rounds' contains the by-trial info for the games played by the players

d <- getRoundData_byLanguage("Spanish",mongoCreds) %>%
  filter(updatedAt > "2021-12-14 00:00:00")

saveRDS(d, file = "../../data/SpanishMain/rawData.rds")

## Option (b): Read in the raw data from .rds (rather than querying database)
## For pipelining: read in data from 2-person pilot

d <- readRDS("../../data/SpanishMain/rawData.rds")

## Cache the raw data before transforming (optional)

rawD <- d

# Step 2: get player demographic data 

## Option (a): query the database 

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

saveRDS(player_info, file = "../../data/SpanishMain/rawPlayerInfo.rds")

## Option (b): read in the raw data from .rds (rather than querying the database)

player_info <- readRDS("../../data/SpanishMain/rawPlayerInfo.rds")

# Step 3: do (demographic) exclusions

## Option (a): (Manually) list games that include players who are excluded by virtue of debrief survey responses

excludeGames_demographic <- c()

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

## Option (b): If list of excluded games is saved locally, read in the list (TODO)

# Step 4: massage the data into something that looks like Degen et al.'s raw format

d <- transformDataDegen2020Raw(d)

# Step 5: exclude games where accuracy is less than < 0.7 (and, optionally, plot by-game accuracy)

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "Spanish Speakers")

# Step 6 (optional): plot accuracy by trial type 

plotAccuracyByTrialType(d)

# Step 7: automatically annotate dataset 

colorTerms <- "negro|azul|cafe|verde|gris|naranja|rosa|morado|rojo|beige|blanco|amarillo|
negra|anaranjado|morada|roja|blanca|amarilla"
nouns <- "globo|chilemorrón|cinturón|bicicleta|bola de billar|carpeta|libro|pulsera|cangilón|mariposa|vela|gorra|silla|perchero|peine|amortiguar|flor|marco|guitarra|secadora|chaqueta|servilleta|pimienta|teléfono |pelotadepingpong|piedra|alfombra|bufanda|zapato|engrapadora|tachuela|tazadeté|cepillodedientes|tortuga|pasteldebodas|hilo"
bleachedNouns <- ""
articles <- "el|la|los|las"
sizeTerms <- "pequeño|pequeña|grande|chico|chica|chiquito|chiquita"

d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, articles)

# Step 8: Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../data/ArabicMain/preManualTypoCorrection.tsv", delim="\t")

# Step 9: Read manually corrected dataset for further preprocessing
# Make sure file being read in is *post* manual correction ('pre' just for testing)
d <- read_delim("../../data/ArabicMain/preManualTypoCorrection.tsv", delim = "\t") %>%
  filter(grepl("color|size", condition)) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 2),
         clickedSize = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 3))
colsizerows <- nrow(d)

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

# Step 9.5 (optional:) make dummy data for testing

d_dummy <- d %>% mutate(gameId = "Dummy1")
d_dummy <- d_dummy %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy2")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy3")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy4")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy5")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy6")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy7")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy8")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy9")) %>%
  full_join(d_dummy %>% mutate(gameId = "Dummy10")) 

d_dummy$colorMentioned <- as.logical(sample(x = c("TRUE","FALSE"), size = nrow(d_dummy), replace = TRUE))
d_dummy$sizeMentioned <- as.logical(sample(x = c("TRUE","FALSE"), size = nrow(d_dummy), replace = TRUE))

destinationFolder <- "../../data/SpanishMain/dummy"
produceBDAandRegressionData(d_dummy, destinationFolder = destinationFolder)

# Step 10: final transformations on data for regression analyses and BDA 

destinationFolder <- "../../data/SpanishMain"
produceBDAandRegressionData(d, destinationFolder = destinationFolder)
