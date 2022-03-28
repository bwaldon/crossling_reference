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

d = read_delim("../../data/BCSPilot/data_exp1.tsv", delim = "\t")

d <- d %>%
  filter(condition %in% c("scenario1", "scenario2", "scenario3", "scenario4")) %>%
  select(gameId, language, condition, roundNumber, directorAllMessages, directorFirstMessage, guesserAllMessages,
         nameClickedObj, correct, colorMentioned, sizeMentioned, typeMentioned, oneMentioned, clickedColor, 
         clickedType, target)

# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY

# We don't change scene Variation (number of distractor items), so this plot is obsolete
#visualize_sceneVariation(d)

#ggsave(file="viz/scenevariation.pdf",width=8,height=4)


d <- d %>%
  mutate(colorCondition = case_when(condition %in% c("scenario1", "scenario4") ~ "necessary",
                                    TRUE ~ "redundant"),
         genderCondition = case_when(condition %in% c("scenario1", "scenario2") ~ "match",
                                     TRUE ~ "mismatch"),
         colorMentioned = case_when(colorMentioned == TRUE ~ 1,
                                    TRUE ~ 0),
         nounMentioned = case_when(typeMentioned == TRUE ~ 1,
                                   TRUE ~ 0))

# Plots

# Color use by scenario
df_colorMentioned <- d %>%
  group_by(colorCondition, genderCondition) %>%
  filter(colorMentioned == 1) %>%
  count(colorMentioned)

df_totalColor <- d %>%
  group_by(colorCondition, genderCondition) %>%
  count()

df_color <- merge(df_colorMentioned, df_totalColor, by = c("colorCondition", "genderCondition"), all.y = TRUE)

df_color <- df_color %>%
  rename(totalColorMentioned = n.x, n = n.y)

df_color$totalColorMentioned <- df_color$totalColorMentioned %>%
  replace_na(0)

df_color <- df_color %>%
  mutate(colorUse = totalColorMentioned/n)

plotColor <- ggplot(df_color, aes(x = colorCondition, y = colorUse, group = genderCondition)) +
  geom_bar(position = "dodge", stat='identity', aes(fill=genderCondition)) 

plotColor

ggsave(filename = "colorUse.pdf", plot = plotColor,
       width = 6, height = 2.5, units = "in", device = "pdf")

# Noun use by Scenario
df_nounMentioned <- d %>%
  group_by(genderCondition, colorCondition) %>%
  filter(nounMentioned == 1) %>%
  count(nounMentioned)

df_totalNoun <- d %>%
  group_by(genderCondition, colorCondition) %>%
  count()

df_noun <- merge(df_nounMentioned, df_totalNoun, by = c("genderCondition", "colorCondition"), all.y = TRUE)

df_noun <- df_noun %>%
  rename(totalNounMentioned = n.x, n = n.y)

df_noun$totalNounMentioned <- df_noun$totalNounMentioned

df_noun <- df_noun %>%
  mutate(nounUse = totalNounMentioned/n)

plotNoun <- ggplot(df_noun, aes(x = genderCondition, y = nounUse, group = colorCondition)) +
  geom_bar(position = "dodge", stat='identity', aes(fill=colorCondition)) 

plotNoun

ggsave(filename = "nounUse.pdf", plot = plotNoun,
       width = 6, height = 2.5, units = "in", device = "pdf")

###################
###################
# For BCS

d <- d %>%
  mutate(colorCondition = case_when(colorCondition == "necessary" ~ 1,
                                    TRUE ~ 0),
         genderCondition = case_when(genderCondition == "mismatch" ~ 1,
                                     TRUE ~ 0),
         gameId = case_when(gameId == "WskiQY3QG4XLCmLFx" ~ 1,
                             gameId == "kgAjLRok7q3vskRYD" ~ 2,
                             gameId == "sANt6jJXrNsm3zFLu" ~ 3),
         target = case_when(target == "belt" ~ 1,
                            target == "tie" ~ 2,
                            target == "pencil" ~ 3,
                            target == "butterfly" ~ 4,
                            target == "bowl" ~ 5,
                            target == "binoculars" ~ 6,
                            target == "fence" ~ 7,
                            target == "mask" ~ 8,
                            target == "robot" ~ 9,
                            target == "helicopter" ~ 10,
                            target == "guitar" ~ 11,
                            target == "knife" ~ 12,
                            target == "crown" ~ 13,
                            target == "necklace" ~ 14,
                            target == "scarf" ~ 15,
                            target == "truck" ~ 16,
                            target == "lock" ~ 17,
                            target == "calculator" ~ 18,
                            target == "door" ~ 19,
                            target == "die" ~ 20,
                            target == "fork" ~ 21,
                            target == "drum" ~ 22,
                            target == "phone" ~ 23,
                            target == "basket" ~ 24,
                            target == "comb" ~ 25,
                            target == "chair" ~ 26,
                            target == "slipper" ~ 27,
                            target == "bed" ~ 28,
                            target == "ring" ~ 29,
                            target == "hammer" ~ 30,
                            target == "calendar" ~ 31,
                            target == "fish" ~ 32,
                            target == "book" ~ 33,
                            target == "ribbon" ~ 34,
                            target == "walled" ~ 35,
                            target == "screwdriver" ~ 36,
                            target == "iron" ~ 37,
                            target == "candle" ~ 38,
                            target == "flower" ~ 39,
                            target == "shell" ~ 40,
                            target == "dress" ~ 41,
                            target == "sock" ~ 42,
                            target == "mug" ~ 43,
                            target == "balloon" ~ 44,
                            target == "microscope" ~ 45,
                            target == "glove" ~ 46,
                            target == "cushion" ~ 47,
                            target == "sock" ~ 48
                            ))
# Factor the variables
# d$colorCondition <- factor(d$colorCondition)
# d$genderCondition <- factor(d$genderCondition)
# # d$colorMentioned <- factor(d$colorMentioned)
# d$gameId <- factor(d$gameId)
# d$target <- factor(unlist(d$target))

# # Relevel the variables
# d <- d %>% mutate(colorCondition = fct_relevel(colorCondition, "redundant"))
# d <- d %>% mutate(genderCondition = fct_relevel(genderCondition, "match"))
# Center the variables
# d$colorCondition = d$colorCondition - mean(d$colorCondition)
# d$genderCondition = d$genderCondition - mean(d$genderCondition)

# Run the models
#test<-glm(colorMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family=binomial(link="logit"))
BCSColorModel <- glm(colorMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d)
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
