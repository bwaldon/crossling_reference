setwd(dirname(rstudioapi::getSourceEditorContext()$path))

library(mongolite)
library(tidyverse)
library(jsonlite)
theme_set(theme_bw())

source("../../../../_shared/regressionHelpers.R")
source("./preprocessingHelpers_copy.R")

# Step 1: read in raw game data

## Option (a): read in the rounds and player info info from the Mongo database

### mongoCreds contains the API key to the Mongo database (ask Brandon for credentials)
mongoCreds <- readLines("../../../../../api_keys/mongo")

### 'Rounds' contains the by-trial info for the games played by the players

d <- getRoundData_byLanguage("English_32",mongoCreds) %>%
  filter(createdAt > "2022-08-18 13:00:00")
  #filter(updatedAt > "2022-8-15 13:30:00")

saveRDS(d, file = "../../../../../data/English2022_summer/pilot/rawData_main.rds")

# ## Option (b): Read in the raw data from .rds (rather than querying database)
# ## For pipelining: read in data from 2-person pilot

# d <- readRDS("../../data/SpanishMain/rawData.rds")

# ## Cache the raw data before transforming (optional)

rawD <- d

# # Step 2: get player demographic data

# ## Option (a): query the database

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

saveRDS(player_info, file = "../../../../../data/English2022_summer/pilot/rawPlayerInfo_main.rds")

# ## Option (b): read in the raw data from .rds (rather than querying the database)

# player_info <- readRDS("../../data/SpanishMain/rawPlayerInfo.rds")

# # Step 3: do (demographic) exclusions

# ## Option (a): (Manually) list games that include players who are excluded by virtue of debrief survey responses

# excludeGames_demographic <- c()

# d <- d %>%
#   filter(!(gameId %in% excludeGames_demographic))

# ## Option (b): If list of excluded games is saved locally, read in the list (TODO)

# # Step 4: massage the data into something that looks like Degen et al.'s raw format


d <- transformDataDegen2020Raw(d)


# # Step 5: exclude games where accuracy is less than < 0.7 (and, optionally, plot by-game accuracy)

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "English Speakers")

# # Step 6 (optional): plot accuracy by trial type

plotAccuracyByTrialType(d)

# # Step 7: automatically annotate dataset 
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "great job with the selections", "its the yellow telephone")
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "magnifying glass", "magnifyingglass")
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "yeloow", "yellow")
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "ornge", "orange")
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "pruple", "purple")
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "you did great! ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "it's ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "its ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "it is ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "sized ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, ", ", ' ')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "christmas ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "light ", '')
d$directorFirstMessage = str_replace_all(d$directorFirstMessage, "picture ", '')
d$directorFirstMessage = gsub("\\.", '', d$directorFirstMessage)

colorTerms <- paste("red", "yellow", "blue", "white", "black", "green", "purple", "orange", "silver", "brown", 
                    "gold", "little", "grey", "irange", sep="|")
nouns <- paste("fork", "key", "remote","belt","candle","calculator","cap","chair","clock","crown", "tie", "square", "padlock", "collar", "hat"
, "tent", "spoon", "sock", "shovel", "scarf", "ruler", "ring", "ornament", "napkin", "mug", "mouse", "lamp", "pan", "fry", "facemask", "mat",
"flower","guitar", "dress", "door", "billiardball", "magnifyingglass", "stapler", "ladle", "airplane", "bike", "comb", "armchair", "gift",
"balloon", "bed","candy","bucket","butterfly","cake", "calendar","coathanger","cushion", "robots", "box", "frying pan", "bug", "tv", "ladle"
,"die", "drum","fish","frame","hammer","knife","lipstick","lock","mask","microscope","pencil","phone", "magmifying glass", "sweet", "february"
,"present","piano","whistle", "truck", "vase", "switch", "shell", "robot", "razor", "rug", "screwdriver", "ball", "hanger", "strap", "towel", "fabric", 
"pillow", "seashell", "dice", "bag", "plane", "telephone", "toy", "sweet/candy", "bicycle", "cloth", "butturfly", "bauble", "triangle", 
"braclet", "scarve", "spade", "scredriver", "lightswitch", "glass", "utensil", "rectangle", "cup", "gun", sep="|")
bleachedNouns <- ""
articles <- paste("the", "a", "an", sep="|")
sizeTerms <- paste("small", "big", "smaller", "smallest", "bigger", "biggest", "larger", "medium", "large", "longer", "largest", "bulb", sep="|")

d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, articles)
d_dup <- d_preManualTypoCorrection %>%
  select(directorFirstMessage, words)


# # Step 8: Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                          select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
             "../../../../../data/English2022_summer/pilot/main_preManualTypoCorrection_part2.tsv", delim="\t")

# # Step 9: Read manually corrected dataset for further preprocessing
# # Make sure file being read in is *post* manual correction ('pre' just for testing)
d <- read_delim("../../../../../data/English2022_summer/pilot/main_preManualTypoCorrection_part2.tsv", delim = "\t") %>%
#   rbind(read_delim("../../data/SpanishMain/postManualTypoCorrection_part2.tsv", delim = "\t")) %>%
filter(grepl("color|size", condition)) %>%
filter(!(grepl("ENGLISH", words))) %>%
#   # Get accurate 'legacy' annotation columns (e.g. colorMentioned) by back-transforming from the annotation column ('words')
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
   # Looks like we collected one game too many, exclude it from analysis
#   filter(!(gameId == "5iXGA8yrtbLNsFb8x"))
colsizerows <- nrow(d)

rawD$data$condition <- gsub("_.*", "", rawD$data$condition)
rawD <- rawD %>%
  filter(!(gameId == "WmBF9voHsNSQuYHpx"))
d = mutate(d, RedundantProperty = rawD$data$condition, .after = condition)
d = mutate(d, SufficientProperty = ifelse(d$RedundantProperty == "color", "size", "color"), .before = condition)
d = mutate(d, redundant = (d$colorMentioned == T & d$RedundantProperty == "color") | (d$sizeMentioned == T & d$RedundantProperty == "size"), .after = RedundantProperty)


# # How many trials were automatically labelled as mentioning a pre-coded level of reference?
 auto_trials = sum(d$automaticallyLabelledTrial)
 print(paste("percentage of automatically labelled trials: ", auto_trials*100/colsizerows)) # 95.7 in Degen 2020

# # How many trials were manually labelled as mentioning a pre-coded level of reference? (overlooked by grep search due to typos or grammatical modification of the expression)
# manu_trials = sum(d$manuallyAddedTrials)
# print(paste("percentage of manually added trials: ", manu_trials*100/colsizerows)) # 1.9 in Degen 2020

# # How often were articles omitted?
no_article_trials = colsizerows - sum(d$theMentioned)
print(paste("percentage trials where articles were omitted: ", no_article_trials*100/colsizerows)) # 71.6 in Degen 2020

# # How often were nouns omitted?
#d$article_mentioned = ifelse(d$oneMentioned == TRUE | d$theMentioned == TRUE, 1, 0)
#no_noun_trials = colsizerows - sum(d$article_mentioned)
no_noun_trials = colsizerows - sum(d$typeMentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) # 88.6 in Degen 2020

# # In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) # 1.5 in Degen 2020

# # How many unique pairs?
length(unique(d$gameId)) # 64

# # Step 9.5 (optional:) make dummy data for testing

# d_dummy <- d %>% mutate(gameId = "Dummy1")
# d_dummy <- d_dummy %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy2")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy3")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy4")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy5")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy6")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy7")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy8")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy9")) %>%
#   full_join(d_dummy %>% mutate(gameId = "Dummy10")) 

# d_dummy$colorMentioned <- as.logical(sample(x = c("TRUE","FALSE"), size = nrow(d_dummy), replace = TRUE))
# d_dummy$sizeMentioned <- as.logical(sample(x = c("TRUE","FALSE"), size = nrow(d_dummy), replace = TRUE))

# destinationFolder <- "../../data/SpanishMain/dummy"
# produceBDAandRegressionData(d_dummy, destinationFolder = destinationFolder)

# # Step 10: final transformations on data for regression analyses and BDA 

destinationFolder <- "../../../../../data/English2022_summer/pilot/"
produceBDAandRegressionData(d, destinationFolder = destinationFolder)
