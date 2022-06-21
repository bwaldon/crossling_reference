library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

source("../_shared/regressionHelpers.r")

d_english = read_delim("../../data/Degen2020/data_exp1.csv", delim = "\t") %>%
  filter(NumDistractors == 4 & NumSameDistractors == 2) %>%
  select(RedundantProperty, redundant) %>%
  mutate(language = "English")
d_ctsl = read_csv("../../data/CTSL/kurstat_ctsldata.csv") %>%
  filter(language == "CTSL") %>%
  select(RedundantProperty, redundant) %>%
  mutate(RedundantProperty = case_when(RedundantProperty == "color" ~ "color redundant",
                                       TRUE ~ "size redundant"))
d_spanish = read_delim("../../data/SpanishMain/data_exp1.tsv", delim = "\t") %>%
  filter(NumDistractors == 4 & NumSameDistractors == 2) %>%
  select(RedundantProperty, redundant) %>%
  mutate(language = "Spanish")

d = d_english %>%
  rbind(d_ctsl) %>%
  rbind(d_spanish) %>%
  group_by(RedundantProperty, language) %>%
  mutate(RedundantProperty = case_when(RedundantProperty == "color redundant" ~ "Color",
                                       TRUE ~ "Size")) %>%
  summarize(mean = mean(redundant), ciLow = ci.low(redundant),
            ciHigh = ci.high(redundant))

d$language <- fct_relevel(as.factor(d$language), "English", "CTSL", "Spanish")

p <- ggplot(data = d, aes(x = RedundantProperty, fill = RedundantProperty, y = mean)) + 
  facet_wrap(~language) +
  geom_bar(stat="identity",position = "dodge", colour="black") +
  ylab("Proportion of redundant\nfeature mention") +
  xlab("Redundant Property") +
  theme(legend.position = "none") +
  geom_errorbar(aes(ymin = mean - ciLow, ymax = mean + ciHigh), width = 0.2) +
  scale_fill_manual(values = c("Color" = "#47abcc",
                               "Size" = "yellow"))

ggsave("results_ELM.pdf", p, width = 8, height = 4, units = "in")
ggsave("results_ELM_nogrid.pdf", p + 
         theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()), width = 8, height = 4, units = "in")

# # CENTER PREDICTORS (NOTE: REFERENCE LEVEL OF FACTORS MAY CHANGE)

d_english_brm = read_delim("../../data/Degen2020/data_exp1.csv", delim = "\t") %>%
  filter(NumDistractors == 4 & NumSameDistractors == 2) %>%
  select(redUtterance, SufficientProperty, gameid, clickedType) %>%
  mutate(Language = "English")
d_ctsl_brm = read_csv("../../data/CTSL/kurstat_ctsldata.csv")%>%
  mutate(clickedType = str_split(targetName, "_", simplify=T)[,1]) %>%
  filter(language == "CTSL") %>%
  select(SufficientProperty, redundant, gameid, clickedType) %>%
  mutate(redUtterance = case_when(redundant == 1 ~ "redundant",
                                  TRUE ~ "minimal")) %>%
  mutate(Language = "CTSL") %>%
  select(-redundant)
d_spanish_brm = read_delim("../../data/SpanishMain/data_exp1.tsv", delim = "\t") %>%
  filter(NumDistractors == 4 & NumSameDistractors == 2) %>%
  select(redUtterance, SufficientProperty, gameid, clickedType) %>%
  mutate(Language = "Spanish")

d_brm <- d_english_brm %>%
  rbind(d_ctsl_brm) %>%
  rbind(d_spanish_brm)

d_brm$Language <- relevel(factor(d_brm$Language), ref = "English")

d_brm <- d_brm %>% 
  mutate(SufficientProperty = factor(SufficientProperty),
         redUtterance = factor(redUtterance),
         gameid = factor(gameid),
         Language = factor(Language))
centered = cbind(d_brm ,myCenter(data.frame(d_brm %>% select(SufficientProperty))))
contrasts(centered$redUtterance)
contrasts(centered$SufficientProperty)
contrasts(centered$Language)

pairscor.fnc(centered[,c("redUtterance","SufficientProperty","Language")])

options(mc.cores = parallel::detectCores())

# # MODEL SPECIFICATION

set.seed(123)

m.b.elm2 = brm(redUtterance ~ cSufficientProperty*Language + (1+cSufficientProperty|gameid) + (1+cSufficientProperty*Language|clickedType), data=centered, family="bernoulli")

summary(m.b.elm2)

# ONE-SIDED HYPOTHESIS TESTING (EXAMPLE)
hypothesis(m.b.elm2, "LanguageSpanish < 0") # hypothesis(m.b.full, "cLanguage < 0"), depending on reference level coding
hypothesis(m.b.elm2, "LanguageCTSL < 0")

# PLOTTING POSTERIORS (EXAMPLE)
plot(m.b.full, variable = c("cLanguage"))