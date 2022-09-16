library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

source("../../_shared/regressionHelpers.r")

# READ DATA

d = read_delim("../../../data/BCS/BCSPilot/data_exp1.tsv", delim = "\t")

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
# Regressions


# Factor the variables
d$colorCondition <- factor(d$colorCondition)
d$genderCondition <- factor(d$genderCondition)
d$target <- factor(unlist(d$target))

# # Relevel the variables
d <- d %>% mutate(colorCondition = fct_relevel(colorCondition, "redundant"))
d <- d %>% mutate(genderCondition = fct_relevel(genderCondition, "match"))

# Center the variables
contrasts(d$colorCondition) <- contr.sum(2)
contrasts(d$genderCondition) <- contr.sum(2)

# Run the models
BCSColorModel <- glmer(colorMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)

# Model outputs
summary(BCSColorModel)
summary(BCSNounModel)
