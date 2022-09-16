##################
# Stefan Pophristic
# Fall 2022
# Regression script for BCS Experiment 1 Familiar
# Crosslinguistic Reference Project
# ALPS
##################
#
# This script takes in the .tsv data file from BCS Experiment 1. The data was 
# preprocessed using the preprocessing.r script found in this folder. 
# 
# The script runs a mixed linear effects model and produces data visualizations 
# found in the viz folder. 
#
# For participant information such as dialect, age, gender, see the comments
# interspersed int eh preprocessing.r script. 

#############
# Read in Data
#############

# Plots
#############
# Color use by scenario

#############
# Regressions
#############

###############
###############
# Load Everything
###############
###############

library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)

theme_set(theme_bw(18))
this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

source("../../../_shared/regressionHelpers.r")
source("helpers.R")

# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#############
# Read in Data
#############

d = read_delim("../../../../data/BCS/BCS_1/English_2/data_cleaned.tsv", delim = "\t")

d <- d %>%
  select(-clickedType) %>%
  rename(trial = roundNumber)

d <- d %>%
  mutate(colorCondition = case_when(condition %in% c("scene1", "scene4") ~ "necessary",
                                    TRUE ~ "redundant"),
         genderCondition = case_when(condition %in% c("scene1", "scene2") ~ "match",
                                     TRUE ~ "mismatch"))


# Number of trials were color was necessary but it wasn't produced
d %>%
  filter(colorCondition == "necessary" & !grepl("C",words)) %>%
  nrow()
# 4 trials require a color but no color was mentioned

# Number of trials were noun was necessary but it wasn't produced
d %>%
  filter(colorCondition == "redundant" & !grepl("N",words)) %>%
  nrow()
# 1 trials require a color but no color was mentioned

###############
###############
# Plots
###############
###############


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

df_plot <- rbind(df_color, df_noun)

plot <-
  df_plot %>%
  ggplot(aes(x = colorCondition, y = meanUse, group = genderCondition)) +
  facet_grid(. ~ variable) +
  scale_fill_manual(values=c("#009E73", "#D55E00")) +
  geom_bar(position = "dodge", stat='identity', aes(fill=genderCondition)) +
  geom_errorbar(aes(ymin = YMin, ymax=YMax), width=0.4, position=position_dodge(.9)) +
  xlab("Color Condition") +
  ylab("Proportion of word use") +
  theme(text = element_text(size = 16),
        plot.title = element_text(hjust = 0.5, size = 14),
        axis.text.x = element_text(size = 12),
        legend.text = element_text(size = 12)) +
  labs(fill = "Gender",
       title = "English Familiar participants")
plot
ggsave(filename = "viz/colorAndNounUse.pdf", plot = plot,
       width = 6, height = 3.5, units = "in", device = "pdf")

###############
###############
#  Regression Analysis
###############
###############

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

# Color Production
BCSColorModel <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition + (1|gameId) + (1|target), data = d, family = binomial)
summary(BCSColorModel)
#                                    Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                        1.3656     0.8339   1.638    0.101    
# ccolorCondition                    6.1570     0.6554   9.394   <2e-16 ***
# cgenderCondition                   0.1760     0.5652   0.311    0.756    
# ccolorCondition:cgenderCondition  -0.3190     1.1476  -0.278    0.781 

# 3 way interaction
BCSColorModelTrial <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition*trial + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
summary(BCSColorModelTrial)
#                                         Estimate Std. Error z value Pr(>|z|)
# (Intercept)                              6.7382    14.1894   0.475    0.635
# ccolorCondition                         17.6136    29.3265   0.601    0.548
# cgenderCondition                       -11.4230    27.8057  -0.411    0.681
# trial                                   -0.1915     0.3738  -0.512    0.608
# ccolorCondition:cgenderCondition       -22.2074    57.4799  -0.386    0.699
# ccolorCondition:trial                    0.1493     0.7597   0.197    0.844
# cgenderCondition:trial                   0.4085     0.7342   0.556    0.578
# ccolorCondition:cgenderCondition:trial  -0.2999     1.4936  -0.201    0.841

BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
summary(BCSNounModel)
#                                                     Estimate Std. Error z value Pr(>|z|)
# (Intercept)                                          938.6  6958855.7   0.000    1.000
# colorConditionnecessary                             -725.7  6958855.8   0.000    1.000
# genderConditionmismatch                             -677.8  6958855.8   0.000    1.000
# colorConditionnecessary:genderConditionmismatch    32870.0 10070213.5   0.003    0.997

