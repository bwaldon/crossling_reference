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

d = read_delim("../../data/BCSPilot/postManualTypoCorrection.tsv", delim = "\t")

d <- d %>%
  filter(is.na(condition)) %>%
  mutate(clickedFeatures = strsplit(nameClickedObj, "_"),
         clickedColor = map(clickedFeatures, pluck, 1),
         clickedType = map(clickedFeatures, pluck, 2),
         clickedSize = rep("0", length(clickedFeatures)))

# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY

# We don't change scene Variation (number of distractor items), so this plot is obsolete
#visualize_sceneVariation(d)

#ggsave(file="viz/scenevariation.pdf",width=8,height=4)


# PLOT BY-DYAD VARIABILITY IN OVERMODIFICATION STRATEGY

# change this to only include color redundancy and not size redundancy use (change it for BCS)
visualize_byDyad(d)

ggsave(file="viz/bydyad.pdf",width=8,height=4)

# PLOT BY-DYAD VARIABILITY IN OVERMODIFICAITON STRATEGY BY EXPERIMENT HALF

# change this to only include color redundancy and not size redundancy use (change it for BCS)
visualize_byDyadHalf(d)

ggsave(file="viz/bydyadhalf.pdf",width=8,height=4)

# BAYESIAN MIXED EFFECTS LOGISTIC REGRESSION
## READ IN THE ENGLISH DATA FROM DEGEN ET AL. (2020)

d_english <- read_delim("../../data/Degen2020/data_exp1.csv", delim = "\t")
d_english$Language <- "English"
d$Language <- "Arabic"

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

# # MODEL SPECIFICATION

m.b.full = brm(redUtterance ~ cSufficientProperty*cSceneVariation*cLanguage + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation*cLanguage|clickedType), data=centered, family="bernoulli")

summary(m.b.full)

# ONE-SIDED HYPOTHESIS TESTING (EXAMPLE)
hypothesis(m.b.full, "cLanguage > 0") # hypothesis(m.b.full, "cLanguage < 0"), depending on reference level coding

# PLOTTING POSTERIORS (EXAMPLE)
plot(m.b.full, variable = c("cSufficientProperty"))

# AUXILIARY GLMER ANALYSIS

# Center the variables of condition


###################
###################
# For BCS

# Factor the variables
d$colorCondition <- factor(d$colorCondition)
d$genderCondition <- factor(d$genderCondition)

# Relevel the variables
d <- d %>% mutate(colorCondition = fct_relevel(colorCondition, "redundant"))
d <- d %>% mutate(genderCondition = fct_relevel(genderCondition, "match"))

# Center the variables
dataFrame$colorCondition = dataFrame$colorCondition - (dataFrame$mean(colorCondition))
dataFrame$genderCondition = dataFrame$genderCondition - (dataFrame$mean(genderCondition))

# Run the models
BCSColorModel <- glmer(colorUse ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|participant) + (1 + colorCondition*genderCondition|item))
BCSNounModel <- glmer(nounUse ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|participant) + (1 + colorCondition*genderCondition|item))

# Model outputs
summary(BCSColorModel)
summary(BCSNounModel)

# Color Use Graphs
# For BCS Participants
d <- read.csv("fakedata.csv")
  
colorPresentSum <- d %>%
  group_by(colorCondition, genderCondition) %>%
  filter(colorUse == 1) %>%
  count(colorUse)

dfPlot <- d %>%
  group_by(colorCondition, genderCondition) %>%
  count()

dfPlot$probability = colorPresentSum$n/dfPlot$n

ggplot(data=dfPlot, aes(x=colorCondition, y=probability, fill=genderCondition)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  theme_minimal()

# Create Graphs for English Participants
# Repeat above code

# Create faceted graphs to compare BCS and English participants
# merge above two dataframes into one and repeat above code with an extra group_by variable


# Noun Use Graphs
# For BCS Participants
nounPresentSum <- d %>%
  group_by(colorCondition, genderCondition) %>%
  filter(nounUse == 1) %>%
  count(nounUse)

dfPlotNoun <- d %>%
  group_by(colorCondition, genderCondition) %>%
  count()

dfPlotNoun$probability = nounPresentSum$n/dfPlotNoun$n

ggplot(data=dfPlotNoun, aes(x=colorCondition, y=probability, fill=genderCondition)) +
  geom_bar(stat="identity", color="black", position=position_dodge()) +
  theme_minimal()


# Create Graphs for English Participants
# Repeat above code

# Create faceted graphs to compare BCS and English participants
# merge above two dataframes into one and repeat above code with an extra group_by variable


# intercept --> overall baseline differences in color use
# slope --> how sensitive people are to particular fixed effect
## color condition --> more sensitive to color condition 
# there can be an overall effect of color condition, but some people won't show it!

#colorUse = color mention in a single trial {1,0}
# 
#colorCondition = {necessary, redundant}
# FACTOR the variable
#
# RELEVEL
# color necessity reference level: "redundant"; gender match reference level: "match"
# d (the dataframe)
# d <- d %>% mutate(colorCondition = fct_relevel(colorCondition, "redundant"))
# this makes redundant level the 0 level
#
# CENTER
# underlyingly:
# --> necessary = 0
# --> redundant = 1
# scale() or by hand --> 
# dataFrame$colorCondition = dataFrame$colorCondition - (dataFrame$mean(colorCondition))
# moves 0 point between two levels of the variable
#
# significant effect of colorCondition --> effect is just for 0 level of other variable (genderCondition) i.e. match Condition
#then we don't have the effect for mismatch condition
# same true vice versa
#
#
# centering --> allows for interpretation of both levels as 
# -.05 = level 1; .05 = level 2 
# this is scaled by number of cases per level 
 
#genderCondition = {match, mismatch}


m.glm = glmer(redUtterance ~ cSufficientProperty*cSceneVariation*cLanguage + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation*cLanguage|clickedType), data=centered, family="bernoulli")
summary(m.glm)
