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

d <- getRoundData_byLanguage("BCS",mongoCreds)


# Get how long the game takes
gameLength <- d %>%
  filter(gameId != "GdJRzt75ocCjvTmj5") %>%
  select(gameId, updatedAt) %>%
  mutate(trial = rep(1:72, (nrow(d)-72)/72)) %>%
  filter(trial %in% c(1, 72)) %>%
  mutate(time = as.integer(updatedAt))

averageTime <- (((1647802989-1647802010) + (1647813047-1647811786) + (1647888158-1647885671))/3)/60
# 26.3 minutes

### 'Users' contains the email addresses

con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))$id
rm(con)

## Cache the raw data before transforming (optional)

rawD <- d

# Step 2: get player demographic data 

## Option (a): query the database 

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)


test <- readRDS("../../data/BCSPilot/rawPlayerInfo.rds")
# Step 3: do (demographic) exclusions

## Option (a): (Manually) list games that include players who are excluded by virtue of debrief survey responses

excludeGames_demographic <- c("GdJRzt75ocCjvTmj5")

d <- d %>%
  filter(!(gameId %in% excludeGames_demographic))

# Step 4: massage the data into something that looks like Degen et al.'s raw format

d <- transformDataDegen2020Raw(d)

# Step 5: exclude games where accuracy is less than < 0.7 (and, optionally, plot by-game accuracy)

d <- accuracyExclusions(d, makeGraph = TRUE, xlab = "BCS Speakers")




# allTargets <- d_preManualTypoCorrection %>%
#   filter(condition == "NA")
# 
# df_allTargets <- data.frame()
# 
# for(x in 0:nrow(allTargets)) {
#   df_allTargets <- rbind(df_allTargets, data.frame(allTargets$images[x]))
# }
# 
# write_csv(df_allTargets, "../../data/BCSPilot/allTargets.csv")

# I didn't have the condition statement in the original code
# So i'm just pasting the conditions in here
# this will all be deleted for the final analysis, because I added it back into the code
targetConditions <- c('scenario2', 'scenario3', 'scenario3', 'scenario3', 'scenario2', 'scenario4', 'scenario2', 'scenario1', 'scenario1', 'scenario1', 'scenario1', 'scenario1', 'scenario1', 'scenario1', 'scenario2', 'scenario3', 'scenario2', 'scenario2', 'scenario1', 'scenario4', 'scenario3', 'scenario4', 'scenario3', 'scenario4', 'scenario1', 'scenario2', 'scenario1', 'scenario4', 'scenario4', 'scenario3', 'scenario3', 'scenario4', 'scenario3', 'scenario1', 'scenario4', 'scenario2', 'scenario2', 'scenario3', 'scenario4', 'scenario2', 'scenario4', 'scenario2', 'scenario1', 'scenario3', 'scenario4', 'scenario3', 'scenario2', 'scenario4', 'scenario1', 'scenario1', 'scenario2', 'scenario4', 'scenario4', 'scenario1', 'scenario2', 'scenario4', 'scenario3', 'scenario4', 'scenario3', 'scenario4', 'scenario3', 'scenario3', 'scenario1', 'scenario2', 'scenario1', 'scenario1', 'scenario2', 'scenario2', 'scenario2', 'scenario2', 'scenario4', 'scenario2', 'scenario2', 'scenario2', 'scenario4', 'scenario2', 'scenario2', 'scenario4', 'scenario1', 'scenario3', 'scenario1', 'scenario2', 'scenario4', 'scenario4', 'scenario3', 'scenario3', 'scenario4', 'scenario4', 'scenario4', 'scenario1', 'scenario3', 'scenario1', 'scenario4', 'scenario3', 'scenario2', 'scenario3', 'scenario1', 'scenario3', 'scenario2', 'scenario1', 'scenario3', 'scenario2', 'scenario1', 'scenario4', 'scenario1', 'scenario4', 'scenario3', 'scenario3', 'scenario4', 'scenario4', 'scenario1', 'scenario4', 'scenario1', 'scenario3', 'scenario2', 'scenario4', 'scenario2', 'scenario4', 'scenario4', 'scenario2', 'scenario2', 'scenario2', 'scenario1', 'scenario2', 'scenario4', 'scenario4', 'scenario4', 'scenario1', 'scenario3', 'scenario2', 'scenario3', 'scenario2', 'scenario3', 'scenario4', 'scenario4', 'scenario2', 'scenario3', 'scenario3', 'scenario2', 'scenario2', 'scenario2', 'scenario4', 'scenario1', 'scenario1')

counter = 1
for(x in 1:nrow(d)){
  if(d$condition[x] == "NA") {
    d$condition[x] <- targetConditions[counter]
    counter = counter + 1
  }
}

# Step 6 (optional): plot accuracy by trial type 

plotAccuracyByTrialType(d)

# Step 7: automatically annotate dataset 

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

d_preManualTypoCorrection <- automaticAnnotate(d, colorTerms, sizeTerms, nouns, bleachedNouns, demonstratives)


allCriticalTargets <- d_preManualTypoCorrection %>%
  filter(condition %in% c("scenario1", "scenario2", "scenario3", "scenario4"))
  
allCriticalTargets <- allCriticalTargets[,3]$name

allCriticalTargets <- unlist(strsplit(allCriticalTargets, split = "_"))
remove <- c("blue", "red", "yellow", "white", "black", "orange", "purple", "green")
allCriticalTargets <- allCriticalTargets[! allCriticalTargets %in% remove]

d_preManualTypoCorrection <- d_preManualTypoCorrection %>%
  add_column(gender = NA)

# Step 8: Write this dataset for manual correction of typos
write_delim(data.frame(d_preManualTypoCorrection %>%
                         select(-target, -images, -listenerImages, -speakerImages,
                                -chat)), 
            "../../data/BCSPilot/preManualTypoCorrection.tsv", delim="\t")


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
d <- read_delim("../../data/BCSPilot/postManualTypoCorrection.tsv", delim = "\t") %>%
  filter(condition %in% c("scenario1", "scenario2", "scenario3", "scenario4")) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2),
         clickedSize = rep("0", length(clickedFeatures)))

# add in target values

d <-d %>%
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
# 2.08%

# How often were colors used?
d$color_mentioned = ifelse(d$colorMentioned == TRUE, 1, 0)
print(paste("percentage of trials where colors were mentioned: ", sum(d$color_mentioned)*100/colsizerows))
# 22%

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

destinationFolder <- "../../data/BCSPilot"
write_delim(d, sprintf("%s/data_exp1.tsv", destinationFolder),delim="\t")
# 
# 
# BCSProduceBDAandRegressionData(d, destinationFolder = destinationFolder)
