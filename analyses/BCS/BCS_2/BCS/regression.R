##################
# Stefan Pophristic
# Fall 2022
# Regression script for BCS Experiment 2
# Crosslinguistic Reference Project
# ALPS
##################
#
# This script takes in the .tsv data file from BCS Experiment 2. The data was 
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

d = read_delim("../../../../data/BCS/BCS_2/BCS/data_cleaned.tsv", delim = "\t")

# Filter out gender column variables
d <- d %>%
  filter(!grepl("O",words)) %>%
  filter((gender %in% c(1, 3)) | (gender == 0 & grepl("N",words))) 

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
  mutate(colorCondition = case_when(condition %in% c("scene1", "scene2") ~ "necessary",
                                    TRUE ~ "redundant"),
         genderCondition = case_when(condition %in% c("scene1", "scene3") ~ "match",
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
# 36 trials require a color but no color was mentioned

# Number of trials were noun was necessary but it wasn't produced
d %>%
  filter(colorCondition == "redundant" & !grepl("N",words)) %>%
  nrow()
# 8 trials require a color but no color was mentioned


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
       title = "EXP2BCS")
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
# (Intercept)                        0.3954     0.3899   1.014    0.310    
# ccolorCondition                    4.1959     0.6026   6.963 3.32e-12 ***
# cgenderCondition                  -0.2878     0.3832  -0.751    0.453    
# ccolorCondition:cgenderCondition   0.1736     0.7459   0.233    0.816   

# 3 way interaction w/
BCSColorModelTrial <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition*trial + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
summary(BCSColorModelTrial)
#                                         Estimate   Std. Error z value Pr(>|z|)    
# ccolorCondition                         4.2780970  0.6086889   7.028 2.09e-12 ***
# cgenderCondition                       -0.2554991  0.4050075  -0.631   0.5281    
# trial                                  -0.0001406  0.0061391  -0.023   0.9817    
# ccolorCondition:cgenderCondition        0.2743265  0.7641843   0.359   0.7196    
# ccolorCondition:trial                   0.0137876  0.0123351   1.118   0.2637    
# cgenderCondition:trial                  0.0243065  0.0123558   1.967   0.0492 *  
# ccolorCondition:cgenderCondition:trial  0.0130904  0.0246811   0.530   0.5958  

BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
summary(BCSNounModel)
# Failure to converge

###########
###########
# By Quarter Analysis
###########
###########

# Add in experiment quarter
dq <- d %>%
  mutate(quarter = case_when(
    roundNumber %in% c(1:18) ~ 1,
    roundNumber %in% c(19:36) ~ 2,
    roundNumber %in% c(37:54) ~ 3,
    roundNumber %in% c(55:72) ~ 4
  )) %>%
  filter(quarter %in% c(1, 2, 3, 4))

###########
# PLOTS
###########

# Color use by scenario
df_color_q <- dq %>%
  group_by(colorCondition, genderCondition, quarter) %>%
  summarize(meanUse = mean(colorMentioned),
            CI.Low = ci.low(colorMentioned),
            CI.High = ci.high(colorMentioned)) %>%
  ungroup() %>%
  mutate(YMin = meanUse - CI.Low,
         YMax = meanUse + CI.High) %>%
  select(-CI.Low, -CI.High) %>%
  mutate(language = "BCS") %>%
  mutate(variable = "color")

df_noun_q <- dq %>%
  group_by(genderCondition, colorCondition, quarter) %>%
  summarize(meanUse = mean(nounMentioned),
            CI.Low = ci.low(nounMentioned),
            CI.High = ci.high(nounMentioned)) %>%
  ungroup() %>%
  mutate(YMin = meanUse - CI.Low,
         YMax = meanUse + CI.High) %>%
  select(-CI.Low, -CI.High) %>%
  mutate(language = "BCS") %>%
  mutate(variable = "noun")

df_plot_q <- rbind(df_color_q, df_noun_q)

plot_q <-
  df_plot_q %>%
  ggplot(aes(x = colorCondition, y = meanUse, group = genderCondition)) +
  facet_grid(quarter ~ variable) +
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
plot_q

ggsave(filename = "viz/colorAndNounUse_byQuarter.pdf", plot = plot,
       width = 6, height = 3.5, units = "in", device = "pdf")
