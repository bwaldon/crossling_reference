setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(mongolite)
library(tidyverse)
library(jsonlite)
theme_set(theme_bw())

source("../../../../_shared/regressionHelpers.R")
source("angPreprocessingHelpers.R")

#This file tells us whether to take the director's first or second utterance - this script presupposes their
#referring expression is found in one of those two options
whichUtt <- read.csv("../data_input/Pilot_messages.csv")

# Step 1: read in raw game data

## Option (a): read in the rounds and player info info from the Mongo database

### mongoCreds contains the API key to the Mongo database (ask Brandon for credentials)
mongoCreds <- readLines("../../../../../api_keys/mongo")

### 'Rounds' contains the by-trial info for the games played by the players

d <- getRoundData_byLanguage("French",mongoCreds) %>%
   filter(createdAt > "2022-08-15 13:00:00")
  #filter(updatedAt > "2022-3-31 00:00:00")

saveRDS(d, file = "../../../../../data/FRENCH/nounInformative/pilot/rawData.rds")

## Option (b): Read in the raw data from .rds (rather than querying database)
## For pipelining: read in data from 2-person pilot

d <- readRDS("../../../../../data/FRENCH/nounInformative/pilot/rawData.rds")

## Cache the raw data before transforming (optional)

rawD <- d

# Step 2: get player demographic data 

## Option (a): query the database 

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

saveRDS(player_info, file = "../../../../../data/FRENCH/nounInformative/pilot/rawPlayerInfo.rds")

## Option (b): read in the raw data from .rds (rather than querying the database)

player_info <- readRDS("../../../../../data/FRENCH/nounInformative/pilot/rawPlayerInfo.rds")

# Step 3: do (demographic) exclusions

## Option (a): (Manually) list games that include players who are excluded by virtue of debrief survey responses

excludeGames_demographic <- c()

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))
  
## exclude dummy game(s) w/ no input
d <- d %>%
  filter(gameId != "NwHGSTNzWeGE6ubN3")

# Step 4: massage the data into something that looks like Degen et al.'s raw format

d <- transformDataDegen2020Raw(d)

# Step 5: exclude games where accuracy is less than < 0.7 (and, optionally, plot by-game accuracy)

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "French Speakers")

# Step 6 (optional): plot accuracy by trial type 

plotAccuracyByTrialType(d)


# Step 7: automatically annotate dataset 

colorTerms <- "noir|noire|bleu|bleue|vert|verte|blanc|blanche|gris|grise|orange|rose|violet|violette|rouge|beige|jaune|marron|marronne|mauve|clair|claire|fonce|foncee"
nouns <- "phone|mouchoir|avion|velo|peigne|fauteuil|ballon|lit|bonbon|sceau|papillon|gateau|gâteau|calendrier|cintre|coussin|de|dé|tambour|poisson|cadre|marteau|couteau|rouge a levres|rouge à levres|cadenas|masque|microscope|crayon|phone|telephone|téléphone|cadeau|piano|sifflet|siffle|telecom|camion|vase|interrupteur|cocquillage|robot|rasoir|tapis|tournevis|fourchette|cle|telecommande|télécommande|ceinture|bougie|calculette|calcul|calculatrice|casquette|chaise|horloge|reveil|réveil|alarme|couronne|cravate|tente|cuillere|cuillère|chaussette|pelle|echarpe|écharpe|late|regle|règle|bague|boule|serviette|tasse|souris|lampe|poele|poêle|fleur|guitare|robe|porte|boule|loupe|agraffeuse|louche"
bleachedNouns = ""
articles <- "le|les|la|l"
sizeTerms <- "petite|grande|grand|petit|plus grand|plus petit|plus grande|plus petite|gros|grosse|plus gros|plus gros"

d <- cbind(d, whichUtt)
d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, articles)

# Step 8: Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../../../../data/FRENCH/nounInformative/pilot/preManualTypoCorrection_part2.tsv", delim="\t")
#view(d_preManualTypoCorrection[-c(1:12,16:18,20)])
fix_typos <- function(d){
  d$directorFirstMessage<-str_replace_all(d$directorFirstMessage,"cuiellere","cuillere")
  d$directorSecondMessage<-str_replace_all(d$directorSecondMessage,"cuiellere","cuillere")
  d$directorFirstMessage<-str_replace_all(d$directorFirstMessage,"interupteur","interrupteur")
  d$directorSecondMessage<-str_replace_all(d$directorSecondMessage,"interupteur","interrupteur")
  d$directorFirstMessage<-str_replace_all(d$directorFirstMessage,"telehpone","telephone")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"telehpone","telephone")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"seau","sceau")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"seau","sceau")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"chausette","chaussette")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"chausette","chaussette")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"sifle","siffle")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"sifle","siffle")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"souri\\b","souris")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"souri\\b","souris")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"guitar\\b","guitare")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"guitar\\b","guitare")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"alarm\\b","alarme")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"alarm\\b","alarme")
  d$directorFirstMessage=str_replace_all(d$directorFirstMessage,"razoir","rasoir")
  d$directorSecondMessage=str_replace_all(d$directorSecondMessage,"razoir","rasoir")
  return(d)
}

d_postTypo <- fix_typos(d_preManualTypoCorrection)
d_postTypo <- automaticAnnotate(d_postTypo, colorTerms, sizeTerms, nouns, bleachedNouns, articles)
# Step 9: Read manually corrected dataset for further preprocessing
# Make sure file being read in is *post* manual correction ('pre' just for testing)

d <- d_postTypo %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 2),
         clickedType = map(clickedFeatures, pluck, 3),
          clickedSize = map(clickedFeatures, pluck, 1))
colsizerows <- nrow(d)

# How many trials were automatically labelled as mentioning a pre-coded level of reference?
auto_trials = sum(d$automaticallyLabelledTrial)
print(paste("percentage of automatically labelled trials: ", auto_trials*100/colsizerows)) # 95.7 in Degen 2020

# How many trials were manually labelled as mentioning a pre-coded level of reference? (overlooked by grep search due to typos or grammatical modification of the expression)
manu_trials = sum(d$manuallyAddedTrials)
print(paste("percentage of manually added trials: ", manu_trials*100/colsizerows)) # 1.9 in Degen 2020

# How often were articles omitted?
d$article_mentioned = ifelse(d$oneMentioned == TRUE | d$theMentioned == TRUE, 1, 0)
no_article_trials = colsizerows - sum(d$article_mentioned)
print(paste("percentage trials where articles were omitted: ", no_article_trials*100/colsizerows)) # 71.6 in Degen 2020

# How often were nouns omitted?
no_noun_trials = colsizerows -sum(d$typeMentioned)
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

d_dummy$colorMentioned <- as.logical(sample(x = c("TRUE|FALSE"), size = nrow(d_dummy), replace = TRUE))
d_dummy$sizeMentioned <- as.logical(sample(x = c("TRUE|FALSE"), size = nrow(d_dummy), replace = TRUE))

produceBDAandRegressionData(d_dummy, destinationFolder = destinationFolder)

# Step 10: final transformations on data for regression analyses and BDA 

destinationFolder <- "../../../../../data/FRENCH/nounInformative/pilot/"
produceBDAandRegressionData(d, destinationFolder = destinationFolder)
