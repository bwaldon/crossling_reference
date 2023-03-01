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
modeling_fr <- modeling_fr %>% mutate(Redundancy = case_when (
  grepl("exp",Name) & grepl("color",Name) ~ "Color",
  grepl("exp",Name) & grepl("size", Name) ~ "Size",
  grepl("alt",Name) & grepl("both", Name) ~ "Both",
  grepl("alt",Name) & grepl("neither", Name) ~ "None",
  grepl("alt",Name) & grepl("fcolor", Name) ~ "Color",
  grepl("alt",Name) & grepl("fsize", Name) ~ "Size"
))
toGraph_fr <- subset(modeling_fr, select= c(Name,modelType,output, Redundancy))
toGraph_fr <- toGraph_fr %>% 
  rename("Model_output" = "output")

modeling_eng <- getModelType(modeling_eng)
modeling_eng <- modeling_eng %>% mutate(Redundancy = case_when (
  grepl("exp",Name) & grepl("color",Name) ~ "Color",
  grepl("exp",Name) & grepl("size", Name) ~ "Size",
  grepl("alt",Name) & grepl("both", Name) ~ "Both",
    grepl("alt",Name) & grepl("neither", Name) ~ "None",
    grepl("alt",Name) & grepl("fcolor", Name) ~ "Color",
    grepl("alt",Name) & grepl("fsize", Name) ~ "Size"
))

toGraph_eng <- subset(modeling_eng, select= c(Name,modelType,output, Redundancy))
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
RedundancyOrder = c("Color", "Both", "Size", "None")
makePlot = function(plot,lang,xnoun){
  ggplot(plot, aes(x=Model_output, y=Probability, color = factor(Redundancy, RedundancyOrder))) +
    #set_theme(base=theme_bw())
    geom_point(stat="identity") +
    #scale_fill_manual(values =cbPalette) +
    facet_wrap(~factor(modelType,typeOrder), nrow = 2) +
    ylim(0,1) +
    labs(y= "Experimental probability", x= sprintf("Model probability (xnoun=%1.2f)",xnoun), color = "Redundancy", title= "Empirical vs. Modeling Probabilities") +
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
#[1] "Discrete global: 0.368978"
#[1] "Discrete incremental: -0.106421"
#[1] "Continuous global: 0.730031"
#[1] "Continuous incremental: 0.036155"
findCor(toGraph_fr)
#[1] "Discrete global: 0.332592"
#[1] "Discrete incremental: -0.280119"
#[1] "Continuous global: 0.669367"
#[1] "Continuous incremental: -0.141453"

#//--- Noun Noise = 0.90
modeling_fr <- modeling %>% filter(Language == 2 | global_inc == "global")
modeling_eng <- modeling %>% filter(Language == 0)

modeling_fr <- modeling_fr %>% filter(noun_noise != 0.99)
modeling_eng <- modeling_eng %>% filter(noun_noise != 0.99)

modeling_fr <- getModelType(modeling_fr)
modeling_fr <- modeling_fr %>% mutate(Redundancy = case_when (
  grepl("exp",Name) & grepl("color",Name) ~ "Color",
  grepl("exp",Name) & grepl("size", Name) ~ "Size",
  grepl("alt",Name) & grepl("both", Name) ~ "Both",
  grepl("alt",Name) & grepl("neither", Name) ~ "None",
  grepl("alt",Name) & grepl("fcolor", Name) ~ "Color",
  grepl("alt",Name) & grepl("fsize", Name) ~ "Size"
))
toGraph_fr <- subset(modeling_fr, select= c(Name,modelType,output,Redundancy))
toGraph_fr <- toGraph_fr %>% 
  rename("Model_output" = "output")

modeling_eng <- getModelType(modeling_eng)
modeling_eng <- modeling_eng %>% mutate(Redundancy = case_when (
  grepl("exp",Name) & grepl("color",Name) ~ "Color",
  grepl("exp",Name) & grepl("size", Name) ~ "Size",
  grepl("alt",Name) & grepl("both", Name) ~ "Both",
  grepl("alt",Name) & grepl("neither", Name) ~ "None",
  grepl("alt",Name) & grepl("fcolor", Name) ~ "Color",
  grepl("alt",Name) & grepl("fsize", Name) ~ "Size"
))
toGraph_eng <- subset(modeling_eng, select= c(Name,modelType,output, Redundancy))
toGraph_eng <- toGraph_eng %>% 
  rename("Model_output" = "output")

toGraph_fr <- getEmpiricalProb(toGraph_fr,2)
toGraph_eng <- getEmpiricalProb(toGraph_eng,0)

#plotting
makePlot(toGraph_fr,"fr",0.90)
makePlot(toGraph_eng, "eng",0.90)

#coefficient analysis
findCor(toGraph_eng)
#[1] "Discrete global: 0.368978"
#[1] "Discrete incremental: -0.106421"
#[1] "Continuous global: 0.743614"
#[1] "Continuous incremental: 0.109478"
findCor(toGraph_fr)
#[1] "Discrete global: 0.332592"
#[1] "Discrete incremental: -0.280119"
#[1] "Continuous global: 0.683555"
#[1] "Continuous incremental: -0.075595"

# further analysis -- removing outliers
toGraph_eng_trimmed <- toGraph_eng %>% filter (Name != "alt_fsize_color_na_na" &
                                                 Name != "alt_both_color_na_na")
findCor(toGraph_eng_trimmed)
#[1] "Continuous global: 0.943911"

toGraph_fr_trimmed <- toGraph_fr %>% filter (Name != "alt_fsize_color_na_na" &
                                               Name != "alt_both_color_na_na")
findCor(toGraph_fr_trimmed)
#[1] "Continuous global: 0.923828"
