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

d = read_delim("../../../data/BCS/BCS2EngPilot/data_exp1.tsv", delim = "\t")

d <- d %>%
  select(gameId, language, condition, roundNumber, directorAllMessages, directorFirstMessage, guesserAllMessages,
         nameClickedObj, correct, colorMentioned, sizeMentioned, typeMentioned, oneMentioned, clickedColor, 
         clickedType, target)

d <- d %>%
  mutate(colorCondition = case_when(condition %in% c("scene1", "scene2") ~ "necessary",
                                    TRUE ~ "redundant"),
         genderCondition = case_when(condition %in% c("scene1", "scene3") ~ "match",
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
       title = "English BCS Study 2 Pilot")
plot

ggsave(filename = "viz/colorAndNounUse.pdf", plot = plot,
       width = 6, height = 3.5, units = "in", device = "pdf")




##########


  
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

# <<<<<<< HEAD
BCSNounModel <- glmer(nounMentioned ~ colorCondition*genderCondition + (1 + colorCondition*genderCondition|gameId) + (1 + colorCondition*genderCondition|target), data = d, family = binomial)
summary(BCSNounModel)
# Generalized linear mixed model fit by maximum likelihood (Laplace Approximation) ['glmerMod']
# Family: binomial  ( logit )
# Formula: nounMentioned ~ colorCondition * genderCondition + (1 + colorCondition *  
#                                                                genderCondition | gameId) + (1 + colorCondition * genderCondition |      target)
# Data: d
# 
# AIC      BIC   logLik deviance df.resid 
# 137.4    265.4    -44.7     89.4     1503 
# 
# Scaled residuals: 
#   Min       1Q   Median       3Q      Max 
# -2.89135  0.00000  0.00000  0.00154  0.38340 
# 
# Random effects:
#   Groups Name                                            Variance  Std.Dev. Corr             
# target (Intercept)                                        0.6597  0.8122                   
# colorConditionnecessary                          609.1012 24.6800  -0.86            
# genderConditionmismatch                         1791.7702 42.3293   0.06  0.34      
# colorConditionnecessary:genderConditionmismatch 4725.5467 68.7426   0.32 -0.71 -0.45
# gameId (Intercept)                                       78.2278  8.8447                   
# colorConditionnecessary                          973.0311 31.1934  -0.01            
# genderConditionmismatch                         2491.9218 49.9192   0.27  0.53      
# colorConditionnecessary:genderConditionmismatch 5490.4776 74.0978  -0.96 -0.20 -0.53
# Number of obs: 1527, groups:  target, 48; gameId, 39
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)   
# (Intercept)                                       10.111      3.591   2.816  0.00486 **
#   colorConditionnecessary                           30.657     27.591   1.111  0.26651   
# genderConditionmismatch                           32.066     45.634   0.703  0.48226   
# colorConditionnecessary:genderConditionmismatch  -27.573     74.456  -0.370  0.71114   
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#   (Intr) clrCnd gndrCn
# clrCndtnncs -0.110              
# gndrCndtnms  0.024  0.066       
# clrCndtnn:C -0.023 -0.408 -0.636
# optimizer (Nelder_Mead) convergence code: 0 (OK)
# unable to evaluate scaled gradient
# Model failed to converge: degenerate  Hessian with 8 negative eigenvalues

# color use model, only random intercepts
BCSColorModel <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition + (1|gameId) + (1|target), data = d, family = binomial)

summary(BCSColorModel)
# Generalized linear mixed model fit by maximum likelihood (Laplace Approximation) ['glmerMod']
# Family: binomial  ( logit )
# Formula: colorMentioned ~ ccolorCondition * cgenderCondition + (1 | gameId) +      (1 | target)
# Data: d
# 
# AIC      BIC   logLik deviance df.resid 
# 632.1    664.1   -310.1    620.1     1521 
# 
# Scaled residuals: 
#   Min      1Q  Median      3Q     Max 
# -84.528  -0.170   0.024   0.101   5.137 
# 
# Random effects:
#   Groups Name        Variance Std.Dev.
# target (Intercept)  0.5016  0.7082  
# gameId (Intercept) 11.1370  3.3372  
# Number of obs: 1527, groups:  target, 48; gameId, 39
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                        2.0281     0.5889   3.444 0.000573 ***
#   ccolorCondition                    8.1401     0.5810  14.011  < 2e-16 ***
#   cgenderCondition                  -0.2520     0.3639  -0.692 0.488692    
# ccolorCondition:cgenderCondition  -0.6121     0.7206  -0.849 0.395621    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#   (Intr) cclrCn cgndrC
# ccolorCndtn  0.226              
# cgendrCndtn -0.069 -0.149       
# cclrCndtn:C -0.069 -0.159  0.733
# color use model, full RE structure
BCSColorModel <- glmer(colorMentioned ~ ccolorCondition*cgenderCondition + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)
# >>>>>>> ae99190c8f4fce0063f5b6aba5615830490e8d2a

summary(BCSColorModel)

# Generalized linear mixed model fit by maximum likelihood (Laplace Approximation) ['glmerMod']
# Family: binomial  ( logit )
# Formula: colorMentioned ~ ccolorCondition * cgenderCondition + (1 + ccolorCondition *  
#                                                                   cgenderCondition | gameId) + (1 + ccolorCondition * cgenderCondition |      target)
# Data: d
# 
# AIC      BIC   logLik deviance df.resid 
# 651.2    779.1   -301.6    603.2     1503 
# 
# Scaled residuals: 
#   Min      1Q  Median      3Q     Max 
# -4.1477 -0.1476  0.0095  0.0460  4.7579 
# 
# Random effects:
#   Groups Name                             Variance Std.Dev. Corr             
# target (Intercept)                       0.9337  0.9663                    
# ccolorCondition                   0.9336  0.9662    0.69            
# cgenderCondition                  0.4362  0.6604   -0.86 -0.95      
# ccolorCondition:cgenderCondition  1.9635  1.4012   -0.47  0.25  0.06
# gameId (Intercept)                      11.9652  3.4591                    
# ccolorCondition                  20.8753  4.5690   0.35             
# cgenderCondition                  5.2486  2.2910   0.37  1.00       
# ccolorCondition:cgenderCondition 21.2224  4.6068   0.35  1.00  1.00 
# Number of obs: 1527, groups:  target, 48; gameId, 39
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                        3.1440     0.8060   3.901  9.6e-05 ***
#   ccolorCondition                   10.3390     1.3887   7.445  9.7e-14 ***
#   cgenderCondition                   0.5025     0.9261   0.543    0.587    
# ccolorCondition:cgenderCondition   0.9669     1.8346   0.527    0.598    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#   (Intr) cclrCn cgndrC
# ccolorCndtn 0.675               
# cgendrCndtn 0.432  0.558        
# cclrCndtn:C 0.433  0.572  0.946 
# optimizer (Nelder_Mead) convergence code: 4 (failure to converge in 10000 evaluations)
# unable to evaluate scaled gradient
# Model failed to converge: degenerate  Hessian with 2 negative eigenvalues
# failure to converge in 10000 evaluations

# noun use model, only random intercepts
BCSNounModel <- glmer(nounMentioned ~ ccolorCondition*cgenderCondition + (1|gameId) + (1|target), data = d, family = binomial)

summary(BCSNounModel)
# Generalized linear mixed model fit by maximum likelihood (Laplace Approximation) ['glmerMod']
# Family: binomial  ( logit )
# Formula: nounMentioned ~ ccolorCondition * cgenderCondition + (1 | gameId) +      (1 | target)
# Data: d
# 
# AIC      BIC   logLik deviance df.resid 
# 146.8    178.8    -67.4    134.8     1521 
# 
# Scaled residuals: 
#   Min      1Q  Median      3Q     Max 
# -9.4170  0.0249  0.0321  0.0577  0.8682 
# 
# Random effects:
#   Groups Name        Variance Std.Dev.
# target (Intercept) 0.9923   0.9961  
# gameId (Intercept) 5.9903   2.4475  
# Number of obs: 1527, groups:  target, 48; gameId, 39
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)    
# (Intercept)                        6.6399     1.0900   6.092 1.12e-09 ***
#   ccolorCondition                    0.2795     0.6803   0.411    0.681    
# cgenderCondition                   0.2892     0.6704   0.431    0.666    
# ccolorCondition:cgenderCondition  -1.3156     1.3319  -0.988    0.323    
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#   (Intr) cclrCn cgndrC
# ccolorCndtn  0.011              
# cgendrCndtn  0.037 -0.284       
# cclrCndtn:C -0.074  0.120  0.085


# noun use model, full RE structure
BCSNounModel <- glmer(nounMentioned ~ ccolorCondition*cgenderCondition + (1 + ccolorCondition*cgenderCondition|gameId) + (1 + ccolorCondition*cgenderCondition|target), data = d, family = binomial)

summary(BCSNounModel)
# Generalized linear mixed model fit by maximum likelihood (Laplace Approximation) ['glmerMod']
# Family: binomial  ( logit )
# Formula: nounMentioned ~ ccolorCondition * cgenderCondition + (1 + ccolorCondition *  
#                                                                  cgenderCondition | gameId) + (1 + ccolorCondition * cgenderCondition |      target)
# Data: d
# 
# AIC      BIC   logLik deviance df.resid 
# 149.0    276.9    -50.5    101.0     1503 
# 
# Scaled residuals: 
#   Min      1Q  Median      3Q     Max 
# -3.2662  0.0000  0.0000  0.0045  0.3957 
# 
# Random effects:
#   Groups Name                             Variance Std.Dev. Corr             
# target (Intercept)                        21.49   4.635                    
# ccolorCondition                    14.97   3.870   -1.00            
# cgenderCondition                  100.97  10.048   -0.94  0.93      
# ccolorCondition:cgenderCondition 2079.41  45.601   -0.98  0.98  0.99
# gameId (Intercept)                        29.17   5.401                    
# ccolorCondition                   827.29  28.763   -0.87            
# cgenderCondition                  333.38  18.259    0.92 -0.62      
# ccolorCondition:cgenderCondition 1541.13  39.257   -0.96  0.93 -0.81
# Number of obs: 1527, groups:  target, 48; gameId, 39
# 
# Fixed effects:
#   Estimate Std. Error z value Pr(>|z|)  
# (Intercept)                        18.977      8.517   2.228   0.0259 *
#   ccolorCondition                     1.858     15.195   0.122   0.9027  
# cgenderCondition                    9.371     14.999   0.625   0.5321  
# ccolorCondition:cgenderCondition  -13.401     34.066  -0.393   0.6940  
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Correlation of Fixed Effects:
#   (Intr) cclrCn cgndrC
# ccolorCndtn -0.426              
# cgendrCndtn  0.630 -0.704       
# cclrCndtn:C -0.768  0.639 -0.419
# optimizer (Nelder_Mead) convergence code: 4 (failure to converge in 10000 evaluations)
# unable to evaluate scaled gradient
# Model failed to converge: degenerate  Hessian with 7 negative eigenvalues
# failure to converge in 10000 evaluations


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
