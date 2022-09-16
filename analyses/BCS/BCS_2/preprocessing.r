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
d <- getRoundData_byLanguage("BCS",mongoCreds)

# Get prolific IDs
con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))
rm(con)


# MAKE SURE PEOPLE WHO HAVE PLAYED BEFORE AREN'T GIVEN ISSUES IN THIS 

playersProlific <- playerEmailAddresses %>%
  unnest(cols = c(urlParams, exitStepsDone, data, lastLogin)) %>%
  filter(batchGroupName == "BCS2Prolific") %>%
  filter(gameId != "ruzTXN3KFiReDSzQH") %>%
  select(id) %>%
  unique()

playersCommunity <- playerEmailAddresses %>%
  unnest(cols = c(urlParams, exitStepsDone, data, lastLogin)) %>%
  filter(batchGroupName == "BCS2Community") %>%
  filter(gameId != "ruzTXN3KFiReDSzQH") %>%
  select(id) %>%
  unique()

playerEmailAddressesProlific <- playerEmailAddresses %>%
  filter(id %in% playersProlific$id)

playerEmailAddressesCommunity <- playerEmailAddresses %>%
  filter(id %in% playersCommunity$id) %>%
  filter(!(id %in% c("StefanTestCommunity2BCS2Community", "Stefan Test BCS2COmmunity 1")))

playerEmailAddressesCommunity$id <- playerEmailAddressesCommunity$id %>%
  str_remove("BCS2Community")

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
excludeGames_demographic <- c() # no participants to exclude

# Exclude the super similar email addresses

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

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "BCS2 Participants")
# "Games remaining after exclusion: 15"
#############
# Plot
#############

plotAccuracyByTrialType(d)


player_info <- player_info %>%
  unnest(cols = c(data)) %>%
  filter(gameId %in% playerEmailAddresses$gameId)

# Country:
player_info %>%
  select(yugoslavCountry) %>%
  group_by(yugoslavCountry) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))


# Gender:
player_info %>%
  select(gender) %>%
  mutate(gender = case_when(gender %in% c("muski", "Muško", "muskog", "Muskog", "musko", "M", "muškog", "Musko", "Muski") ~ "male",
                            gender %in% c("zenski", "zenski pol", "zensko", "Zensko", "zenskog", "Zenskog", "Ženski", "Z", "Žena", "Ž", "žensko") ~ "female",
                            is.na(gender) ~ "NA",
                            gender == "" ~ "NA", 
                            TRUE ~ "other")) %>%
  group_by(gender) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))


# Dialect criterion 1
player_info %>%
  select(dialectOneBCS) %>%
  group_by(dialectOneBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))


# Dialect criterion 2
player_info %>%
  select(dialectTwoBCS) %>%
  group_by(dialectTwoBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))


# Speaker status
player_info %>%
  select(yugoslavCountryYears) %>%
  group_by(yugoslavCountryYears) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))

# responses refer to question "What age range did you spend in the balkans
# "neverButVisited" --> heritage speakers that grew up abroad but spent significant time on the Balkans

# Current main language used
player_info %>%
  select(currentOutsideHomeLanguageBCS) %>%
  mutate(currentOutsideHomeLanguageBCS = case_when(currentOutsideHomeLanguageBCS %in% c("engleski", "Engleski", "Engleski ") ~ "English",
                                                   currentOutsideHomeLanguageBCS %in% c("srpski", "hrvatski") ~ "BCS",
                                                   currentOutsideHomeLanguageBCS %in% c("Njemacki, Njemački") ~ "German",
                                                   currentOutsideHomeLanguageBCS %in% c("Spanski, Španski") ~ "Spanish",
                                                   is.na(currentOutsideHomeLanguageBCS) ~ "NA",
                                                   currentOutsideHomeLanguageBCS == "" ~ "NA",
                                                   TRUE ~ "other")) %>%
  group_by(currentOutsideHomeLanguageBCS) %>%
  count() %>%
  mutate(percent = n/nrow(player_info))


#############
# Annotate Data Set
#############

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
otherCommonSpellings <- "kajis|kamijon|kockica|klupica|zavrtac|rulavica|narukvica|ribica|digiron|taraba|pojas"

nouns <- paste(nounsCS1MLatin, nounsCS1FLatin, nounsCS1FLatinAcc, nounsCS2MLatin, nounsCS2FLatin, nounsCS2FLatinAcc, nounsCS1MCyrillic, nounsCS1FCyrillic, nounsCS1FCyrillicAcc, nounsCS2MCyrillic, nounsCS2FCyrillic, nounsCS2FCyrillicAcc, otherCommonSpellings, sep = "|")

# We don't have articles, but we do have demonstratives. I assume these demonstratives will only appear
# with missing nouns, and make something comparable to a bleached noun construction: That blue --> the blue one
demonstratives <- "ta|taj|to|te|tu|tog|ona|onaj|ono|one|oni|onu|onog"

sizeTerms <- "velika|veliki|veliko|velike|veliku|velikog|mala|mali|malo|male|malu|malog"

# There are no bleached nouns in BCS
bleachedNouns <- ""

d$directorFirstMessage <- as.character(d$directorFirstMessage)
d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, demonstratives)

d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  add_column(gender = NA)

# Add a gender column for gender annotation
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  add_column(gender = NA)

# only get target trials
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))
d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  unnest(cols = c(target)) %>%
  rename(target = name)

#############
# Save the annotations
#############
write_delim(data.frame(d_preManualTypoCorrection %>%
             select(-target, -images, -listenerImages, -speakerImages,
                    -chat)),
"../../../data/BCS/BCS2/preManualTypoCorrection.tsv", delim="\t")

#############
# I fixed the annotations manually in excel
#############

#############
# Upload manual annotations
#############


d <- read_delim("../../../data/BCS/BCS2/postManualTypoCorrection.tsv", delim = "\t") %>%
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
# d <- d %>%
#   add_column(target = allCriticalTargets)

# How often were nouns omitted?
d$noun_mentioned = ifelse(d$typeMentioned == TRUE, 1, 0)
no_noun_trials = colsizerows - sum(d$noun_mentioned)
print(paste("percentage of trials where nouns were omitted: ", no_noun_trials*100/colsizerows)) 
# 18.4%

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 60%

# In how many cases did the listener choose the wrong object?
print(paste(100*(1-(sum(d$correct)/colsizerows)),"% of cases of non-target choices")) 
# 7.7%

# How many unique pairs?
length(unique(d$gameId)) 
# 15


#############
# Final Transformations for Regression and BDA
#############

d <- d %>%
  select(-clickedFeatures)

allclicks <- d$clickedColor
unlisted <- unlist(d$clickedColor)
# 
# d$clickedColor <- unlist(d$clickedColor)
# d$clickedSize <- unlist(d$clickedSize)
# d$clickedType <- unlist(d$clickedType)

# Rename columns that were mislabeled with the automatic functions
# d <- d %>%
#   rename(color = clickedSize, type = clickedColor)%>%
#   rename(clickedColor = color, clickedType = type)

# Delete all trials that had an "other" naming mechanism
numOtherTrials <- d %>%
  filter(grepl('O', words)) %>%
  nrow()

numOtherTrials/nrow(d) #13% of trials contained an "other" type of referring expression

# Get rid of all of those types of trials
d <- d %>%
  filter(!grepl("O", words))

d <- d %>%
  select(-clickedColor, -clickedSize, -clickedType)

destinationFolder <- "../../../data/BCS/BCS2"
write_delim(d, sprintf("%s/data_exp1.tsv", destinationFolder),delim="\t")

ProduceBDAandRegressionData(d, destinationFolder = destinationFolder)
