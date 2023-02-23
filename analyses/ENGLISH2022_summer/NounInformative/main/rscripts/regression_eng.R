library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

source("../../../../_shared/regressionHelpers.r")

# READ DATA
# # (dummy data for analysis pipeline creation)
d = read_delim("../../../../../data/ENGLISH2022_summer/main/main_data_exp1.tsv", delim = "\t")
#d_postraw = read_tsv("../../data/SpanishMain/postManualTypoCorrection.tsv") %>% bind_rows(read_tsv("../../data/SpanishMain/postManualTypoCorrection_part2.tsv"))

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
    TRUE ~ paste(DistractorsNoun,"_noun/",DistractorsRedProp,"_redundantvalue",sep=""))) %>% 
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

write.csv(agr,"../../../../../data/ENGLISH2022_summer/main/scene_probabilities.csv")

ggplot(agr, aes(x=Condition,y=Probability,color=RedundantProperty,group=1)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  xlab("Condition") +
  ylab("Proportion of color-and-size mentions") +
  scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  facet_wrap(~TrialType,scales="free") +
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))

ggsave(file="../graphs/redundant_proportions.pdf",width=8,height=7)





# BAYESIAN MIXED EFFECTS LOGISTIC REGRESSION

d_french <- read_delim("../../../../../data/FRENCH/nounInformative/main/data_exp1.tsv", delim = "\t")
d_french$Language <- "French"
d_french = d_french %>% 
  mutate(NounMentioned = case_when(typeMentioned == TRUE ~ "noun",
                                   TRUE ~ "no noun"))

d = d_french # might want to eventually add additional languages here

# # CENTER PREDICTORS (NOTE: REFERENCE LEVEL OF FACTORS MAY CHANGE)
d <- d %>% 
  mutate(RedundantProperty = factor(RedundantProperty),
         redUtterance = factor(redUtterance),
         DistractorsNoun = factor(DistractorsNoun),
         DistractorsRedProp = factor(DistractorsRedProp),
         gameid = factor(gameid),
         Language = factor(Language),
         Item = factor(ItemID)) # edited:

# different subset analyses:
d_extended = d %>% 
  filter(NumDistractors == 5) %>%  
  filter(TrialType == "target") %>% #edited:
  droplevels()

# first test effects of redundant property and number of distractors on full dataset
centered_number = cbind(d,myCenter(data.frame(d %>% select(RedundantProperty, Trial, NumDistractors )))) #Language))))

contrasts(centered_number$redUtterance)
contrasts(centered_number$RedundantProperty)
#contrasts(centered_number$Language)

# the model with the full random effects structure (which can't run on this few data points)
m_number = glmer(redundant ~ cRedundantProperty*cNumDistractors + cTrial + (1 + cRedundantProperty*cNumDistractors + cTrial|gameid) + (1 + cRedundantProperty*cNumDistractors + cTrial|Item), data=centered_number, family="binomial")
summary(m_number)

# the model with only random intercepts for testing
m_number = glmer(redundant ~ cRedundantProperty*cNumDistractors + cTrial + (1|gameid) + (1|Item), data=centered_number, family="binomial")
summary(m_number)


# now test effects of distractor objects on subset with 6 objects in display
centered_extended = cbind(d_extended,myCenter(data.frame(d_extended %>% select(RedundantProperty, Trial, DistractorsNoun, DistractorsRedProp)))) #Language))))

contrasts(centered_extended$redUtterance)
contrasts(centered_extended$RedundantProperty)
contrasts(centered_extended$DistractorsNoun)
contrasts(centered_extended$DistractorsRedProp)
#contrasts(centered_number$Language)

# the model with the full random effects structure (which can't run on this few data points)
m_extended = glmer(redundant ~ cRedundantProperty*cDistractorsNoun*cDistractorsRedProp + cTrial + (1 + cRedundantProperty*cDistractorsNoun*cDistractorsRedProp + cTrial|gameid) + (1 + cRedundantProperty*cDistractorsNoun*cDistractorsRedProp + cTrial|Item), data=centered_extended, family="binomial")
summary(m_extended)

# the model with only random intercepts for testing
m_extended = glmer(redundant ~ cRedundantProperty*cDistractorsNoun*cDistractorsRedProp + cTrial +  (1|gameid) + (1|Item), data=centered_extended, family="binomial")
summary(m_extended)
