# plots the model predictions obtained by Angelique and Manh in summer 2022, documented here: https://docs.google.com/spreadsheets/d/1cj2Y4GLFNQPoW1eoIkCFzxrdtzFEOaPGDMvpjqP4E5k/edit?usp=sharing

# for contexts, see slack channel / grant

library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

d = read_csv("../data/data.csv",skip_empty_rows=TRUE) %>% 
  drop_na()
summary(d)
nrow(d)

# CONTEXT 1A AND 1B
# 3 pins varying in color and size, noun uninformative
# 1A: "color-redundant"
# 1B: "size-redundant"    
d_noun_uninf = d %>% 
  filter(Context %in% c("1A", "1B")) %>% 
  mutate(ContextType = case_when(  
    Context == "1A" ~ "Redundant color adjective",
    Context == "1B" ~ "Redundant size adjective",    
    TRUE ~ "other")) %>% 
  mutate(UtteranceType = case_when(
    Language == "English" & Utterance == "small blue pin" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin blue and small" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin small and blue" ~ "redundant",
    Language == "French" & Utterance == "small pin blue" ~ "redundant",    
    Language == "Spanish" & Utterance == "pin blue small" ~ "redundant",
    TRUE ~ "other"
  )) %>% 
  filter(UtteranceType == "redundant") %>% 
  group_by(Language, ContextType,Semantics, Utility) %>% 
  summarize(RedundantProbability = sum(Probability)) %>% 
  ungroup() %>% 
  mutate(Semantics = fct_relevel(Semantics, "Discrete"))

dodge = position_dodge(.9)

ggplot(d_noun_uninf, aes(x=Language,y=RedundantProbability,fill=ContextType)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200"),name="") +
  facet_grid(Utility~Semantics) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())

ggsave(file="../graphs/noun-uninformative.pdf",width=7,height=5)

# just spanish and english
d_noun_uninf = d %>% 
  filter(Context %in% c("1A", "1B") & Language %in% c("Spanish","English")) %>% 
  mutate(ContextType = case_when(  
    Context == "1A" ~ "Redundant color adjective",
    Context == "1B" ~ "Redundant size adjective",    
    TRUE ~ "other")) %>% 
  mutate(UtteranceType = case_when(
    Language == "English" & Utterance == "small blue pin" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin blue and small" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin small and blue" ~ "redundant",
    Language == "French" & Utterance == "small pin blue" ~ "redundant",    
    Language == "Spanish" & Utterance == "pin blue small" ~ "redundant",
    TRUE ~ "other"
  )) %>% 
  filter(UtteranceType == "redundant") %>% 
  group_by(Language, ContextType,Semantics, Utility) %>% 
  summarize(RedundantProbability = sum(Probability)) %>% 
  ungroup() %>% 
  mutate(Semantics = fct_relevel(Semantics, "Discrete"))

dodge = position_dodge(.9)

ggplot(d_noun_uninf, aes(x=Language,y=RedundantProbability,fill=ContextType)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200")) +
  facet_grid(Utility~Semantics) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(legend.position="bottom",axis.title.x=element_blank(),legend.title=element_blank(),legend.box.margin=margin(-10,-10,-10,-10))
ggsave(file="../graphs/noun-uninformative-sp-en.pdf",width=4,height=4)
#ggsave(file="../../_project_description/images/noun-uninformative-sp-en.pdf",width=4,height=3.8)


# CONTEXT 2A AND 2B
# 3 pins plus extra object varying in color and size, noun necessary
# 1A: "color-redundant"
# 1B: "size-redundant"   
check_sums = d %>% 
  filter(Context %in% c("2A", "2B")) %>% 
  group_by(Language, Context,Semantics, Utility) %>% 
  summarize(Sum = sum(Probability))

# print out the cases where probabilities don't add to 1 (indicates manual error in data entry)
check_sums %>% 
  filter(Sum < .99)

d_noun_nec = d %>% 
  filter(Context %in% c("2A", "2B")) %>% 
  mutate(ContextType = case_when(  
    Context == "2A" ~ "Redundant color adjective",
    Context == "2B" ~ "Redundant size adjective",    
    TRUE ~ "other")) %>% 
  mutate(UtteranceType = case_when(
    Language == "English" & Utterance == "small blue pin" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin blue and small" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin small and blue" ~ "redundant",
    Language == "French" & Utterance == "small pin blue" ~ "redundant",    
    Language == "Spanish" & Utterance == "pin blue small" ~ "redundant",
    TRUE ~ "other"
  )) %>% 
  filter(UtteranceType == "redundant") %>% 
  group_by(Language, ContextType,Semantics, Utility) %>% 
  summarize(RedundantProbability = sum(Probability)) %>% 
  ungroup() %>% 
  mutate(Semantics = fct_relevel(Semantics, "Discrete"))

dodge = position_dodge(.9)

ggplot(d_noun_nec, aes(x=Language,y=RedundantProbability,fill=ContextType)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200"),name="") +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  facet_grid(Utility~Semantics) +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="../graphs/noun-necessary.pdf",width=5.5,height=4)


ggplot(d_noun_nec %>% filter(Semantics == "Continuous"), aes(x=Language,y=RedundantProbability,fill=ContextType)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200"),name="") +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  facet_wrap(~Utility,nrow=2) +
  theme(legend.position="bottom",axis.title.x=element_blank())
ggsave(file="../graphs/noun-necessary-cont.pdf",width=3.5,height=4)


# CONTEXT 3A & 3B
# 1 blue pin plus 3 other objects of varying colors, noun-informative, color-redundant (Rubio-Fernandez style)
# 1 small pin plus 3 other objects of different size, noun-informative, size-redundant (Rubio-Fernandez style)

# hacky stuff you did when utterance space wasn't yet pruned
# d_noun_inf_color_red = d %>% 
#   filter(Context %in% c("3A")) %>% 
#   filter(!Utterance %in% c("small pin","pin small","small blue pin","small pin blue","pin blue small","pin blue and small","pin small and blue")) %>% 
#   mutate(UtteranceType = case_when(
#     Language == "English" & Utterance == "blue pin" ~ "redundant",
#     Language == "Vietnamese" & Utterance == "pin blue" ~ "redundant",
#     Language == "French" & Utterance == "pin blue" ~ "redundant",
#     Language == "Spanish" & Utterance == "pin blue" ~ "redundant",
#     TRUE ~ "minimal"
#   )) 
#   
# d_noun_inf_size_red = d %>% 
#   filter(Context %in% c("3B")) %>% 
#   filter(!Utterance %in% c("blue pin","pin blue","small blue pin","small pin blue","pin blue small","pin blue and small","pin small and blue")) %>%  
#   mutate(UtteranceType = case_when(
#     Language == "English" & Utterance == "small pin" ~ "redundant",
#     Language == "Vietnamese" & Utterance == "pin small" ~ "redundant",
#     Language == "French" & Utterance == "small pin" ~ "redundant",    
#     Language == "Spanish" & Utterance == "pin small" ~ "redundant",
#     TRUE ~ "minimal"
#   )) 
# 
# d_noun_inf = bind_rows(d_noun_inf_color_red,d_noun_inf_size_red) %>% 
#   mutate(ContextType = case_when(  
#   Context == "3A" ~ "Redundant color adjective",
#   Context == "3B" ~ "Redundant size adjective",    
#   TRUE ~ "other"))
# 
# sums = d_noun_inf %>% 
#   group_by(Language,ContextType,Semantics,Utility) %>% 
#   summarize(Sum=sum(Probability))
# 
# d_noun_inf = d_noun_inf %>% 
#   left_join(sums, by=c("Language","ContextType","Semantics","Utility")) %>% 
#   mutate(Probability = Probability / Sum) %>%   
#   filter(UtteranceType == "redundant") %>% 
#   group_by(Language, ContextType,Semantics, Utility) %>% 
#   summarize(RedundantProbability = sum(Probability)) %>% 
#   ungroup() %>% 
#   mutate(Semantics = fct_relevel(Semantics, "Discrete")) %>% 
#   complete(Language,ContextType,Semantics,Utility) %>% 
#   mutate(RedundantProbability = replace_na(RedundantProbability,0))

check_sums = d %>% 
  filter(Context %in% c("3A", "3B")) %>% 
  group_by(Language, Context,Semantics, Utility) %>% 
  summarize(Sum = sum(Probability))

# print out the cases where probabilities don't add to 1 (indicates manual error in data entry)
check_sums %>% 
  filter(Sum < .99)

d_noun_inf = d %>% 
  filter(Context %in% c("3A", "3B")) %>% 
  mutate(ContextType = case_when(  
    Context == "3A" ~ "Redundant color adjective",
    Context == "3B" ~ "Redundant size adjective",    
    TRUE ~ "other")) %>% 
  mutate(UtteranceType = case_when(
    Language == "English" & Utterance %in% c("blue pin","small pin") ~ "redundant",
    Language == "Vietnamese" & Utterance %in% c("pin blue","pin small") ~ "redundant",
    Language == "French" & Utterance %in% c("pin blue","small pin") ~ "redundant",    
    Language == "Spanish" & Utterance %in% c("pin blue","pin small") ~ "redundant",
    TRUE ~ "other"
  )) %>% 
  filter(UtteranceType == "redundant") %>% 
  mutate(RedundantProbability = Probability) %>% 
  mutate(Semantics = fct_relevel(Semantics, "Discrete"))

dodge = position_dodge(.9)

# weird results, mostly 50-50??
ggplot(d_noun_inf, aes(x=Language,y=RedundantProbability,fill=ContextType)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200"),name="") +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  facet_grid(Utility~Semantics) +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="../graphs/noun-informative-prunedspace.pdf",width=7,height=5)


# CONTEXT 4
# 3 pins plus 1 other object. target pin requires either color OR size to be mentioned in addition to type. color AND size jointly are redundant. noun-necessary, joint-properties-redundant 

check_sums = d %>% 
  filter(Context %in% c("4")) %>% 
  group_by(Language, Context,Semantics, Utility) %>% 
  summarize(Sum = sum(Probability))

# print out the cases where probabilities don't add to 1 (indicates manual error in data entry)
check_sums %>% 
  filter(Sum < .99)

d_noun_nec_joint_redundant = d %>% 
  filter(Context %in% c("4")) %>% 
  mutate(ContextType = case_when(  
    Context == "4" ~ "Redundant joint color and size adjectives",
    TRUE ~ "other")) %>% 
  mutate(UtteranceType = case_when(
    Language == "English" & Utterance == "small blue pin" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin blue and small" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin small and blue" ~ "redundant",
    Language == "French" & Utterance == "small pin blue" ~ "redundant",    
    Language == "Spanish" & Utterance == "pin blue small" ~ "redundant",
    TRUE ~ "other"
  )) %>% 
  filter(UtteranceType == "redundant") %>% 
  group_by(Language, ContextType,Semantics, Utility) %>% 
  summarize(RedundantProbability = sum(Probability)) %>% 
  ungroup() %>% 
  mutate(Semantics = fct_relevel(Semantics, "Discrete"))

dodge = position_dodge(.9)

ggplot(d_noun_nec_joint_redundant, aes(x=Language,y=RedundantProbability,fill=ContextType)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#55C667FF"),name="") +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  facet_grid(Utility~Semantics) +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="../graphs/noun-necessary-join-redundant.pdf",width=5,height=5)


# CONTEXT 5A and 5B (like 1A AND 1B, but with 3 extra big red pins, ie increased scene variation)
# 6 pins varying in color and size, noun uninformative
# 5A: "color-redundant"
# 5B: "size-redundant"    
check_sums = d %>% 
  filter(Context %in% c("1A", "1B","5A","5B")) %>% 
  group_by(Language, Context,Semantics, Utility) %>% 
  summarize(Sum = sum(Probability))

# print out the cases where probabilities don't add to 1 (indicates manual error in data entry)
check_sums %>% 
  filter(Sum < .99)

d_noun_uninf_scenevar = d %>% 
  filter(Context %in% c("1A", "1B","5A","5B")) %>% 
  mutate(ContextType = case_when(  
    Context == "1A" ~ "color",
    Context == "1B" ~ "size",    
    Context == "5A" ~ "color",
    Context == "5B" ~ "size",        
    TRUE ~ "other")) %>% 
  mutate(SceneVariation = case_when(
    Context %in% c("1A","1B") ~ "low",
    Context %in% c("5A","5B") ~ "high",    
    TRUE ~ "other"
  )) %>% 
  mutate(UtteranceType = case_when(
    Language == "English" & Utterance == "small blue pin" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin blue and small" ~ "redundant",
    Language == "Vietnamese" & Utterance == "pin small and blue" ~ "redundant",
    Language == "French" & Utterance == "small pin blue" ~ "redundant",    
    Language == "Spanish" & Utterance == "pin blue small" ~ "redundant",
    Language == "English" & Context %in% c("1A","5A") & Utterance == "blue pin" ~ "redundant", # include underinformative one-feature mentions
    Language == "English" & Context %in% c("1B","5B") & Utterance == "small pin" ~ "redundant", # include underinformative one-feature mentions    
    Language == "Vietnamese" & Context %in% c("1A","5A") & Utterance == "pin blue" ~ "redundant",
    Language == "Vietnamese" & Context %in% c("1B","5B") & Utterance == "pin small" ~ "redundant",    
    Language == "French" & Context %in% c("1A","5A") & Utterance == "pin blue" ~ "redundant",    
    Language == "French" & Context %in% c("1B","5B") & Utterance == "small pin" ~ "redundant",        
    Language == "Spanish" & Context %in% c("1A","5A") & Utterance == "pin blue" ~ "redundant",
    Language == "Spanish" & Context %in% c("1B","5B") & Utterance == "pin small" ~ "redundant",    
    TRUE ~ "other"
  )) %>% 
  filter(UtteranceType == "redundant") %>% 
  group_by(Language, ContextType,Semantics, Utility,SceneVariation) %>% 
  summarize(RedundantProbability = sum(Probability)) %>% 
  ungroup() %>% 
  mutate(Semantics = fct_relevel(Semantics, "Discrete"))

dodge = position_dodge(.9)

ggplot(d_noun_uninf_scenevar, aes(x=Language,y=RedundantProbability,fill=ContextType,alpha=SceneVariation)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200"),name="") +
  scale_alpha_discrete(range=c(.3,1)) +
  facet_grid(Utility~Semantics) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="../graphs/noun-uninformative-scenevar.pdf",width=8,height=4.5)

# generate only the continuous-semantics version of this plot
d_cont = d_noun_uninf_scenevar %>% 
  filter(Semantics == "Continuous") %>% 
  droplevels()

ggplot(d_cont, aes(x=Language,y=RedundantProbability,fill=ContextType,alpha=SceneVariation)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values=c("#4287f5","#fff200"),name="Redundant property") +
  scale_alpha_discrete(range=c(.3,1),name="Scene variation") +
  facet_wrap(~Utility,nrow=2) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(legend.position="bottom",axis.title.x=element_blank(),legend.text=element_text(size=10),legend.key.size = unit(.5, "cm")) +
  guides(fill = guide_legend(title.position = "top", title.hjust = 0.5),alpha = guide_legend(title.position = "top", title.hjust = 0.5))
#ggsave(file="../../_project_description/images/noun-uninformative-scenevar-cont.pdf",width=4,height=4)
