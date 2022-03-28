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

# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY

visualize_sceneVariation(d)

ggsave(file="viz/scenevariation.pdf",width=8,height=4)

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

# # MODEL SPECIFICATION

m.b.full = brm(redUtterance ~ cSufficientProperty*cSceneVariation*cLanguage + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation*cLanguage|clickedType), data=centered, family="bernoulli")

summary(m.b.full)

# ONE-SIDED HYPOTHESIS TESTING (EXAMPLE)
hypothesis(m.b.full, "cLanguage < 0") # hypothesis(m.b.full, "cLanguage < 0"), depending on reference level coding

# PLOTTING POSTERIORS (EXAMPLE)
plot(m.b.full, variable = c("cSufficientProperty"))

# AUXILIARY GLMER ANALYSIS
m.glm = glmer(redUtterance ~ cSufficientProperty*cSceneVariation*cLanguage + (1+cSufficientProperty*cSceneVariation|gameid) + (1+cSufficientProperty*cSceneVariation*cLanguage|clickedType), data=centered, family="bernoulli")
summary(m.glm)


