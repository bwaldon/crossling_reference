library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

source("../../_shared/regressionHelpers.r")
source("helpers.R")


# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") 


#############
# Read in Data
#############

d = read_delim("../../../data/BCS/BCSEnglishMain/data_exp1.tsv", delim = "\t")

d <- d %>%
  select(gameId, language, condition, roundNumber, directorAllMessages, directorFirstMessage, guesserAllMessages,
         nameClickedObj, correct, colorMentioned, sizeMentioned, typeMentioned, oneMentioned, clickedColor, 
         clickedType, target)

d <- d %>%
  mutate(colorCondition = case_when(condition %in% c("scene1", "scene4") ~ "necessary",
                                    TRUE ~ "redundant"),
         genderCondition = case_when(condition %in% c("scene1", "scene2") ~ "match",
                                     TRUE ~ "mismatch"),
         colorMentioned = case_when(colorMentioned == TRUE ~ 1,
                                    TRUE ~ 0),
         nounMentioned = case_when(typeMentioned == TRUE ~ 1,
                                   TRUE ~ 0))

#############
# Plots
#############

# Color use by scenario
df_color <- d %>%
  group_by(colorCondition, genderCondition) %>%
  summarize(meanUse = mean(colorMentioned),
            CI.Low = ci.low(colorMentioned),
            CI.High = ci.high(colorMentioned)) %>%
  ungroup() %>% 
  mutate(YMin = meanUse - CI.Low, 
         YMax = meanUse + CI.High) %>%
  select(-CI.Low, -CI.High) %>%
  mutate(language = "English") %>%
  mutate(variable = "color")

df_color_BCS_fake <- data.frame(
  colorCondition = c("necessary", "necessary", "redundant", "redundant"),
  genderCondition = c("match", "mismatch", "match", "mismatch"),
  meanUse = c(0.98, 0.98, 0.3, 0.6),
  # YMin = c(0.93, 0.93, 0.27, 0.57),
  # YMax = c(1, 1, 0.33, 0.63),
  YMin = c(0, 0, 0, 0),
  YMax = c(0, 0, 0, 0),
  language = c(rep("BCS", 4)),
  variable = c(rep("color",4))
)

df_noun <- d %>%
  group_by(genderCondition, colorCondition) %>%
  summarize(meanUse = mean(nounMentioned),
            CI.Low = ci.low(nounMentioned),
            CI.High = ci.high(nounMentioned)) %>%
  ungroup() %>% 
  mutate(YMin = meanUse - CI.Low, 
         YMax = meanUse + CI.High) %>%
  select(-CI.Low, -CI.High) %>%
  mutate(language = "English") %>%
  mutate(variable = "noun")

df_noun_BCS_fake <- data.frame(
  colorCondition = c("necessary", "necessary", "redundant", "redundant"),
  genderCondition = c("match", "mismatch", "match", "mismatch"),
  meanUse = c(0.98, 0.3, 0.97, 0.5),
  #YMin = c(0.93, 0.27, 0.90, 0.53),
  #YMax = c(1, 0.33, 1, 0.47),
  YMin = c(0, 0, 0, 0),
  YMax = c(0, 0, 0, 0),
  language = c(rep("BCS", 4)),
  variable = c(rep("noun",4))
)

df_plot <- rbind(df_color, df_color_BCS_fake, df_noun, df_noun_BCS_fake)

plot <-  
  df_plot %>%
  ggplot(aes(x = colorCondition, y = meanUse, group = genderCondition)) +
  facet_grid(variable ~ language, 
             labeller = as_labeller(
               c(color = "Color", noun = "Noun", English = "English", BCS = "BCS (hypothesized results)"))) + 
  scale_fill_manual(values=c("#009E73", "#D55E00")) +
  geom_bar(position = "dodge", stat='identity', aes(fill=genderCondition)) +
  geom_errorbar(aes(ymin = YMin, ymax=YMax), width=0.4, position=position_dodge(.9)) +
  xlab("Color Condition") +
  ylab("Proportion of word use") +
  theme(text = element_text(size = 16), 
        plot.title = element_text(hjust = 0.5, size = 14),
        axis.text.x = element_text(size = 12),
        legend.text = element_text(size = 12)) +
  labs(fill = "Gender")
  
plot

ggsave(filename = "viz/colorAndNounUse.pdf", plot = plot,
       width = 6, height = 3.5, units = "in", device = "pdf")

# Noun use by Scenario

df_noun <- rbind(df_noun, df_noun_BCS_fake)

#plotNoun <-  
  df_noun %>%
  ggplot(aes(x = genderCondition, y = mean_noun, group = colorCondition)) +
  #facet_grid(. ~ language) +
  scale_fill_manual(values=c("#009E73", "#D55E00")) +
  geom_bar(position = "dodge", stat='identity', aes(fill=colorCondition)) +
  #geom_errorbar(aes(ymin = YMin, ymax=YMax), width=0.4, position=position_dodge(.9)) +
  xlab("Gender Condition") +
  ylab("Mean Noun Use") +
  theme(text = element_text(size = 12), 
        plot.title = element_text(hjust = 0.5, size = 12),
        axis.text.x = element_text(size = 8, angle = 45, hjust = 0.9),
        legend.text = element_text(size = 8)) #+
  labs(fill = "Color Condition")

  
  
  
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

ggsave(filename = "viz/nounUse.pdf", plot = plotNoun,
       width = 6, height = 2.5, units = "in", device = "pdf")

#############
# Regressions
#############

# Factor the variables
d$colorCondition <- factor(d$colorCondition)
d$genderCondition <- factor(d$genderCondition)
d$target <- factor(unlist(d$target))
d$gameId <- factor(d$gameId)

# # Relevel the variables
d <- d %>% mutate(colorCondition = fct_relevel(colorCondition, "redundant"))
d <- d %>% mutate(genderCondition = fct_relevel(genderCondition, "match"))

# Center the variables
d$ccolorCondition <- as.numeric(d$colorCondition) - mean(as.numeric(d$colorCondition))
d$cgenderCondition <- as.numeric(d$genderCondition) - mean(as.numeric(d$genderCondition))

# Run the models

# contrasts
contrasts(d$colorCondition)
contrasts(d$genderCondition)

<<<<<<< HEAD
BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
=======
# color use model, only random intercepts
BCSColorModel <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition + (1|gameId) + (1|target), data = d, family = binomial)

summary(BCSColorModel)

# color use model, full RE structure
BCSColorModel <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
>>>>>>> ae99190c8f4fce0063f5b6aba5615830490e8d2a

summary(BCSColorModel)

# noun use model, only random intercepts
BCSNounModel <- glmer(nounMentioned ~ ccolorCondition*cgenderCondition + (1|gameId) + (1|target), data = d, family = binomial)

summary(BCSNounModel)

# noun use model, full RE structure
BCSNounModel <- glmer(nounMentioned ~ ccolorCondition*cgenderCondition + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)

summary(BCSNounModel)



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
