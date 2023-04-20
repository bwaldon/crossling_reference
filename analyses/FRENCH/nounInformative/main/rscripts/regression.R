library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
library(viridis)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

source("../../../../_shared/regressionHelpers.r")

# READ DATA
# # (dummy data for analysis pipeline creation)
d = read_delim("../../../../../data/FRENCH/nounInformative/main/data_exp1.tsv", delim = "\t")
#d_postraw = read_tsv("../../data/SpanishMain/postManualTypoCorrection.tsv") %>% bind_rows(read_tsv("../../data/SpanishMain/postManualTypoCorrection_part2.tsv"))

condition_info = read_csv("../../../data/condition-information.csv")

d = d %>% 
  left_join(condition_info,by=c("condition","NumDistractors"))

# get data with linear order annotation
#d_post = d_postraw %>% 
#select(gameId,roundNumber,nameClickedObj,words)
#colnames(d_post) = c("gameid","Trial","TargetItem","WordOrder")

# d = d %>% 
#   left_join(d_post,by=c("gameid","Trial","TargetItem")) %>% 
#   mutate(redWordOrder = case_when(
#     WordOrder %in% c("ANC","NC","ANCS","ANS","NAS","NCAS","NCS","NS","NSC") ~ "post-nominal",
#     WordOrder %in% c("ACN","CN","ACSN","ASN","CASN","CSN","SN","SCN","CSN","ASCN") ~ "pre-nominal",
#     WordOrder %in% c("CNS","SNC") ~ "split",
#   TRUE ~ "no noun")) %>% 
#   mutate(interWordOrder = case_when(
#     WordOrder %in% c("ANC","NC","ANCS","ANS","NAS","NCAS","NCS","NS","NSC") ~ "post-nominal",
#     WordOrder %in% c("ACN","CN","ACSN","ASN","CASN","CSN","SN","SCN","CSN","ASCN") ~ "pre-nominal",
#     WordOrder %in% c("CNS","SNC") ~ "split",
#     WordOrder %in% c("ASC","SC") ~ "likely split",
#     WordOrder %in% c("ACS","CS") ~ "likely post-nominal",
#     TRUE ~ "no noun"))

# how many unique linear orders?
#table(d$WordOrder)
# how many cases of pre-, post-, and split referring exps?
#table(d$redWordOrder)
# no noun post-nominal 


# how many cases of pre-, post-, and split referring exps, assuming no-noun cases with linear order CS are post-nominal, and SC are split?
#table(d$interWordOrder)
# likely post-nominal        likely split             no noun        post-nominal 


# only x of the x dyads used the purely post-nominal strategy with regularity
# table(d$gameid,d$redWordOrder)

# how many cases of conjunction?
# table(d_postraw$comments) # 19

# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY
agr <- d %>%
  mutate(Condition = case_when(
    TrialType == "target" & DistractorsNoun == "no_extras" ~ "base",
    TrialType == "control" ~ ControlType,
    TRUE ~ paste(DistractorsNoun,"_",DistractorsRedProp,"",sep=""))) %>% 
  select(redundant,RedundantProperty,Condition,TrialType) %>%
  # mutate(Condition = case_when(
    # NumDistractors == 3 ~ "base",
    # TRUE ~ paste(DistractorsNoun,"_noun/",DistractorsRedProp,"_redundantvalue",sep=""))) %>% 
  #mutate(Redundant = case_when(redUtterance == "redundant" ~ 1,
  #TRUE ~ 0)) %>% 
  # pivot_longer(redUtterance,names_to="Utterance",values_to="Mentioned",-Redundant_Property,-NumDistractors,-Distractors_Noun,-Distractors_RedProp) %>%
  group_by(RedundantProperty,TrialType,Condition) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high) %>% 
  mutate(Condition = fct_relevel(Condition, "noun_sufficient","size_redundant","color_redundant"),
         RedundantProperty=fct_recode(RedundantProperty,color="color redundant",size="size redundant"))

write.csv(agr,"../../../../../data/FRENCH/nouninformative/main/scene_probabilities.csv")

ggplot(agr, aes(x=Condition,y=Probability,color=RedundantProperty,group=1)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  xlab("Condition") +
  ylab("Proportion of over-modification") +
  scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  facet_wrap(~TrialType,scales="free") +
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))

ggsave(file="../graphs/redundant_proportions.pdf",width=8,height=7)



# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY
agr <- d %>%
  mutate(Condition = case_when(
    TrialType == "target" & DistractorsNoun == "no_extras" ~ "base",
    TrialType == "control" ~ ControlType,
    TRUE ~ paste(DistractorsNoun,"_",DistractorsRedProp,"",sep=""))) %>% 
  select(redundant,RedundantProperty,Condition,TrialType,NumDistractors,SameSize,SameColor,SameNoun) %>%
  # mutate(Condition = case_when(
  # NumDistractors == 3 ~ "base",
  # TRUE ~ paste(DistractorsNoun,"_noun/",DistractorsRedProp,"_redundantvalue",sep=""))) %>% 
  #mutate(Redundant = case_when(redUtterance == "redundant" ~ 1,
  #TRUE ~ 0)) %>% 
  # pivot_longer(redUtterance,names_to="Utterance",values_to="Mentioned",-Redundant_Property,-NumDistractors,-Distractors_Noun,-Distractors_RedProp) %>%
  group_by(RedundantProperty,TrialType,Condition,NumDistractors,SameSize,SameColor,SameNoun) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high) %>% 
  mutate(Condition = fct_relevel(Condition, "noun_sufficient","size_redundant","color_redundant"),
         RedundantProperty=fct_recode(RedundantProperty,color="color redundant",size="size redundant"))

write.csv(agr,"../../../../../data/FRENCH/nouninformative/main/scene_probabilities.csv")


agr$DiffSize = agr$NumDistractors - agr$SameSize
agr$DiffColor = agr$NumDistractors - agr$SameColor
agr$DiffNoun = agr$NumDistractors - agr$SameNoun

# agr$numCondition = paste(agr$SameSize, agr$SameColor, agr$SameNoun)
# agr$numCondition = paste(agr$DiffSize, agr$DiffColor, agr$DiffNoun)

# SIZE COLOR NOUN
agr$propDiffNoun = round(agr$DiffNoun / agr$NumDistractors,2)
agr = agr %>% 
  mutate(propDiffRedundant = case_when(RedundantProperty == "color" ~ DiffColor / NumDistractors,
                                       RedundantProperty == "size" ~ DiffSize / NumDistractors,
                                       TRUE ~ 555))

agr$charpropDiffNoun = as.factor(as.character(agr$propDiffNoun))
# dodge = position_dodge(.9)

ggplot(agr %>% filter(TrialType == "target") %>% droplevels(), aes(x=propDiffRedundant,y=Probability,color=propDiffNoun)) +
  # geom_point(position=dodge) +
  geom_point(size=2) +
  # geom_text(aes(label=numCondition)) +
  # geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03,position=dodge) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03) +
  xlab("Proportion of distractors with different redundant property value") +
  ylab("Proportion of redundant modifiers") +
  # scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  scale_color_viridis(name="Proportion of distractors with different noun",begin=.8,end=0,breaks = c(.2,.4,.6)) +
  # scale_shape_manual(name="Proportion of\ndistractors with\ndifferent noun",values=c(0,7,15))
  # scale_alpha_continuous(range=c(.3,1))
  facet_wrap(~RedundantProperty) +
  theme(legend.position="top",legend.margin=margin(b=-20))

ggsave(file="../graphs/redundant_proportions_xprag_french.pdf",width=8,height=4.5)


#COLOR SAME SAME: 
# .2 (propDiffNoun), .4 (propDiffRedundant)
#COLOR DIFF DIFF: 
# .6 (propDiffNoun), .8 (propDiffRedundant)




########## ENGLISH ################
# READ DATA
# # (dummy data for analysis pipeline creation)

d_eng = read_delim("../../../../../data/ENGLISH2022_summer/nounInformative/main/main_data_exp1.tsv", delim = "\t")

condition_info = read_csv("../../../data/condition-information.csv")

d_eng = d_eng %>% 
  left_join(condition_info,by=c("condition","NumDistractors"))

# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY
agr <- d_eng %>%
  mutate(Condition = case_when(
    TrialType == "target" & DistractorsNoun == "no_extras" ~ "base",
    TrialType == "control" ~ ControlType,
    TRUE ~ paste(DistractorsNoun,"_",DistractorsRedProp,"",sep=""))) %>% 
  select(redundant,RedundantProperty,Condition,TrialType) %>%
  # mutate(Condition = case_when(
  # NumDistractors == 3 ~ "base",
  # TRUE ~ paste(DistractorsNoun,"_noun/",DistractorsRedProp,"_redundantvalue",sep=""))) %>% 
  #mutate(Redundant = case_when(redUtterance == "redundant" ~ 1,
  #TRUE ~ 0)) %>% 
  # pivot_longer(redUtterance,names_to="Utterance",values_to="Mentioned",-Redundant_Property,-NumDistractors,-Distractors_Noun,-Distractors_RedProp) %>%
  group_by(RedundantProperty,TrialType,Condition) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high) %>% 
  mutate(Condition = fct_relevel(Condition, "noun_sufficient","size_redundant","color_redundant"),
         RedundantProperty=fct_recode(RedundantProperty,color="color redundant",size="size redundant"))


ggplot(agr, aes(x=Condition,y=Probability,color=RedundantProperty,group=1)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  xlab("Condition") +
  ylab("Proportion of over-modification") +
  scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  facet_wrap(~TrialType,scales="free") +
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))

ggsave(file="../graphs/redundant_proportions_english.pdf",width=8,height=7)



# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY
agr <- d_eng %>%
  mutate(Condition = case_when(
    TrialType == "target" & DistractorsNoun == "no_extras" ~ "base",
    TrialType == "control" ~ ControlType,
    TRUE ~ paste(DistractorsNoun,"_",DistractorsRedProp,"",sep=""))) %>% 
  select(redundant,RedundantProperty,Condition,TrialType,NumDistractors,SameSize,SameColor,SameNoun) %>%
  group_by(RedundantProperty,TrialType,Condition,NumDistractors,SameSize,SameColor,SameNoun) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high) %>% 
  mutate(Condition = fct_relevel(Condition, "noun_sufficient","size_redundant","color_redundant"),
         RedundantProperty=fct_recode(RedundantProperty,color="color redundant",size="size redundant"))

agr$DiffSize = agr$NumDistractors - agr$SameSize
agr$DiffColor = agr$NumDistractors - agr$SameColor
agr$DiffNoun = agr$NumDistractors - agr$SameNoun

# SIZE COLOR NOUN
agr$propDiffNoun = round(agr$DiffNoun / agr$NumDistractors,2)
agr = agr %>% 
  mutate(propDiffRedundant = case_when(RedundantProperty == "color" ~ DiffColor / NumDistractors,
                                       RedundantProperty == "size" ~ DiffSize / NumDistractors,
                                       TRUE ~ 555))

agr$charpropDiffNoun = as.factor(as.character(agr$propDiffNoun))

ggplot(agr %>% filter(TrialType == "target") %>% droplevels(), aes(x=propDiffRedundant,y=Probability,color=propDiffNoun)) +
  # geom_point(position=dodge) +
  geom_point(size=2) +
  # geom_text(aes(label=numCondition)) +
  # geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03,position=dodge) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03) +
  xlab("Proportion of distractors with different redundant property value") +
  ylab("Proportion of redundant modifiers") +
  # scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  scale_color_viridis(name="Proportion of distractors with different noun",begin=.8,end=0,breaks = c(.2,.4,.6)) +
  # scale_shape_manual(name="Proportion of\ndistractors with\ndifferent noun",values=c(0,7,15))
  # scale_alpha_continuous(range=c(.3,1))
  facet_wrap(~RedundantProperty) +
  theme(legend.position="top",legend.margin=margin(b=-20))
ggsave(file="../graphs/redundant_proportions_xprag_english.pdf",width=8,height=4.5)

################################################
# BAYESIAN MIXED EFFECTS LOGISTIC REGRESSION
################################################

#read french data
d_french <- read_delim("../../../../../data/FRENCH/nounInformative/main/data_exp1.tsv", delim = "\t")
d_french$Language <- "French"
d_french = d_french %>% 
  mutate(NounMentioned = case_when(typeMentioned == TRUE ~ "noun",
                                   TRUE ~ "no noun")) %>% 
  mutate(RedundantProperty = fct_recode(RedundantProperty, "color"="color redundant","size"="size redundant"))

d_french = d_french %>% 
  select(condition,NumDistractors,RedundantProperty,gameid,redUtterance,ItemID,Trial,TrialType,Language,redundant)

nrow(d_french) # 847 data points before exclusion of filler trials

# read english data
d_eng = read_delim("../../../../../data/ENGLISH2022_summer/nounInformative/main/main_data_exp1.tsv", delim = "\t")
d_eng$Language <- "English"
d_eng = d_eng %>% 
  mutate(NounMentioned = case_when(typeMentioned == TRUE ~ "noun",
                                   TRUE ~ "no noun"))
d_eng = d_eng %>% 
  select(condition,NumDistractors,RedundantProperty,gameid,redUtterance,ItemID,Trial,TrialType,Language,redundant)

nrow(d_eng) # 1451 data points before exclusion of filler trials

d = bind_rows(d_french,d_eng) # might want to eventually add additional languages here

# read external condition information
condition_info = read_csv("../../../data/condition-information.csv")

d = d %>% 
  left_join(condition_info,by=c("condition","NumDistractors"))

d$DiffSize = d$NumDistractors - d$SameSize
d$DiffColor = d$NumDistractors - d$SameColor
d$DiffNoun = d$NumDistractors - d$SameNoun

# proportion of distractors with different noun (one proxy for redundant property informativeness)
d$propDiffNoun = round(d$DiffNoun / d$NumDistractors,2)
# proportion of distractors with different redundant property value (a second proxy for redundant property informativeness)
d = d %>% 
  mutate(propDiffRedundant = case_when(RedundantProperty == "color" ~ DiffColor / NumDistractors,
                                       RedundantProperty == "size" ~ DiffSize / NumDistractors,
                                       TRUE ~ 555))

# prepare french dataset for analysis
dm <- d %>% 
  filter(TrialType == "target" & Language == "French") %>% 
  droplevels() %>% 
  mutate(RedundantProperty=fct_relevel(RedundantProperty,"size")) %>% 
  mutate(redUtterance = as.factor(redUtterance), # outcome variable
         cRedundantProperty = as.numeric(as.factor(RedundantProperty)) - mean(as.numeric(as.factor(RedundantProperty))),
         cpropDiffNoun = propDiffNoun - mean(propDiffNoun),
         cpropDiffRedundant = propDiffRedundant - mean(propDiffRedundant),
         gameid = factor(gameid),
         Language = as.factor(Language),
         Item = as.factor(ItemID)) # edited:

contrasts(dm$redUtterance) # contrasts set to predict redundancy
contrasts(as.factor(dm$RedundantProperty)) # ref level: size

# the model with the full random effects structure (which can't run on this few data points)
m_fr = glmer(redUtterance ~ cRedundantProperty*cpropDiffNoun*cpropDiffRedundant + (1+cRedundantProperty|gameid) + (1|Item), data=dm, family="binomial",glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
summary(m_fr)

# prepare english dataset for analysis
dm <- d %>% 
  filter(TrialType == "target" & Language == "English") %>% 
  droplevels() %>% 
  mutate(RedundantProperty=fct_relevel(RedundantProperty,"size")) %>% 
  mutate(redUtterance = as.factor(redUtterance), # outcome variable
         cRedundantProperty = as.numeric(as.factor(RedundantProperty)) - mean(as.numeric(as.factor(RedundantProperty))),
         cpropDiffNoun = propDiffNoun - mean(propDiffNoun),
         cpropDiffRedundant = propDiffRedundant - mean(propDiffRedundant),
         gameid = factor(gameid),
         Language = as.factor(Language),
         Item = as.factor(ItemID)) # edited:

contrasts(dm$redUtterance) # contrasts set to predict redundancy
contrasts(as.factor(dm$RedundantProperty)) # ref level: size redundant

# the model with the full random effects structure (which can't run on this few data points)
m_eng = glmer(redUtterance ~ cRedundantProperty*cpropDiffNoun*cpropDiffRedundant + (1+cRedundantProperty|gameid) + (1|Item), data=dm, family="binomial",glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
summary(m_eng)


# prepare joint dataset for analysis
# prepare english dataset for analysis
dm <- d %>% 
  filter(TrialType == "target") %>% 
  droplevels() %>% 
  mutate(RedundantProperty=fct_relevel(RedundantProperty,"size")) %>% 
  mutate(Language=fct_relevel(as.factor(Language),"French")) %>% 
  mutate(redUtterance = as.factor(redUtterance), # outcome variable
         cRedundantProperty = as.numeric(as.factor(RedundantProperty)) - mean(as.numeric(as.factor(RedundantProperty))),
         cpropDiffNoun = propDiffNoun - mean(propDiffNoun),
         cpropDiffRedundant = propDiffRedundant - mean(propDiffRedundant),
         gameid = factor(gameid),
         cLanguage = as.numeric(as.factor(Language)) - mean(as.numeric(as.factor(Language))),
         Item = as.factor(ItemID)) # edited:

contrasts(dm$redUtterance) # contrasts set to predict redundancy
contrasts(as.factor(dm$RedundantProperty)) # ref level: size redundant
contrasts(as.factor(dm$Language)) # ref level: French

# the model with the full random effects structure (which can't run on this few data points)
m = glmer(redUtterance ~ cRedundantProperty*cpropDiffNoun*cpropDiffRedundant*cLanguage + (1+cRedundantProperty|gameid) + (1|Item), data=dm, family="binomial",glmerControl(optimizer = "bobyqa", optCtrl = list(maxfun = 100000)))
summary(m)


# plot both languages in one figure for xprag
# PLOT PROPORTION OF REDUNDANT UTTERANCES BY REDUNDANT PROPERTY
agr <- dm %>%
  group_by(RedundantProperty,propDiffNoun,propDiffRedundant,Language) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high)

ggplot(agr, aes(x=propDiffRedundant,y=Probability,color=propDiffNoun)) +
  # geom_point(position=dodge) +
  geom_point(size=2) +
  # geom_text(aes(label=numCondition)) +
  # geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03,position=dodge) +
  geom_errorbar(aes(ymin=YMin,ymax=YMax),width=.03) +
  # xlab("Proportion of distractors with different redundant property value") +
  xlab("Informativeness of redundant property") +
  ylab("Proportion of redundant modifiers") +
  # scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  # scale_color_viridis(name="Proportion of distractors with different noun",begin=.8,end=0,breaks = c(.2,.4,.6)) +
  scale_color_viridis(name="Informativeness of noun",begin=.8,end=0,breaks = c(.2,.4,.6)) +  
  # scale_shape_manual(name="Proportion of\ndistractors with\ndifferent noun",values=c(0,7,15))
  # scale_alpha_continuous(range=c(.3,1))
  facet_grid(Language~RedundantProperty) +
  theme(legend.position="top",legend.margin=margin(b=-20))
# ggsave(file="../graphs/redundant_proportions_xprag.pdf",width=8,height=6)
ggsave(file="../graphs/redundant_proportions_xprag.png",width=6,height=5)


