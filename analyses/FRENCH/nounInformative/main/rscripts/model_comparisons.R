library(tidyverse)
library(gridExtra)
library(brms)
library(lme4)
library(languageR)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

empirical_fr <- read.csv("../../../../../data/FRENCH/nounInformative/main/scene_probabilities.csv")

empirical_eng <- read.csv("../../../../../data/ENGLISH2022_summer/nounInformative/main/scene_probabilities.csv")

modeling <- read.csv("../../../../../simulations/ang_manh_simulations/series/series2_winter/model_output/w23_scenes_out.csv")
modeling <- modeling %>% filter(!grepl("three",Name))
modeling_fr <- modeling %>% filter(Language == 2 | global_inc == "global")
modeling_eng <- modeling %>% filter(Language == 0)

#NOUN NOISE = 0.99
modeling_fr <- modeling_fr %>% filter(noun_noise != 0.90)
modeling_eng <- modeling_eng %>% filter(noun_noise != 0.90)

getModelType = function(df) {
  d_with_models = df %>%
    mutate(modelType = case_when(  
      (size_noise == "0.8" & global_inc == "inc") ~ "Continuous incremental",
      (size_noise == "0.8" & global_inc == "global") ~ "Continuous global",
      (size_noise == "1" & global_inc == "inc") ~ "Discrete incremental",
      (size_noise == "1" & global_inc == "global") ~ "Discrete global",
      TRUE ~ "other"))
  return(d_with_models)
}
modeling_fr <- getModelType(modeling_fr)
toGraph_fr <- subset(modeling_fr, select= c(Name,modelType,output))
toGraph_fr <- toGraph_fr %>% 
  rename("Model_output" = "output")

modeling_eng <- getModelType(modeling_eng)
toGraph_eng <- subset(modeling_eng, select= c(Name,modelType,output))
toGraph_eng <- toGraph_eng %>% 
  rename("Model_output" = "output")

getProbFromCol_fr = function(row){
  getProbFromName(row["Name"],empirical_fr)
}
getProbFromCol_eng = function(row){
  getProbFromName(row["Name"],empirical_eng)
}

getProbFromName = function(Name,emp){
  cond = "oops"
  redProp = "oops"
  trial = "oops"
  if (grepl("exp",Name)){
    trial = "target"
    if (grepl("color",Name)){
      redProp = "color"}
    else {
      redProp = "size"
    }
    if (grepl("_diff_diff",Name)){
      cond = "diff_noun/diff_redundantvalue"
    }
    else if (grepl("_same_same", Name)){
      cond = "same_noun/same_redundantvalue"
    }
    else if (grepl("_same_diff", Name)){
      cond = "same_noun/diff_redundantvalue"
    }
    else if (grepl("_diff_same", Name)){
      cond = "diff_noun/same_redundantvalue"
    }
    else if (grepl("na_na",Name) & grepl("exp", Name)){
      cond = "base"
    }
  }
  else {
    trial = "control"
    if (grepl("fcolor",Name)){
      redProp = "color"
      cond = "color_redundant"}
    else if(grepl("fsize", Name)) {
      redProp = "size"
      cond = "size_redundant"
    }
    else if (grepl("neither",Name)){
      cond = "both_necessary"
      if (grepl("_color", Name)){
        redProp = "color"
      }
      else {
        redProp = "size"
      }
    }
    else if(grepl("both", Name)){
      cond = "noun_sufficient"
      if (grepl("_color", Name)){
        redProp = "color"
      }
      else {
        redProp = "size"
      }
    }
  }
  prob = emp %>% 
    filter(RedundantProperty == redProp, TrialType == trial, Condition == cond) %>% 
    select(Probability)
  return(prob[1,1])
}

getEmpiricalProb = function(df,lang){
  if (lang == 0){
  d_with_probs = df %>%
    mutate(Probability = apply(df, 1, getProbFromCol_eng)
    )
  }
  if (lang == 2){
    d_with_probs = df %>%
      mutate(Probability = apply(df, 1, getProbFromCol_fr)
      )
  }
  return(d_with_probs)
}

toGraph_fr <- getEmpiricalProb(toGraph_fr,2)
toGraph_eng <- getEmpiricalProb(toGraph_eng,0)

typeOrder = c("Discrete global", "Discrete incremental", "Continuous global", "Continuous incremental")
makePlot = function(plot,lang,xnoun){
  ggplot(plot, aes(x=Model_output, y=Probability)) +
    #set_theme(base=theme_bw())
    geom_point(stat="identity") +
    scale_fill_manual(values =cbPalette) +
    facet_wrap(~factor(modelType,typeOrder), nrow = 2) +
    ylim(0,1) +
    labs(y= "Experimental probability", x= sprintf("Model probability (xnoun=%1.2f)",xnoun), title= "Empirical vs. Modeling Probabilities") +
    theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom")
  ggsave(filename = sprintf("model_comp_%s_%1.2f.jpg",lang,xnoun), path = "../../../../../analyses/FRENCH/nounInformative/main/graphs", device = "jpg")
}

makePlot(toGraph_fr,"fr",0.99)
makePlot(toGraph_eng, "eng",0.99)

#Coefficient analysis
findCor = function(toGraph){
  for (type in typeOrder){
    toFind <- toGraph %>% filter(modelType == type)
    print(sprintf("%s: %f",type,cor(toFind$Model_output,toFind$Probability)))
  }
}
findCor(toGraph_eng)
findCor(toGraph_fr)

#//--- Noun Noise = 0.90
modeling_fr <- modeling %>% filter(Language == 2 | global_inc == "global")
modeling_eng <- modeling %>% filter(Language == 0)

modeling_fr <- modeling_fr %>% filter(noun_noise != 0.99)
modeling_eng <- modeling_eng %>% filter(noun_noise != 0.99)

modeling_fr <- getModelType(modeling_fr)
toGraph_fr <- subset(modeling_fr, select= c(Name,modelType,output))
toGraph_fr <- toGraph_fr %>% 
  rename("Model_output" = "output")

modeling_eng <- getModelType(modeling_eng)
toGraph_eng <- subset(modeling_eng, select= c(Name,modelType,output))
toGraph_eng <- toGraph_eng %>% 
  rename("Model_output" = "output")

toGraph_fr <- getEmpiricalProb(toGraph_fr,2)
toGraph_eng <- getEmpiricalProb(toGraph_eng,0)

#plotting
makePlot(toGraph_fr,"fr",0.90)
makePlot(toGraph_eng, "eng",0.90)

#coefficient analysis
findCor(toGraph_eng)
findCor(toGraph_fr)
