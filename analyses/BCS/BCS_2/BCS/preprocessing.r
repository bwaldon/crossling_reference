##################
# Stefan Pophristic
# Spring 2022
# Preprocessing script for BCS Experiment 2
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

# # Game ID 7GRCFe84BiHNuYsdQ had messages that were in a very different dialect
# # in this dialect the words for screwdriver (kacavida) and fork (pinjur) were of
# # a different gender. Get rid of trials with those two words for this game
# 
# d <- d %>%
#   filter(gameId == "7GRCFe84BiHNuYsdQ")
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
d <- getRoundData_byLanguage("BCS",mongoCreds)

# Get player email addresses for payment purposes
con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))
playerEmailAddresses <- playerEmailAddresses %>%
  filter(urlParams["batchGroupName"] == "BCS2Prolific" |
           urlParams["batchGroupName"] == "BCS2Community") %>%
  filter(!(id %in% c("StefanTestCommunity1BCS2Community", "StefanTestCommunity2BCS2Community",
                     "Stefan Test BCS2Prolific 1", "Stefan Test BCS2COmmunity 1",
                     "Stefan Test BCS2COmmunity 2", "Stefan Test BCS2Prolific 2")) )
rm(con)

# Cache the raw data before transforming 
rawD <- d

# exclude data from other BCS games
d <- d %>% 
  filter(gameId %in% unique(playerEmailAddresses$gameId))


###############
# Demographic Data
###############

# Query database to get demographic data
player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

player_info <- player_info %>%
  filter(gameId %in% playerEmailAddresses$gameId) %>%
  select(-createdAt, -gameLobbyId)

player_info <- unnest(player_info) 

# Some participants participated in BCS_1 and BCS_2 and received the same gameID
# and avatar, merge the demographic information from both games (since we asked 
# some different quesitons in both)

player_info <- player_info %>%
  group_by(playerId) %>%
  fill(everything(), .direction = "downup") %>%
  slice(1)

# Standardize responses
# Standardize responses
player_info <- player_info %>%
  mutate(gender = case_when(
    gender %in% c("zensko", "Zenski", "zenskog", "zenski", "zenski",  "Žensko",
                  "Zenskog", "Zensko ", "ženski", "žensko", "Ž", "Z", "z") ~ "F",
    gender %in% c("muškog", "muškog", "Muško", "Muskog", "M", "Musko", 
                  "musko", "m", "Muški", "muskog", "muški", "muski") ~ "M",
    gender == "" ~ "NA",
    TRUE ~ "Other"),
    language = case_when(
      language %in% c("srpski", "bosanski i engleski", "Hrvatski", "Srpski",
                      "Bosanski", "hrvatski", "sprski", "Srpski ", 
                      "srpsko-hrvatski") ~ "BCS",
      language %in% c("Srpski i Francuski", "srpski i engleski", 
                      "Bosanski/engleski") ~ "BCS + Other Language",
      language == "" ~ "NA",
      TRUE ~ "Other"),
    languageAtHomeBCS = case_when(
      languageAtHomeBCS %in% c("hrvatski", "Srpski", "Bosanski", "Hrvatski ",
                               "srpski", "hrvatsko=srpski", "Hrvatski", 
                               "Srpsko-hrvatski", "srpsko hrvatski") ~ "BCS",
      languageAtHomeBCS %in% c("bosanski i engleski ", "slovenski srpski", 
                               "Bosanski/engleski ", "srpski i slovenski") ~ "BCS + Other",
      is.na(languageAtHomeBCS) ~ "NA",
      TRUE ~ "Other"))

# Country in Balkans were participant spent most time
player_info %>%
  select(yugoslavCountry) %>%
  group_by(yugoslavCountry) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# yugoslavCountry       n percent
# 1 bih                 9  0.220 
# 2 hr                 11  0.268 
# 3 none                1  0.0244
# 4 si                  2  0.0488
# 5 srb                12  0.293 
# 6 NA                  6  0.146 


# Gender:
player_info %>%
  select(gender) %>%
  group_by(gender) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# gender     n percent
# 1 F         20  0.488 
# 2 M         20  0.488 
# 3 NA         1  0.0244

# Dialect info 1
player_info %>%
  select(dialectOneBCS) %>%
  group_by(dialectOneBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# dialectOneBCS     n percent
# 1 ekavica          16  0.390 
# 2 ijekavica        18  0.439 
# 3 ikavica           2  0.0488
# 4 other             1  0.0244
# 5 NA                4  0.0976

# Dialect info 2
player_info %>%
  select(dialectTwoBCS) %>%
  group_by(dialectTwoBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# 1 cakavski          2  0.0488
# 2 kajkavski         3  0.0732
# 3 other             1  0.0244
# 4 stakavski        29  0.707 
# 5 NA                6  0.146 

# Speaker status
player_info %>%
  select(yugoslavCountryYears) %>%
  group_by(yugoslavCountryYears) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# yugoslavCountryYears     n percent
# <chr>                <int>   <dbl>
# 1 after8                   2  0.0488
# 2 before8                  3  0.0732
# 3 beforeAfter8            26  0.634 
# 4 never                    3  0.0732
# 5 neverButVisited          2  0.0488
# 6 NA                       5  0.122 
# responses refer to question "What age range did you spend in the balkans
# "neverButVisited" --> heritage speakers that grew up abroad but spent significant time on the Balkans

# Language
player_info %>%
  select(language) %>%
  group_by(language) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# currentOutsideHomeLanguageBCS     n percent
# 1 BCS                     36  0.878 
# 2 BCS + Other Language     3  0.0732
# 3 NA                       1  0.0244
# 4 Other                    1  0.0244

# Language Growing Up
player_info %>%
  select(languageAtHomeBCS) %>%
  group_by(languageAtHomeBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# currentOutsideHomeLanguageBCS     n percent
# 1 BCS                  31  0.756 
# 2 BCS + Other           4  0.0976
# 3 NA                    5  0.122 
# 4 Other                 1  0.0244

# Partner Relationship
player_info %>%
  select(relationship) %>%
  group_by(relationship) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# relationship         n percent
# 1 ""                 4  0.0976
# 2 "closeFriends"     8  0.195 
# 3 "family"          12  0.293 
# 4 "friends"          3  0.0732
# 5 "other"            3  0.0732
# 6 "spouse"          11  0.268


# Exclude games manually
# TedrpZPEvN7mZ8rLf --> one of the participants was a non-native speaker of BCS
excludeGames_demographic <- c("TedrpZPEvN7mZ8rLf")
d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

###############
# Data Wrangling
###############

# Get rows that have no data
for (x in 1:nrow(d)) {
  if (!grepl("text", d[x,]$data$chat)) {
    print(x)
  }
}
# 71 rows don't have data, all of them are from the same game
# Something must have gone wrong, so I'll jsut exclude the game
d <- d %>%
  filter(!(gameId == "32iJc5dEvPPnpXWAS"))

# Check that no other data is missing 
# (if none missing, this loop will print nothing)
for (x in 1:nrow(d)) {
  if (!grepl("text", d[x,]$data$chat)) {
    print(x)
  }
}

# Data transformation 
d <- transformDataDegen2020Raw(d)

preExclusionNumGames <- d %>% select(gameId) %>% unique() %>% nrow()

# Exclude games with < 0.7 accuracy
d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "BCS Speakers")

d %>% select(gameId) %>% unique() %>% nrow() - preExclusionNumGames
# 0 games were excluded due to the accuracy criteria


# Game Id 7GRCFe84BiHNuYsdQ participants had non standard dialect words
# exclude trials from that game with those images (fork and screwdriver)
d <- d %>%
  filter(!(gameId == "7GRCFe84BiHNuYsdQ" & roundNumber %in% c(2, 10, 25, 33, 44, 45, 46, 54, 61, 68)))


# Plot accuracy by trial type
plotAccuracyByTrialType(d)


###############
# Automatic Data Annotation
###############

# Annotate Color Terms
redLatin <- "crvena|crvene|crven|crveni|crveno|crvenu"
redCyrillic <- "црвена|црвене|црвен|црвени|црвено|црвену"
red <- paste(redLatin, redCyrillic, sep = "|")

blueLatin <- "plava|plave|plavo|plavi|plavu|plavog|plav"
blueCyrillic <- "плава|плаве|плаво|плави|плаву|плавог|плав"
blue <- paste(blueLatin, blueCyrillic, sep = "|")

yellowLatin <- "žuta|žute|žuto|žuti|žutu|žutog|zuta|zute|zuto|zuti|zutu|zutog"
yellowCyrillic <- "жута|жуте|жуто|жути|жуту|жутог|зута|зуте|зуто|зути|зуту|зутог"
yellow <- paste(yellowLatin, yellowCyrillic, sep = "|")

whiteLatin <- "bela|bele|beo|beli|belo|belu|belog|bijela|bijele|bijeo|bijeli|bijelo|bijelu|bijelog"
whiteCyrillic <- "бела|беле|бео|бели|бело|белу|белог|бијела|бијеле|бијео|бијели|бијело|бијелу|бијелог"
white <- paste(whiteLatin, whiteCyrillic, sep = "|")

orangeLatin <- "naradžasta|narandzasta|narandjasta|narančasta|narancasta|naradžaste|narandzaste|narandjaste|narančaste|narancaste|naradžasto|narandzasto|narandjasto|narančasto|narancasto|naradžasti|narandzasti|narandjasti|narančasti|narancasti|naradžastog|narandzastog|narandjastog|narančastog|narancastog|naradžastu|narandzastu|narandjastu|narančastu|narancastu"
orangeCyrillic <- "нараџаста|нарандзаста|нарандјаста|наранчаста|наранцаста|нараџасте|нарандзасте|нарандјасте|наранчасте|наранцасте|нараџасто|нарандзасто|нарандјасто|наранчасто|наранцасто|нараџасти|нарандзасти|нарандјасти|наранчасти|наранцасти|нараџастог|нарандзастог|нарандјастог|наранчастог|наранцастог|нараџасту|нарандзасту|нарандјасту|наранчасту|наранцасту"
orange <- paste(orangeLatin, orangeCyrillic, sep = "|")

purpleLatin <- "ljubičasta|ljubicasta|ljubičasti|ljubicasti|ljubičasto|ljubicasto|ljubičaste|ljubicaste|ljubičastu|ljubicastu|ljubičastog|ljubicastog"
purpleCyrillic <- "љубичаста|љубицаста|љубичасти|љубицасти|љубичасто|љубицасто|љубичасте|љубицасте|љубичасту|љубицасту|љубичастог|љубицастог"
purple <- paste(purpleLatin, purpleCyrillic, sep = "|")

greenLatin <- "zelena|zeleni|zeleno|zelene|zelenog|zelenu"
greenCyrillic <- "зелена|зелени|зелено|зелене|зеленог|зелену"
green <- paste(greenLatin, greenCyrillic, sep = "|")

blackLatin <- "crna|crn|crni|crno|crne|crnu|crnog"
blackCyrillic <- "црна|црн|црни|црно|црне|црну|црног"
black <- paste(blackLatin, blackCyrillic, sep = "|")

colorTerms <- paste(red, blue, yellow, white, orange, purple, green, black, sep = "|")

nounsCS1MLatin <- "leptir|balon|telefon|krevet|cvet|cvijet|novčanik|novcanik|prsten|jastuk|češalj|cesalj|digitron|kalkulator|kaiš|kais|kajš|kajs|šal|sal"
nounsCS1FLatin <- "vrata|kruna|haljina|olovka|knjiga|sveća|sveca|svijeća|svijeca|pegla|stolica|ograda|maska|gitara|šolja|solja|šalica|salica|čaša|casa"
nounsCS1FLatinAcc <- "krunu|haljinu|olovku|knjigu|sveću|svecu|svijeću|svijecu|peglu|stolicu|ogradu|masku|gitaru|šolju|solju|šalicu|salicu|čašu|casu"
nounsCS2MLatin <- "kalendar|čekić|cekic|kamion|mikroskop|dvogled|dalekozor|bubanj|robot|helikopter|nož|noz|kofer|lokot|katanac|šrafciger|srafciger|odvijač|odvijac"
nounsCS2FLatin <- "kocka|riba|košara|kosara|korpa|kravata|vilica|viljuška|viljuska|rukavica|školjka|skoljka|čarapa|carapa|činija|cinija|zdela|zdjela|mašna|masna|ogrlica|papuča|papuca"
nounsCS2FLatinAcc <- "kocku|ribu|košaru|kosaru|korpu|kravatu|vilicu|viljušku|viljusku|rukavicu|školjku|skoljku|čarapu|carapu|činiju|ciniju|zdelu|zdjelu|mašnu|masnu|ogrlicu|papuču|papucu"
nounsCS1MCyrillic <- "лептир|балон|телефон|кревет|цвет|цвијет|новчаник|новцаник|прстен|јастук|цешаљ|цесаљ|дигитрон|калкулатор|каиш|каис|кајш|кајс|шал|сал"
nounsCS1FCyrillic <- "врата|круна|хаљина|оловка|књига|свећа|свеца|свијећа|свијеца|пегла|столица|ограда|маска|гитара|шоља|соља|шалица|салица|чаша|цаса"
nounsCS1FCyrillicAcc <- "врата|круну|хаљину|оловку|књигу|свећу|свијећу|пеглу|столицу|ограду|маску|гитару|шољу|шалицу|чашу"
nounsCS2MCyrillic <-"календар|чекић|цекиц|камион|микроскоп|двоглед|далекозор|бубањ|робот|хеликоптер|нож|ноз|кофер|локот|катанац|шрафцигер|срафцигер|одвијач|одвијац"
nounsCS2FCyrillicAcc <- "коцка|риба|кошара|косара|корпа|кравата|вилица|виљушка|виљуска|рукавица|шкољка|скољка|чарапа|царапа|чинија|цинија|здела|здјела|машна|масна|огрлица|папуча|папуца"
nounsCS2FCyrillic <- "коцку|рибу|кошару|корпу|кравату|вилицу|виљушку|рукавицу|шкољку|чарапу|чинију|зделу|здјелу|машну|огрлицу|папучу"

nouns <- paste(nounsCS1MLatin, nounsCS1FLatin, nounsCS1FLatinAcc, nounsCS2MLatin, nounsCS2FLatin, nounsCS2FLatinAcc, nounsCS1MCyrillic, nounsCS1FCyrillic, nounsCS1FCyrillicAcc, nounsCS2MCyrillic, nounsCS2FCyrillic, nounsCS2FCyrillicAcc, sep = "|")

# We don't have articles, but we do have demonstratives. I assume these demonstratives will only appear
# with missing nouns, and make something comparable to a bleached noun construction: That blue --> the blue one
demonstratives <- "ta|taj|to|te|tu|tog|ona|onaj|ono|one|oni|onu|onog"

sizeTerms <- "velika|veliki|veliko|velike|veliku|velikog|mala|mali|malo|male|malu|malog"

# There are no bleached nouns in BCS
bleachedNouns <- ""

# Automatic annotation function
d$directorFirstMessage <- as.character(d$directorFirstMessage)
d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, demonstratives)



# Add a column with the target objects
# allCriticalTargets <- d_preManualTypoCorrection %>%
#   filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))
# 
# allCriticalTargets <- allCriticalTargets[,3]$name
# 
# allCriticalTargets <- unlist(strsplit(allCriticalTargets, split = "_"))
# remove <- c("blue", "red", "yellow", "white", "black", "orange", "purple", "green")
# allCriticalTargets <- allCriticalTargets[! allCriticalTargets %in% remove]

# Add a column to code the gender 
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  add_column(gender = NA) %>%
  unnest(target) %>%
  mutate(target = sub('.*_', '', name))

# Save the data set for manual annotation
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-id, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../../../data/BCS/BCS_2/BCS/preManualTypoCorrection.tsv", delim="\t")


###############
###############
# Manual Annotation
###############
###############

# File was manually annotated by Stefan Pophristic

# The gender column refers to whether gender was marked on the color adjective
# The following notation was used for the gender column:
# 0: no color adjective, therefore no gender marking
# 1: color adjective + appropriate gender marking
# 2: Color adjective + gender marking, but the statement was type "other" therefore
#     gender may not refer to target object
# 3: Color adjective but no gender marking (e.g. writing "ljub." instead of "ljubicasta")
# 4: Color adjective that cannot have a gender suffix (e.g. "braun" or "lila")
# 5: Color adjective with neuter gender (no neuter nouns were included in the 
#     data set). Neuter is usually the citation form of an adjective
# 6: Color adjective with non-matching gender (e.g. blue.masc + noun.fem)

# all gender column related exclusions are done in the regression script. 

###############
###############
# Final Transformations
###############
###############

###############
# Load in manually annotated data
###############

d <- read_delim("../../../../data/BCS/BCS_2/BCS/postManualTypoCorrection.tsv", delim = "\t") %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4")) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2),
         clickedSize = rep("0", length(clickedFeatures))) %>%
  rename("target" = d_preManualTypoCorrection.target)

d <- d %>%
  mutate(colorMentioned = case_when(
      grepl("C",words) ~ TRUE,
      TRUE ~ FALSE),
    nounMentioned = case_when(
      grepl("N",words) ~ TRUE,
      TRUE ~ FALSE),
    otherMethod = case_when(
      grepl("O", words) ~ TRUE,
      TRUE ~ FALSE))


###############
# Get Meta Data
###############

colsizerows <- nrow(d)

# How often were nouns omitted?
d$noun_mentioned = ifelse(d$nounMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$noun_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# 23.73%

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 53.88%

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# 1.3%

# How many unique pairs?
length(unique(d$gameId)) # 19


###############
# Final Transformations + Export
###############

d <- d %>%
  select(-clickedFeatures)

d$clickedColor <- unlist(d$clickedColor)
d$clickedType <- unlist(d$clickedType)

destinationFolder <- "../../../../data/BCS/BCS_2/BCS/"
write_delim(d, sprintf("%s/data_cleaned.tsv", destinationFolder),delim="\t")

# BCSProduceBDAandRegressionData(d, destinationFolder = destinationFolder)
