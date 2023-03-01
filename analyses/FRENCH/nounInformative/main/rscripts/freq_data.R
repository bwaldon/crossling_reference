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

empirical_fr <- read.csv("../../../../../data/FRENCH/nounInformative/main/data_exp1.tsv")

empirical_eng <- read_tsv("../../../../../data/ENGLISH2022_summer/nounInformative/main/main_data_exp1.tsv")

freq <- read.csv("freq.csv")

view(empirical_eng)

getTargetWord <- function(itemName) {
  return(strsplit(itemName,"_")[[1]][3])
}
getWordFreq <- function(word) {
  return(as.numeric(freq[freq$Word == word, "engFreq"]))
}

empirical_eng$targetName= lapply(empirical_eng$TargetItem,getTargetWord)
df <- empirical_eng %>% select(condition, targetName, minimal, redundant)
df$targetFreq = lapply(df$targetName, getWordFreq)


dfnew <- df %>%
select(redundant,targetFreq,condition) %>%
  group_by(targetFreq) %>%
  summarise(Probability=mean(redundant)) 

dfnew$targetFreq <- as.numeric(dfnew$targetFreq)
makePlot = function(plot){
  ggplot(plot, aes(x=targetFreq, y=Probability)) +
    #set_theme(base=theme_bw())
    geom_point(stat="identity") +
    #facet_wrap(~factor(modelType,typeOrder), nrow = 2) +
    ylim(0,1) +
    xlim(500,260000) +
    labs(y= "Experimental probability", x= "Word frequency", title= "Redundancy vs. Target word frequency") +
    theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom")
  #ggsave(filename = sprintf("model_comp_%s_%1.2f.jpg",lang,xnoun), path = "../../../../../analyses/FRENCH/nounInformative/main/graphs", device = "jpg")
}

makePlot(dfnew)