library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

source("../_shared/regressionHelpers.r")

# READ DATA
# # (dummy data for analysis pipeline creation)
d = read_delim("../../data/SpanishMain/data_exp1.tsv", delim = "\t")
d_postraw = read_tsv("../../data/SpanishMain/postManualTypoCorrection.tsv") %>% bind_rows(read_tsv("../../data/SpanishMain/postManualTypoCorrection_part2.tsv"))

# get data with linear order annotation
d_post = d_postraw %>% 
  select(gameId,roundNumber,nameClickedObj,words)
colnames(d_post) = c("gameid","Trial","TargetItem","WordOrder")
  
d = d %>% 
  left_join(d_post,by=c("gameid","Trial","TargetItem")) %>% 
  mutate(redWordOrder = case_when(
    WordOrder %in% c("ANC","NC","ANCS","ANS","NAS","NCAS","NCS","NS","NSC") ~ "post-nominal",
    WordOrder %in% c("ACN","CN","ACSN","ASN","CASN","CSN","SN","SCN","CSN","ASCN") ~ "pre-nominal",
    WordOrder %in% c("CNS","SNC") ~ "split",
  TRUE ~ "no noun")) %>% 
  mutate(interWordOrder = case_when(
    WordOrder %in% c("ANC","NC","ANCS","ANS","NAS","NCAS","NCS","NS","NSC") ~ "post-nominal",
    WordOrder %in% c("ACN","CN","ACSN","ASN","CASN","CSN","SN","SCN","CSN","ASCN") ~ "pre-nominal",
    WordOrder %in% c("CNS","SNC") ~ "split",
    WordOrder %in% c("ASC","SC") ~ "likely split",
    WordOrder %in% c("ACS","CS") ~ "likely post-nominal",
    TRUE ~ "no noun"))

# how many unique linear orders?
table(d$WordOrder)
# how many cases of pre-, post-, and split referring exps?
table(d$redWordOrder)
# no noun post-nominal 


# how many cases of pre-, post-, and split referring exps, assuming no-noun cases with linear order CS are post-nominal, and SC are split?
table(d$interWordOrder)
# likely post-nominal        likely split             no noun        post-nominal 


# only 6 of the 56 dyads used the purely post-nominal strategy with regularity
table(d$gameid,d$redWordOrder)

# how many cases of conjunction?
table(d_postraw$comments) # 19

# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY

visualize_sceneVariation(d)

ggsave(file="viz/scenevariation.pdf",width=8,height=4)

visualize_sceneVariation_byorder(d)

ggsave(file="viz/scenevariation_byorder.pdf",width=8,height=6)

# PLOT BY-DYAD VARIABILITY IN OVERMODIFICATION STRATEGY

visualize_byDyad(d)

ggsave(file="viz/bydyad.pdf",width=8,height=4)

# PLOT BY-DYAD VARIABILITY IN OVERMODIFICAITON STRATEGY BY EXPERIMENT HALF

visualize_byDyadHalf(d)

ggsave(file="viz/bydyadhalf.pdf",width=8,height=4)

# BAYESIAN MIXED EFFECTS LOGISTIC REGRESSION
## READ IN THE ENGLISH DATA FROM DEGEN ET AL. (2020)

d_english <- read_delim("../../data/Degen2020/data_exp1.csv", delim = "\t")
d_english$Language <- "English"
d$Language <- "Spanish"

d <- d %>%
  full_join(d_english)

# # CENTER PREDICTORS (NOTE: REFERENCE LEVEL OF FACTORS MAY CHANGE)
d <- d %>% 
  mutate(SufficientProperty = factor(SufficientProperty),
         redUtterance = factor(redUtterance),
         gameid = factor(gameid),
         Language = factor(Language))
centered = cbind(d,myCenter(data.frame(d %>% select(SufficientProperty, Trial, SceneVariation, Language))))
contrasts(centered$redUtterance)
contrasts(centered$SufficientProperty)
contrasts(centered$Language)

pairscor.fnc(centered[,c("redUtterance","SufficientProperty","SceneVariation","Language")])

options(mc.cores = parallel::detectCores())

# # MODEL SPECIFICATION, reported in xprag abstract

m.b.full = brm(redUtterance ~ cSufficientProperty*cSceneVariation*cLanguage + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation*cLanguage|clickedType), data=centered, family="bernoulli")

summary(m.b.full)


# create centered version of English dataset
centered = cbind(d_english %>% 
                   select(redUtterance,SufficientProperty,Trial,SceneVariation,gameid,clickedType) %>% 
                   mutate(SufficientProperty = as.factor(SufficientProperty)),
                 myCenter(data.frame(d_english %>% 
                                       select(SufficientProperty, Trial, SceneVariation) %>% 
                                       mutate(SufficientProperty = as.factor(SufficientProperty)))))

m.b.english = brm(redUtterance ~ cSufficientProperty*cSceneVariation + (1+cSufficientProperty+cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation|clickedType), data=centered, family="bernoulli")

summary(m.b.english)

# create centered version of Spanish dataset
centered = cbind(d %>% 
                   filter(Language == "Spanish") %>% 
                   select(redUtterance,SufficientProperty,Trial,SceneVariation,gameid,clickedType) %>% 
                   mutate(SufficientProperty = as.factor(SufficientProperty)),
                 myCenter(data.frame(d %>% 
                                       filter(Language == "Spanish") %>% 
                                       select(SufficientProperty, Trial, SceneVariation) %>% 
                                       mutate(SufficientProperty = as.factor(SufficientProperty)))))



m.b.spanish = brm(redUtterance ~ cSufficientProperty*cSceneVariation + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation|clickedType), data=centered, family="bernoulli")

summary(m.b.spanish)


# ONE-SIDED HYPOTHESIS TESTING (EXAMPLE)
hypothesis(m.b.full, "cLanguage < 0") # hypothesis(m.b.full, "cLanguage < 0"), depending on reference level coding

# PLOTTING POSTERIORS (EXAMPLE)
plot(m.b.full, variable = c("cSufficientProperty"))

# AUXILIARY GLMER ANALYSIS
m.glm = glmer(redUtterance ~ cSufficientProperty*cSceneVariation*cLanguage + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation*cLanguage|clickedType), data=centered, family="binomial")
summary(m.glm)


