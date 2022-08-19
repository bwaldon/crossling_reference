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
d = read_delim("../../../../../data/FRENCH/nounInformative/pilot/data_exp1.tsv", delim = "\t")
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
  filter(TrialType == "target") %>%
  select(redundant,Redundant_Property,NumDistractors,Distractors_Noun,Distractors_RedProp) %>%
  mutate(Condition = case_when(
    NumDistractors == 3 ~ "base",
    TRUE ~ paste(Distractors_Noun,"_noun/",Distractors_RedProp,"_redundantvalue",sep=""))) %>% 
  #mutate(Redundant = case_when(redUtterance == "redundant" ~ 1,
  #TRUE ~ 0)) %>% 
  # pivot_longer(redUtterance,names_to="Utterance",values_to="Mentioned",-Redundant_Property,-NumDistractors,-Distractors_Noun,-Distractors_RedProp) %>%
  group_by(Redundant_Property,Condition) %>%
  summarise(Probability=mean(redundant),ci.low=ci.low(redundant),ci.high=ci.high(redundant)) %>%
  ungroup() %>%
  mutate(YMin = Probability - ci.low, YMax = Probability + ci.high) %>% 
  mutate(Condition = fct_relevel(Condition, "base"),Redundant_Property=fct_recode(Redundant_Property,color="color redundant",size="size redundant"))

ggplot(agr, aes(x=Condition,y=Probability,color=Redundant_Property,group=1)) +
  geom_point() +
  geom_errorbar(aes(ymin=YMin,ymax=YMax)) +
  xlab("Condition") +
  ylab("Probability of redundant modifier") +
  scale_color_manual(name="Redundant\nproperty",values=cbPalette[1:2]) +
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))

ggsave(file="../graphs/redundant_proportions.pdf",width=6,height=7)





# BAYESIAN MIXED EFFECTS LOGISTIC REGRESSION

d_french <- read_delim("../../../../../data/FRENCH/nounInformative/pilot/data_exp1.tsv", delim = "\t")
d_french$Language <- "French"
d_french = d_french %>% 
  mutate(NounMentioned = case_when(typeMentioned == TRUE ~ "noun",
                                   TRUE ~ "no noun"))

d = d_french # might want to eventually add additional languages here

# # CENTER PREDICTORS (NOTE: REFERENCE LEVEL OF FACTORS MAY CHANGE)
d <- d %>% 
  mutate(Redundant_Property = factor(Redundant_Property),
         redUtterance = factor(redUtterance),
         Distractors_Noun = factor(Distractors_Noun),
         Distractors_RedProp = factor(Distractors_RedProp),
         gameid = factor(gameid),
         Language = factor(Language),
         Item = factor(itemID)) # edited:

# different subset analyses:
d_extended = d %>% 
  filter(NumDistractors == 5) %>%  
  filter(TrialType == "target") %>% #edited:
  droplevels()

# first test effects of redundant property and number of distractors on full dataset
centered_number = cbind(d,myCenter(data.frame(d %>% select(Redundant_Property, Trial, NumDistractors )))) #Language))))

contrasts(centered_number$redUtterance)
contrasts(centered_number$Redundant_Property)
#contrasts(centered_number$Language)

# the model with the full random effects structure (which can't run on this few data points)
m_number = glmer(redundant ~ cRedundant_Property*cNumDistractors + cTrial + (1 + cRedundant_Property*cNumDistractors + cTrial|gameid) + (1 + cRedundant_Property*cNumDistractors + cTrial|Item), data=centered_number, family="binomial")
summary(m_number)

# the model with only random intercepts for testing
m_number = glmer(redundant ~ cRedundant_Property*cNumDistractors + cTrial + (1|gameid) + (1|Item), data=centered_number, family="binomial")
summary(m_number)


# now test effects of distractor objects on subset with 6 objects in display
centered_extended = cbind(d_extended,myCenter(data.frame(d_extended %>% select(Redundant_Property, Trial, Distractors_Noun, Distractors_RedProp)))) #Language))))

contrasts(centered_extended$redUtterance)
contrasts(centered_extended$Redundant_Property)
contrasts(centered_extended$Distractors_Noun)
contrasts(centered_extended$Distractors_RedProp)
#contrasts(centered_number$Language)

# the model with the full random effects structure (which can't run on this few data points)
m_extended = glmer(redundant ~ cRedundant_Property*cDistractors_Noun*cDistractors_RedProp + cTrial + (1 + cRedundant_Property*cDistractors_Noun*cDistractors_RedProp + cTrial|gameid) + (1 + cRedundant_Property*cDistractors_Noun*cDistractors_RedProp + cTrial|Item), data=centered_extended, family="binomial")
summary(m_extended)

# the model with only random intercepts for testing
m_extended = glmer(redundant ~ cRedundant_Property*cDistractors_Noun*cDistractors_RedProp + cTrial +  (1|gameid) + (1|Item), data=centered_extended, family="binomial")
summary(m_extended)
