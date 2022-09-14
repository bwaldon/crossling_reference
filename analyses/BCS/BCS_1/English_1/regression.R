##################
# Stefan Pophristic
# Fall 2022
# Regression script for BCS Experiment 1
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

d = read_delim("../../../../data/BCS/BCS_1/English_1/data_cleaned.tsv", delim = "\t")
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
       title = "English stranger participants")
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
BCSColorModel <- glmer(color_mentioned ~ ccolorCondition*cgenderCondition + (1|gameId) + (1|target), data = d, family = binomial)
summary(BCSColorModel)
#                                   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                        3.1261     0.6693   4.671    3e-06 ***
# ccolorCondition                    9.5080     0.8569  11.096   <2e-16 ***
# cgenderCondition                  -0.5935     0.6140  -0.967    0.334    
# ccolorCondition:cgenderCondition  -1.3911     1.2189  -1.141    0.254  

# 3 way interaction
BCSColorModelTrial <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition*trial + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
summary(BCSColorModelTrial)
# Estimate Std. Error z value Pr(>|z|)
# (Intercept)                             14.4647    10.6558   1.357    0.175
# ccolorCondition                         32.0447    21.0906   1.519    0.129
# cgenderCondition                       -24.2712    21.0672  -1.152    0.249
# trial                                   -0.1131     0.1375  -0.823    0.411
# ccolorCondition:cgenderCondition       -46.7924    41.7449  -1.121    0.262
# ccolorCondition:trial                   -0.2143     0.2725  -0.786    0.432
# cgenderCondition:trial                   0.2453     0.2740   0.895    0.371
# ccolorCondition:cgenderCondition:trial   0.4417     0.5422   0.815    0.415

BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
summary(BCSNounModel)

