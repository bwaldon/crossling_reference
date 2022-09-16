##################
# Stefan Pophristic
# Spring 2022
# Preprocessing script for BCS Experiment 1
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
source("../../../_shared/stefanBDAFunction.R")

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
  filter(urlParams["batchGroupName"] == "BCSMain")
rm(con)

# Cache the raw data before transforming 
rawD <- d

# exclude data from other BCS games
d <- d %>% 
  filter(gameId %in% unique(playerEmailAddresses$gameId))

d$gameId %>% unique() %>% length()
# 26 games total

###############
# Demographic Data
###############

# Query database to get demographic data
player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

player_info <- player_info %>%
  filter(gameId %in% playerEmailAddresses$gameId) %>%
  select(-createdAt, -gameLobbyId)

player_info <- unnest(player_info) 
player_info <- player_info %>%
  select(-raceWhite, -raceBlack, -raceAsian, -raceNative, -raceIslander, -raceHispanic, 
         -primaryLanguageAtHome, -otherPrimaryLanguages, -otherPrimaryLanguagesSpecify,
         -whenLanguageLearned, -livedInCountry, -howManyYears, -languageMostFrequentHome, -languageMostFrequentOutside,
         -dialectArabic, -dialectArabicSpecify, -spanishVariety, -whereLive, -whereGrowUp, -spanishCommunitySpecify)

# Some participants participated in BCS_1 and BCS_2 and received the same gameID
# and avatar, merge the demographic information from both games (since we asked 
# some different quesitons in both)

player_info <- player_info %>%
  group_by(playerId) %>%
  fill(everything(), .direction = "downup") %>%
  slice(1)

# Participant 13 exited the final survey pre-maturily and provided the answers manually 
player_info[13, ] <- list("BeRi2dwdDN2PseqFN", "wmtpy4FMiWrdgopzB", "46", "zenski", "srpski", "undergrad", "yes", "stronglyAgree", "da", "chat je bio lak",
                          "za dva pitanje slika nije mogla da se vidi i samo jedno pitanje je gde je taj problem bio za sliku sto je bila u kvadratu", "ne, nemam",
                          "yes", NA, NA, "srpski", "ne samo srpski",  "srpsko-hrvatski", "beforeAfter8",
                          "srb", "English", "ekavica", "stakavski", "ca", "family", NA, NA)

# Standardize responses
player_info <- player_info %>%
  mutate(gender = case_when(
            gender == "zensok" ~ "F",
            gender == "zensko" ~ "F",
            gender == "Zenskog" ~ "F",
            gender == "zenski" ~ "F",
            gender == "Ženski" ~ "F",
            gender == "zenski pol" ~ "F",
            gender == "Z" ~ "F",
            gender == "Žena" ~ "F",
            gender == "Zensko" ~ "F",
            gender == "žensko" ~ "F",   
            gender == "Ž" ~ "F",
            gender == "muškog" ~ "M",
            gender == "Muško" ~ "M",
            gender == "Muski" ~ "M",
            gender == "Muskog" ~ "M",
            gender == "muski" ~ "M",
            gender == "muskog" ~ "M",
            gender == "Musko" ~ "M",
            gender == "M" ~ "M",
            gender == "musko" ~ "M",
            TRUE ~ "Other"),
         currentOutsideHomeLanguageBCS = case_when(
           currentOutsideHomeLanguageBCS == "engleski" ~ "English",
           currentOutsideHomeLanguageBCS == "Trenutno Engleski, inace Flamanski" ~ "Flemish",
           currentOutsideHomeLanguageBCS == "Engleski" ~ "English",
           currentOutsideHomeLanguageBCS == "Španski" ~ "Spanish",
           currentOutsideHomeLanguageBCS == "Srpski" ~ "BCS",
           currentOutsideHomeLanguageBCS == "NA" ~ "NA",
           currentOutsideHomeLanguageBCS == "njemacki" ~ "German",
           currentOutsideHomeLanguageBCS == "Spanski" ~ "Spanish",
           currentOutsideHomeLanguageBCS == "Engleski " ~ "English",
           currentOutsideHomeLanguageBCS == " " ~ "NA",
           currentOutsideHomeLanguageBCS == "Njemacki" ~ "German",
           currentOutsideHomeLanguageBCS == "Njemački" ~ "German",
           currentOutsideHomeLanguageBCS == "hrvatski" ~ "BCS",
           currentOutsideHomeLanguageBCS == "English " ~ "English",
           currentOutsideHomeLanguageBCS == "engleski, francuski" ~ "English + French"))
  



# Exclude gameId oAhCTmfuQgwZQMA6c, because one of the participants reported being colorblind
d <- d %>%
  filter(gameId != "oAhCTmfuQgwZQMA6c")

# Country in Balkans were participant spent most time
player_info %>%
  select(yugoslavCountry) %>%
  group_by(yugoslavCountry) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# yugoslavCountry       n percent
# 1 bih                 8  0.157 
# 2 hr                 18  0.353 
# 3 none                1  0.0196
# 4 srb                22  0.431 
# 5 NA                  2  0.0392



# Gender:
player_info %>%
  select(gender) %>%
  group_by(gender) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# gender     n percent
# 1 F         24   0.471
# 2 M         16   0.314
# 3 Other     11   0.216

# Dialect info 1
player_info %>%
  select(dialectOneBCS) %>%
  group_by(dialectOneBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# dialectOneBCS     n percent
# 1 ekavica          27  0.529 
# 2 ijekavica        21  0.412 
# 3 ikavica           2  0.0392
# 4 NA                1  0.0196

# Dialect info 2
player_info %>%
  select(dialectTwoBCS) %>%
  group_by(dialectTwoBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# 1 cakavski          2  0.0392
# 2 kajkavski         5  0.0980
# 3 stakavski        43  0.843 
# 4 NA                1  0.0196

# Speaker status
player_info %>%
  select(yugoslavCountryYears) %>%
  group_by(yugoslavCountryYears) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# yugoslavCountryYears     n percent
# <chr>                <int>   <dbl>
# 1 after8                   2  0.0392
# 2 before8                  1  0.0196
# 3 beforeAfter8            41  0.804 
# 4 Izaberite Opciju         1  0.0196
# 5 never                    3  0.0588
# 6 neverButVisited          2  0.0392
# 7 NA                       1  0.0196
# responses refer to question "What age range did you spend in the balkans
# "neverButVisited" --> heritage speakers that grew up abroad but spent significant time on the Balkans

# Current main language used outside of home
player_info %>%
  select(currentOutsideHomeLanguageBCS) %>%
  group_by(currentOutsideHomeLanguageBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# currentOutsideHomeLanguageBCS     n percent
# 1 BCS                               3  0.0588
# 2 English                          35  0.686 
# 3 English + French                  1  0.0196
# 4 Flemish                           1  0.0196
# 5 German                            5  0.0980
# 6 Spanish                           2  0.0392
# 7 NA                                4  0.0784


# Partner Relationship
player_info %>%
  select(relationship) %>%
  mutate(relationship = case_when(
    relationship == "da, moja cerka" ~ "family",
    TRUE ~ relationship)) %>%
  group_by(relationship) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))
# relationship         n percent
# 1 ""                 4  0.0784
# 2 "closeFriends"     2  0.0392
# 3 "family"           4  0.0784
# 4 "spouse"           3  0.0588
# 5  NA               38  0.745
# This question first appeared in the BCS_2 experiment, so most participants in this
# one did not have this question


###############
# Data Wrangling
###############

# Get rows that have no data
for (x in 1:nrow(d)) {
  if (!grepl("text", d[x,]$data$chat)) {
    print(x)
  }
}

# exclude them 
# Keep in mind that deleting 1 row will mean that the next row does not retain it's original row number
d <- d[-c(508),]

# due to a spelling mistake, the orange_fork stimulus did not load for participants
# Exclude all trials with the "orange_fork" 
d %>% 
  filter(grepl("orange_fork", data$images)) %>% 
  nrow()
# 24 data points excluded due to this error 

d <- d %>%
  filter(!(grepl("orange_fork", data$images)))

# Data transformation 
d <- transformDataDegen2020Raw(d)

preExclusionNumGames <- d %>% select(gameId) %>% unique() %>% nrow()

# Exclude games with < 0.7 accuracy
d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "BCS Speakers")

d %>% select(gameId) %>% unique() %>% nrow() - preExclusionNumGames
# 0 games were excluded due to the accuracy criteria

# Plot accuracy by trial type
plotAccuracyByTrialType(d)

# For game ZKNNpgTCwqNxcMWPf, participants used unexpected dialect words
# pinjur for fork (vilkjuska) and kacavida for screwdriver (odvijac)
# exclude trials from that game with those items
d <- d %>%
  filter(!(gameId == "ZKNNpgTCwqNxcMWPf" & roundNumber %in% c(6, 29, 59, 65)))


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

d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  add_column(gender = NA) %>%
  unnest(target) %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))

# Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-id, -images, -listenerImages, -speakerImages,
                                -chat, -colorMentioned, -sizeMentioned, -typeMentioned,
                                -oneMentioned, -theMentioned)), 
            "../../../../data/BCS/BCS_1/BCS/preManualTypoCorrection.tsv", delim="\t")

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

d <- read_delim("../../../../data/BCS/BCS_1/BCS/postManualTypoCorrection.tsv", delim = "\t") %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4")) %>%
  select(gameId, language, condition, roundNumber, name, nameClickedObj, correct, words) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2))

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

# Add a column with the target objects
d <- d %>%
  mutate(target = sub('.*_', '', name))


###############
# Get Meta Data
###############

colsizerows <- nrow(d)

# How often were nouns omitted?
d$nounMentioned = ifelse(d$nounMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$nounMentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# 10.70

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 49.2%

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# 0.26%

# How many unique pairs?
length(unique(d$gameId))
#25


###############
# Final Transformations + Export for regression
###############

# Get rid of rows with incorrect selections
d <- d %>%
  filter(correct == 1)

d$clickedColor <- unlist(d$clickedColor)
d$clickedType <- unlist(d$clickedType)

destinationFolder <- "../../../../data/BCS/BCS_1/BCS"
write_delim(d, sprintf("%s/data_cleaned.tsv", destinationFolder),delim="\t")


###############
# Transform data for BDA
###############

BDA <- d %>%
  select(gameId, roundNumber, condition, words) %>%
  rename(response = words) %>%
  add_column(game = "1_BCS") %>%
  filter(!(grepl("O", response)))

write_delim(BDA, sprintf("%s/BDA.tsv", destinationFolder),delim="\t")
# 
# 
# BDA$gameId <- as.character(BDA$gameId)
# BDA$condition <- as.character(BDA$condition)
# BDA$response <- as.character(BDA$response)
# BDA$game <- as.character(BDA$game)
# BDA$roundNumber <- as.character(BDA$roundNumber)
# 
# write.csv(d, "../../../../data/BCS/BCS_1/BCS/BDA.csv", row.names = FALSE)
# write_delim(d, sprintf("%s/BDA.csv", destinationFolder),delim="\t")


