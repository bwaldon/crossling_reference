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

d <- getRoundData_byLanguage("BCS",mongoCreds)

# # To save this data locally (so you don't need to connect to the database):
# saveRDS(d, file = "../../data/BCSPilot/rawData.rds")

### 'Users' contains the email addresses

con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
playerEmailAddresses <- (data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(unique(d$gameId))))))$id
rm(con)

## Option (b): Read in the raw data from .rds (rather than querying database)
## For pipelining: read in data from 2-person pilot

d <- readRDS("../../data/BCSPilot/rawData.rds")

## Cache the raw data before transforming (optional)

rawD <- d

# Step 2: get player demographic data 

## Option (a): query the database 

player_info <- getPlayerDemographicData(unique(d$gameId),mongoCreds)

# # To save this data locally (so you don't need to connect to the database):
# saveRDS(player_info, file = "../../data/BCSPilot/rawPlayerInfo.rds")

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

colorTerms_arabizi <- "ramadeya|ramadiya|rmede|rmedy|rmedeye|rmediyi|rmedeye|a5dar|akhdar|khadra|5adra|5adraa|banafsaji|banafsajeye|banafsajeya|mov|abyad|2abyad|2byad|2byd|bayda|byda|baydaa|aswad|2aswad|2swad|2swd|sawdaa|sawda|benne|binni|benny|bennie|binniyi|asfar|2asfar|asfr|2sfr|2sfar|safra|safraa|sfra|dahabi|dahabe|dahaby|dahabiyi|dahabeye|orange|fodde|foddeye|azra2|2azra2|2zra2|2zr2|azraa|zar2a|zaraa|zhr|zahriyi|zahreye|zahr|zaher|wardeye|ahmar|2ahmar|2hmar|ahmr|2ahmr|2hmr|27mr|27mar|2a7mar|2a7mr|a7mr|a7mar|hamraa|hamra|hamra2|7amraa|7amra|7amra2"
colorTerms_arabic_indef <- "رمادي|رمادية|أخضر|خضراء|خضرا|بنفسجي|بنفسجية|موف|أبيض|بيضاء|بيضا|أسود|سوداء|سودا|بني|بنية| زهرية|حمراء|حمرا|أصفر|صفراء|صفرا|ذهبي|ذهبية|دهبي|دهبية|برتقالي|برتقالية|فضي|فضية|أزرق|زرقاء|زرقا|وردي|وردية|زهري|أحمر"
colorTerms_arabic_indef <- gsub(" ", "", colorTerms_arabic_indef, fixed = TRUE)
colorTerms_arabic_def <- strsplit(colorTerms_arabic_indef, "|",fixed = TRUE)[[1]]
colorTerms_arabic_def <- paste("ال", colorTerms_arabic_def, sep = "")
colorTerms_arabic_def <- paste(colorTerms_arabic_def, collapse = "|")
colorTerms <- paste(colorTerms_arabizi,colorTerms_arabic_indef, colorTerms_arabic_def, sep="|")
colorTerms <- gsub(" ", "", colorTerms, fixed = TRUE)

nouns_arabizi <- "soof|souf|suf|5yout|5yoot|5yut|5itan|5eetan|5eetaan|5itaan|cake|katu|sili7fe|sol7afat|sola7fat|fersheye|forshaya|forsheye|forshat|fersheyet snen|forshayat asnan|forsheyet snen|fersheyet snan|forshayat asnan|forshat snen|forshat snan|
kebeye|kobeye|kobaya|kebeyet shay|kobeyet shay|kobayat shay|fenjen|fonjen|fonjan|makbas|dabbase|dabase|dabese|sobat|7itha2|da3ase|d3se|da3se|
sajede|sajjede|sjede|7ajra|7ajara|sa5ra|sakhra|telefon|talefon|talifon|telifon|jawwal|jawal|jawel|jawwel|hatef|haatef|filfol|folfol|filfil|filfol|flayfle|flaifle|flaifli|flayfli|zeene|zini|zeeni|zine|ma7rame|ma7rme|mandeel|mendeel|mendil|mandil|kanze|2amees|amees|2mees|2amis|amis|2mis|sotra|stra|seshwar|sishwar|sechwar|kora|tabe|taabe|tabi|birwez|berwez|berwaz|itaar|itar|etar|warde|wardi|warda|zahra|guitar|takaya|takeye|wesede|wesada|mosht|moshot|jacket|m3taf|mi3taf|me3taf|m3tf|me3tf|mi3tf|ta3li2a|ta3lee2a|te3li2a|te3lee2a|kirsi|kirse|kirsy|korse|korsy|sham3a|cham3a|farashe|farasha|satl|satel|dalw|iswara|eswara|oswara|siwar|sewar|iswaara|eswaara|oswaara|siwaar|sewaar|kitaab|kitab|kteb|malaf|milaf|darraje|darraja|7zem|7izem|7izam|ta2eye|ta2iyi|ballon|baloon|avocado|kalb|keleb|warde|wardei|wrde|wrdi|zahra|dob|dobb|deb|debb|dib|dibb|sayyara|sayara|range|7alwa|7ilo|7elo|bonbon|bonbon|kanze|kanzi|knzi|knze|2amees|2amis|2mis|2mees|nisir|nsr|3osfour|3sfour|asfoor|asfour|osfour|osfoor|babaghaa2|baba8a2|babagha2|baba8aa2|7amama|7ameme|yamama|yameme|samake|samaka|smke|samke|samak|tawle|tawla|tawela|5zene|5izana|5azne|jawareer"
nouns_arabic_indef <- "أفوكادو|بالون|قبعة|طقية|حزام|دراجة|كرة بلياردو|طابة|ملف|كتاب|سوار|اسوارة| دلو|سطل|فراشة|شمعة|كرسي|تعليقة|معطف|جاكيت|مشط|وسادة|تكاية|جيتار|زهرة|وردة|إطار|برواز|كرة جولف|كرة|مجفف شعر|سشوار|سترة|قميص|كنزة|محرمة|منديل|زينة|فلفل|فليفلة|هاتف|جوال|تلفون|تيلفون|حجرة|سجادة|دعسة|دعاسة|حذاء|صباط|دباسة| مكبس|فنجان شاي |فنجان|كباية|فرشاة أسنان|فرشاة|فرشاية|سلحفاة|سلحفة|سلحفا|كعكة زفاف|كعكة|كيكة|كيك|خيوط|خيطان|صوف|كلب|وردة|زهرة|دب|باندا|سيارة|رانج|حلوى|بونبون|بون بون|كنزة|قميص|نسر|عصفور|ببغاء|حمامة|يمامة|سمكة|سمك|طاولة|خزانة|جوارير|"
nouns_arabic_def <- strsplit(nouns_arabic_indef, "|",fixed = TRUE)[[1]]
nouns_arabic_def <- paste("ال", nouns_arabic_def, sep = "")
nouns_arabic_def <- paste(nouns_arabic_def, collapse = "|")
nouns <- paste(nouns_arabizi,nouns_arabic_def,nouns_arabic_indef,sep = "|")

bleachedNouns <- "وحدة|واحد|شي|شيء|wa7id|wa7ed|w7de|w7di|shi|we7de|we7d"
articles <- "ال"

sizeTerms_arabizi <- "kabira|kabeera|kabeer|kabir|kbeer|kbeeri|kbir|lkbir|alkabeer|kbiri|kbeere|lkbiri|s8ir|s8eer|z8ir|z8eer|zghir|sghir|zgheer|zgheer|s8iri|s8eeri|s8eere|z8iri|z8eeri|zghiri|sghiri|zgheeri|zgheeri|saghir|saghira|sagheer|sagheera|sa8ir|sa8eer|sa8ira|sa8eera|as8ar|asghar|az8ar|azghar|2asghar|2sghar|2s8ar|2s8r|akbar|2akbar|2kbar|2kbr|dakhm|dhakhem|da5m|da5em|dakhme|dhakhme|da5me|da5mi"
sizeTerms_arabic_indef <- "كبير |صغير|كبيرة |صغيرة |أكبر |أصغر |ضخم|ضخمة"
sizeTerms_arabic_indef <- gsub(" ", "", sizeTerms_arabic_indef, fixed = TRUE)
sizeTerms_arabic_def <- strsplit(sizeTerms_arabic_indef, "|",fixed = TRUE)[[1]]
sizeTerms_arabic_def <- paste("ال", sizeTerms_arabic_def, sep = "")
sizeTerms_arabic_def <- paste(sizeTerms_arabic_def, collapse = "|")
sizeTerms <- paste(sizeTerms_arabizi,sizeTerms_arabic_indef, sizeTerms_arabic_def, sep="|")

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

# Step 10: final transformations on data for regression analyses and BDA 

destinationFolder <- "../../data/BCSPilot"
produceBDAandRegressionData(d, destinationFolder = destinationFolder)
