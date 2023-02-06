# plots the model predictions obtained by Angelique and Manh in summer 2022

library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)
library(sjmisc)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

d = read_csv("model_output/w23_scenes_out.csv",skip_empty_rows=TRUE) %>% 
  drop_na()
summary(d)

dtest = read_csv("model_output/w23_three_pin_test.csv",skip_empty_rows=TRUE) %>% 
  drop_na()
#view(d)
nrow(d)

addLang = function(df){
  df = df %>% mutate(LangAbr = case_when (
  Language == "0" ~ "EN",
  Language == "1" ~ "SP",
  Language == "2" ~ "FR",
  Language == "3" ~ "VN",
))
  return(df)
}
d = addLang(d)
d <- d %>% filter(global_inc == "inc" | (global_inc == "global" & Language == 0))
dodge = position_dodge(.9)
# color-blind-friendly palette
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


sanityMaker = function(df){
  d_size_prop = df %>%
    mutate(Redundancy = case_when(  
      grepl("color",Name) ~ "Color",
      grepl("size",Name) ~ "Size",
      TRUE ~ "other")) %>%
    mutate(ModelType = case_when(
      (size_noise!= 1 & global_inc == "global") ~ "Continuous global",
      (size_noise == 1 & global_inc == "global") ~ "Discrete global",
      (size_noise!= 1 & global_inc == "inc") ~ "Continuous incremental",
      (size_noise== 1 & global_inc == "inc") ~ "Discrete incremental",
    ))
}
dtest <- sanityMaker(dtest)
dtest$ModelType_f = factor(dtest$ModelType, levels=c('Discrete global','Continuous global','Discrete incremental','Continuous incremental'))
sanityCheck = function(plot) {
  ggplot(plot, aes(x=Redundancy,y=output, fill = Redundancy))+
    geom_bar(stat="identity")+
    scale_fill_manual(values =cbPalette) +
    facet_wrap(~ModelType_f, nrow = 2) +
    ylim(0,1) +
    labs(y= "Probability of redundant referring expression", color = "Redundant Property", title= "Three pins") +
    theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
  ggsave(filename = "three_pin_test.jpg", path = "../../graphs/w23/tester", device = "jpg")
}
sanityCheck(dtest)

byColorProp = function(df){
  d_color_prop = df %>%
    mutate(Redundancy = case_when(  
      grepl("color",Name) ~ "Color",
      grepl("size",Name) ~ "Size",
      TRUE ~ "other")) %>%
    mutate(Prop = case_when(
      grepl("base",Name) ~ "0.66",
      grepl("three_color",Name) ~ "0.5",
      grepl("three_size",Name) ~ "1",
      (grepl("color",Name) & (grepl("diff_same",Name)|grepl("same_same",Name))) ~ "0.4",
      (grepl("color",Name) & (grepl("diff_diff",Name)|grepl("same_diff",Name))) ~ "0.8",
      grepl("size", Name) ~ "0.8",
      TRUE ~ "other"
    )) %>%
    group_by(Language, global_inc, alpha) %>% 
    ungroup()
  d_color_prop$Prop <- as.numeric(d_color_prop$Prop)
  return(d_color_prop)
}

byNounProp = function(df){
  d_noun_prop = df %>%
    mutate(Redundancy = case_when(  
      grepl("color",Name) ~ "Color",
      grepl("size",Name) ~ "Size",
      TRUE ~ "other")) %>%
    mutate(Prop = case_when(
      grepl("base",Name) ~ "0.33",
      grepl("three",Name) ~ "0",
      grepl("six_(color|size)_same",Name) ~ "0.2",
      grepl("six_(color|size)_diff",Name) ~ "0.6",
      TRUE ~ "other"
    )) %>%
    group_by(Language, global_inc, alpha) %>% 
    ungroup()
  d_noun_prop$Prop <- as.numeric(d_noun_prop$Prop)
  return(d_noun_prop)
}

bySizeProp = function(df){
  d_size_prop = df %>%
    mutate(Redundancy = case_when(  
      grepl("color",Name) ~ "Color",
      grepl("size",Name) ~ "Size",
      TRUE ~ "other")) %>%
    mutate(Prop = case_when(
      grepl("base",Name) ~ "0.66",
      grepl("three_color",Name) ~ "1",
      grepl("three_size",Name) ~ "0.5",
      grepl("six_color",Name) ~ "0.8",
      grepl("six_size_(same|diff)_diff",Name) ~ "0.8",
      grepl("six_size_(same|diff)_same",Name) ~ "0.4",
      TRUE ~ "other"
    ))
  d_size_prop$Prop <- as.numeric(d_size_prop$Prop)
  return(d_size_prop)
}

makePlot = function(plot,plotType, filename, filepath){
  ggplot(plot, aes(x=Prop,color=factor(Redundancy),y=output, size = 3)) +
    #set_theme(base=theme_bw())
    geom_point(stat="identity") +
    scale_fill_manual(values =cbPalette) +
    facet_wrap(~LangAbr, nrow = 1) +
    ylim(0,1) +
    labs(y= "Probability of redundant referring expression", color = "Redundant Property", title= plotType) +
    theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
  ggsave(filename = filename, path = sprintf("../../graphs/w23/%s",filepath), device = "jpg")
  }

#NOUN UNINFORMATIVE (3 pins):
d_three <- d %>% filter(grepl("three",Name))

#DISCRETE GLOBAL
d_global_disc <- d_three %>% filter(global_inc == "global") %>%
  filter(color_noise == "1") %>% filter(Language == "0")
#By proportion of color distractors
d_color_prop <- byColorProp(d_global_disc)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion", "global_disc.jpg","three_pins/color_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_global_disc)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion", "global_disc.jpg","three_pins/size_prop")

#CONTINUOUS GLOBAL
d_global_cont <- d_three %>% filter(global_inc == "global") %>%
  filter(color_noise == "0.95")
#Noun noise --> 0.99
d_global_cont_1 <- d_global_cont %>% filter(noun_noise == "0.99")
#By proportion of color distractors
d_color_prop <- byColorProp(d_global_cont_1)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Low noun noise", "global_cont_1.jpg","three_pins/color_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_global_cont_1)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Low noun noise", "global_cont_1.jpg","three_pins/size_prop")

#Noun noise --> 0.9
d_global_cont_2 <- d_global_cont %>% filter(noun_noise == "0.9")
#By proportion of color distractors
d_color_prop <- byColorProp(d_global_cont_2)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Noisy noun", "global_cont_2.jpg","three_pins/color_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_global_cont_2)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Noisy noun", "global_cont_2.jpg","three_pins/size_prop")


#DISCRETE INCREMENTAL
d_inc_disc <- d_three %>% filter(global_inc == "inc") %>%
  filter(color_noise == "1")
#By proportion of color distractors
d_color_prop <- byColorProp(d_inc_disc)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion", "inc_disc.jpg","three_pins/color_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_inc_disc)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion", "inc_disc.jpg","three_pins/size_prop")

#CONTINUOUS INCREMENTAL
#Eliminating global trials
d_inc_cont <- d_three %>% filter(global_inc == "inc") %>%
  filter(color_noise == "0.95")
#Noun noise --> 0.99
d_inc_cont_1 <- d_inc_cont %>% filter(noun_noise == "0.99")
#By proportion of color distractors
d_color_prop <- byColorProp(d_inc_cont_1)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Low noun noise", "inc_cont_1.jpg","three_pins/color_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_inc_cont_1)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Low noun noise", "inc_cont_1.jpg","three_pins/size_prop")

#Noun noise --> 0.9
d_inc_cont_2 <- d_inc_cont %>% filter(noun_noise == "0.9")
#By proportion of color distractors
d_color_prop <- byColorProp(d_inc_cont_2)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Noisy noun", "inc_cont_2.jpg","three_pins/color_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_inc_cont_2)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Noisy noun", "inc_cont_2.jpg","three_pins/size_prop")



#EXPERIMENTAL SIDE:

#Eliminating filler trials & three pin scenario
d_exp <- d %>% filter(!grepl("alt", Name))


#DISCRETE GLOBAL
d_global_disc <- d_exp %>% filter(global_inc == "global") %>%
  filter(color_noise == "1") %>% filter(Language == "0")
#By proportion of color distractors
d_color_prop <- byColorProp(d_global_disc)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion", "global_disc.jpg","color_prop")
#By proportion of noun distractors 
d_noun_prop <- byNounProp(d_global_disc)
makePlot(d_noun_prop,"Redundancy Rate vs. Noun Proportion", "global_disc.jpg","noun_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_global_disc)
d_size_prop['Prop'] = d_size_prop['Prop'].astype(float)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion", "global_disc.jpg","size_prop")


#CONTINUOUS GLOBAL
d_global_cont <- d_exp %>% filter(global_inc == "global") %>%
  filter(color_noise == "0.95")
#Noun noise --> 0.99
d_global_cont_1 <- d_global_cont %>% filter(noun_noise == "0.99")
#By proportion of color distractors
d_color_prop <- byColorProp(d_global_cont_1)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Low noun noise", "global_cont_1.jpg","color_prop")
#By proportion of noun distractors 
d_noun_prop <- byNounProp(d_global_cont_1)
makePlot(d_noun_prop,"Redundancy Rate vs. Noun Proportion - Low noun noise", "global_cont_1.jpg","noun_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_global_cont_1)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Low noun noise", "global_cont_1.jpg","size_prop")

#Noun noise --> 0.9
d_global_cont_2 <- d_global_cont %>% filter(noun_noise == "0.9")
#By proportion of color distractors
d_color_prop <- byColorProp(d_global_cont_2)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Noisy noun", "global_cont_2.jpg","color_prop")
#By proportion of noun distractors 
d_noun_prop <- byNounProp(d_global_cont_2)
makePlot(d_noun_prop,"Redundancy Rate vs. Noun Proportion - Noisy noun", "global_cont_2.jpg","noun_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_global_cont_2)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Noisy noun", "global_cont_2.jpg","size_prop")


#DISCRETE INCREMENTAL
d_inc_disc <- d_exp %>% filter(global_inc == "inc") %>%
  filter(color_noise == "1")
#By proportion of color distractors
d_color_prop <- byColorProp(d_inc_disc)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion", "inc_disc.jpg","color_prop")
#By proportion of noun distractors 
d_noun_prop <- byNounProp(d_inc_disc)
makePlot(d_noun_prop,"Redundancy Rate vs. Noun Proportion", "inc_disc.jpg","noun_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_inc_disc)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion", "inc_disc.jpg","size_prop")

#CONTINUOUS INCREMENTAL
#Eliminating global trials
d_inc_cont <- d_exp %>% filter(global_inc == "inc") %>%
  filter(color_noise == "0.95")
#Noun noise --> 0.99
d_inc_cont_1 <- d_inc_cont %>% filter(noun_noise == "0.99")
#By proportion of color distractors
d_color_prop <- byColorProp(d_inc_cont_1)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Low noun noise", "inc_cont_1.jpg","color_prop")
#By proportion of noun distractors 
d_noun_prop <- byNounProp(d_inc_cont_1)
makePlot(d_noun_prop,"Redundancy Rate vs. Noun Proportion - Low noun noise", "inc_cont_1.jpg","noun_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_inc_cont_1)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Low noun noise", "inc_cont_1.jpg","size_prop")

#Noun noise --> 0.9
d_inc_cont_2 <- d_inc_cont %>% filter(noun_noise == "0.9")
#By proportion of color distractors
d_color_prop <- byColorProp(d_inc_cont_2)
makePlot(d_color_prop,"Redundancy Rate vs. Color Proportion - Noisy noun", "inc_cont_2.jpg","color_prop")
#By proportion of noun distractors 
d_noun_prop <- byNounProp(d_inc_cont_2)
makePlot(d_noun_prop,"Redundancy Rate vs. Noun Proportion - Noisy noun", "inc_cont_2.jpg","noun_prop")
#By proportion of size distractors
d_size_prop <- bySizeProp(d_inc_cont_2)
makePlot(d_size_prop,"Redundancy Rate vs. Size Proportion - Noisy noun", "inc_cont_2.jpg","size_prop")


#FILLER TRIALS
d_filler <- d %>% filter(grepl("alt", Name) & !grepl("three", Name))

byType = function(df){
  d_fillers = df %>%
    mutate(Redundancy = case_when(  
      grepl("_color",Name) ~ "Color",
      grepl("_size",Name)~ "Size",
      TRUE ~ "other")) %>%
    mutate(Type = case_when(
      grepl("both",Name) ~ "Noun sufficient",
      grepl("neither",Name) ~ "Both necessary",
      grepl("fcolor",Name) ~ "Color redundant",
      grepl("fsize", Name) ~ "Size redundant",
      TRUE ~ "other"
    )) %>%
    group_by(Language, global_inc, alpha) %>% 
    ungroup()
  return(d_fillers)
}
d_filler <- byType(d_filler)

TypeOrder <- c("Noun sufficient","Size redundant","Color redundant","Both necessary")
makePlotFiller = function(plot,plotType, filename, filepath){
  ggplot(plot, aes(x=factor(Type,TypeOrder),y=output,)) +
    #set_theme(base=theme_bw())
    geom_bar(stat="identity") +
    scale_fill_manual(values =cbPalette) +
    facet_wrap(~LangAbr, nrow = 1) +
    ylim(0,1) +
    labs(y= "Probability of redundant referring expression", title= plotType) +
    theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
  ggsave(filename = filename, path = sprintf("../../graphs/w23/%s",filepath), device = "jpg")
}

#Discrete global
d_global_disc <- d_filler %>% filter(global_inc == "global") %>%
  filter(color_noise == "1")
makePlotFiller(d_global_disc,"Probability of redundant referring expression vs. Trial type", "global_disc.jpg","fillers")
#Continuous global
d_global_cont <- d_filler %>% filter(global_inc == "global") %>%
  filter(color_noise == "0.95")
#Low noun noise
d_global_cont_1 <- d_global_cont %>% filter(noun_noise == "0.99")
makePlotFiller(d_global_cont_1,"Probability of redundant referring expression vs. Trial type - low noun noise", "global_cont_1.jpg","fillers")
#High noun noise
d_global_cont_2 <- d_global_cont %>% filter(noun_noise == "0.9")
makePlotFiller(d_global_cont_2,"Probability of redundant referring expression vs. Trial type - noisy noun", "global_cont_2.jpg","fillers")


#Discrete incremental
d_inc_disc <- d_filler %>% filter(global_inc == "inc") %>%
  filter(color_noise == "1")
makePlotFiller(d_inc_disc,"Probability of redundant referring expression vs. Trial type", "inc_disc.jpg","fillers")

#Continuous incremental
d_inc_cont <- d_filler %>% filter(global_inc == "inc") %>%
  filter(color_noise == "0.95")
#Low noun noise
d_inc_cont_1 <- d_inc_cont %>% filter(noun_noise == "0.99")
makePlotFiller(d_inc_cont_1,"Probability of redundant referring expression vs. Trial type - low noun noise", "inc_cont_1.jpg","fillers")
#High noun noise
d_inc_cont_2 <- d_inc_cont %>% filter(noun_noise == "0.9")
makePlotFiller(d_inc_cont_2,"Probability of redundant referring expression vs. Trial type - noisy noun", "inc_cont_2.jpg","fillers")

#To do: fix proportions to be numbers and not strings
num_order = c("2/5","1/2","2/3","1")





#Old code for reference






d_inc_all = d_all_new %>%
  filter(global_inc=="inc") %>%
  mutate(ContextType = case_when(  
   grepl("low",Name) ~ "Low variation",
   grepl("",Name) ~ "Medium variation",
   grepl("high",Name) ~ "",
    TRUE ~ "other")) %>%
  mutate(sceneName = case_when(  
    grepl("3",Name) ~ "Scene 3",
    grepl("4",Name) ~ "Scene 4",
    TRUE ~ "other") )
ggplot(d_inc_all, aes(x=LangAbr,y=output, fill = factor(ContextType,level = type_order))) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values =c("blue","yellow","red")) +
  facet_wrap(~sceneName, nrow = 1) +
  ylim(0,1) +
  labs(y = "Probability of redundant referring expression", fill = "Variation", x = "Language") +
  theme(legend.position="bottom")

ggsave(file="test_graph_3_4_inc.pdf",width=7,height=5)

#True experiment section
d_exp_all = d_exp_all %>%
  filter(global_inc=="inc") %>%
  filter(LangAbr != "VN" & LangAbr != "SP") %>%
  mutate(ContextType = case_when(  
    grepl("low",Name) ~ "Base scene",
    grepl("3b",Name) ~ "same/same",
    grepl("4b",Name) ~ "diff/same",
    grepl("3a",Name) ~ "same/diff",
    grepl("4a",Name) ~ "diff/diff",
    grepl("high",Name) ~ "",
    TRUE ~ "other")) %>%
  mutate(Redundant_Property = case_when(  
      grepl("color",Name) ~ "Color",
      grepl("size",Name) ~ "Size",
      TRUE ~ "other"))
ggplot(d_exp_all, aes(x=ContextType,y=output, fill = Redundant_Property)) +
  theme_bw() +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values =c("#E69F00", "#56B4E9","red")) +
  facet_wrap(~LangAbr, nrow = 2) +
  ylim(0,1) +
  labs(y = "Probability of redundant referring expression", fill = "Redundant Property", x = "Context Type (noun/redundant property)") +
  theme(legend.position="bottom")
#global model
d_exp_all = d_exp_all %>%
  filter(global_inc=="global") %>%
  mutate(ContextType = case_when(  
    grepl("low",Name) ~ "Base scene",
    grepl("3b",Name) ~ "same/same",
    grepl("4b",Name) ~ "diff/same",
    grepl("3a",Name) ~ "same/diff",
    grepl("4a",Name) ~ "diff/diff",
    grepl("high",Name) ~ "",
    TRUE ~ "other")) %>%
  mutate(Redundant_Property = case_when(  
    grepl("color",Name) ~ "Color",
    grepl("size",Name) ~ "Size",
    TRUE ~ "other"))
ggplot(d_exp_all, aes(x=ContextType,y=output, fill = Redundant_Property)) +
  theme_bw() +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values =c("#E69F00", "#56B4E9","red")) +
  #facet_wrap(~LangAbr, nrow = 2) +
  ylim(0,1) +
  labs(y = "Probability of redundant referring expression", fill = "Redundant Property", x = "Context Type (noun/redundant property)") +
  theme(legend.position="bottom")


ggplot(d_no_cost, aes(x=Language,y=output,fill=Grouping)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values =c("#4287f5AA","#fff200AA","#4287f5","#fff200")) +
  facet_wrap(~alpha, nrow = 2) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="no_cost.pdf",width=7,height=5)

ggplot(d_with_cost, aes(x=Language,y=output,fill=Grouping)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values =c("#4287f5AA","#fff200AA","#4287f5","#fff200")) +
  facet_wrap(~alpha, nrow = 2) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="withcost.pdf",width=7,height=5)

type_order = c("Low variation", "Medium variation", "High variation")
ggplot(d_global_5, aes(x=factor(ContextType,level = type_order),y=output,fill=Redundancy)) +
  geom_bar(stat="identity",position=dodge) +
  scale_fill_manual(values =c("#4287f5","#fff200")) +
  facet_wrap(~adj_cost, nrow = 2) +
  ylim(0,1) +
  ylab("Probability of redundant referring expression") +
  theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom",axis.title.x=element_blank())
ggsave(file="withcost.pdf",width=7,height=5)






#Stefan's code below this--->
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
ggsave(file=".pdf",width=4,height=3.8)


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
