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

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

source("../../../_shared/regressionHelpers.r")


###############
# Load + Clean the Data
###############

d = read_delim("../../../../data/BCS/BCS_1/BCS/data_cleaned.tsv", delim = "\t")

# Filter out gender column variables
d <- d %>%
  filter(!grepl("O",words)) %>%
  filter((gender %in% c(1, 3)) | (gender == 0 & grepl("N",words))) %>%
  filter(condition %in% c("scene1", "scene2", "scene3", "scene4"))

# The gender column refers to whether gender was marked on the color adjective
# The following notation was used for the gender column:
# 0: no color adjective, therefore no gender marking
# 1: color adjective + appropriate gender marking
# 2: Color adjective + gender marking, but the statement was type "other" therefore
#     gender may not refer to target object
# 3: Color adjective but no gender marking (e.g. writing "ljub." instead of "ljubicasta")
# 4: Color adjective that cannot have a gender suffix (e.g. "braun" or "lila")
# 5: Color adjective with neuter gender (no neuter nouns were included in the 
#     data set). Neuter is usually the citation form of an adjective
# 6: Color adjective with non-matching gender (e.g. blue.masc + noun.fem)

# We are included case #3 under the assumption that participants reconstruct the
#   full word.


# Change condition names
# Add in color/noun mentioned columns with numbers
d <- d %>%
  mutate(colorCondition = case_when(condition %in% c("scene1", "scene4") ~ "necessary",
                                    TRUE ~ "redundant"),
         genderCondition = case_when(condition %in% c("scene1", "scene2") ~ "match",
                                     TRUE ~ "mismatch"),
         colorMentioned = case_when(colorMentioned == TRUE ~ 1,
                                    TRUE ~ 0),
         nounMentioned = case_when(nounMentioned == TRUE ~ 1,
                                   TRUE ~ 0))

# Sanity check: Within a single game, was an object ever shown as the target twice?
# print statement should show: 0
sanityCheck <- d %>%
  group_by(gameId) %>%
  select(gameId, target)

sanityCheck <- sanityCheck %>%
  group_by_all() %>%
  mutate(
    n_row = row_number(),
    dup   = n_row > 1
  )

sanityCheck %>%
  filter(dup == TRUE) %>%
  nrow()


# Number of trials were color was necessary but it wasn't produced
d %>%
  filter(colorCondition == "necessary" & !grepl("C",words)) %>%
  nrow()
# 33 trials require a color but no color was mentioned

# Number of trials were noun was necessary but it wasn't produced
d %>%
  filter(colorCondition == "redundant" & !grepl("N",words)) %>%
  nrow()
# 0 trials require a color but no color was mentioned



###############
###############
# Plots
###############
###############

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
  mutate(language = "BCS") %>%
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
  mutate(language = "BCS") %>%
  mutate(variable = "noun")

# df_plot <- rbind(df_color, df_color_BCS_fake, df_noun, df_noun_BCS_fake)
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
       title = "BCS 1 Participants")
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

# # Relevel the variables and center them
d <- d %>% 
  mutate(colorCondition = fct_relevel(colorCondition, "redundant"),
         ccolorCondition = as.numeric(colorCondition) - mean(as.numeric(colorCondition)))
d <- d %>% mutate(genderCondition = fct_relevel(genderCondition, "match"),
                  cgenderCondition = as.numeric(genderCondition) - mean(as.numeric(genderCondition)))
d <- d %>% mutate(trial = as.numeric(roundNumber) - mean(as.numeric(roundNumber))) 

# Run the models
BCSColorModel <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
summary(BCSColorModel)
#                                   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                        0.4511     1.1506   0.392    0.695    
# ccolorCondition                   10.8160     1.8975   5.700  1.2e-08 ***
# cgenderCondition                  -0.6240     3.5023  -0.178    0.859    
# ccolorCondition:cgenderCondition  -0.1237     6.9431  -0.018    0.986  


# 3 way interaction
BCSColorModelTrial <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition*trial + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
summary(BCSColorModelTrial)
#                                         Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                             0.041826   1.202251   0.035   0.9722    
# ccolorCondition                        11.273972   1.408199   8.006 1.19e-15 ***
# cgenderCondition                       -1.022534   1.935238  -0.528   0.5972    
# trial                                  -0.004087   0.015612  -0.262   0.7935    
# ccolorCondition:cgenderCondition        0.791245   3.929641   0.201   0.8404    
# ccolorCondition:trial                   0.072325   0.030310   2.386   0.0170 *  
# cgenderCondition:trial                 -0.058121   0.029368  -1.979   0.0478 *  
# ccolorCondition:cgenderCondition:trial  0.028561   0.061602   0.464   0.6429    

BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
# Error: Response is constant

