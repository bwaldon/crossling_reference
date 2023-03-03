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

empirical_fr <- read_tsv("../../../../../data/FRENCH/nounInformative/main/data_exp1.tsv")

empirical_eng <- read_tsv("../../../../../data/ENGLISH2022_summer/nounInformative/main/main_data_exp1.tsv")

freq <- read.csv("freqFinal.csv")
freq<- as.data.frame(freq)
freq <- freq[-c(1),]
freq <- freq[,-c(1)]
sortedListEng <- freq[order(freq$engFreq),]
sortedListFren <- freq[order(freq$frenFreq),]

getTargetWord <- function(itemName) {
  word = strsplit(itemName,"_")[[1]][3]
  if (word == "fryingpan") word = "pan"
  if (word == "magnifyingglass") word = "magnifying glass"
  if (word == "billiardball") word = "billiard ball"
  if (word == "coathanger") word = "hanger"
  return(word)
}
getWordFreq <- function(word,lang) {
  if (lang == "eng") {
    return(as.numeric(freq[freq$engWord == word, "engFreq"]))
  }
  else if (lang == "fr") {
    return(as.numeric(freq[freq$engWord == word, "frenFreq"]))
  }
}

empirical_eng$targetName= lapply(empirical_eng$TargetItem,getTargetWord)
dfEng <- empirical_eng %>% select(condition, targetName, minimal, redundant)
dfEng$targetFreq = lapply(dfEng$targetName, getWordFreq, "eng")

empirical_fr$targetName= lapply(empirical_fr$TargetItem,getTargetWord)
dfFren <- empirical_fr %>% select(condition, targetName, minimal, redundant)
dfFren$targetFreq = lapply(dfFren$targetName, getWordFreq, "fr")

makeProb = function(df) {
  dfnew <- df %>%
  select(redundant,targetFreq,condition) %>%
    group_by(targetFreq) %>%
    summarise(Probability=mean(redundant)) 
  dfnew$targetFreq <- as.numeric(dfnew$targetFreq)
  return(dfnew)
}

dfEng <- makeProb(dfEng)
dfFren <- makeProb(dfFren)

makePlot = function(plot,lang){
  ggplot(plot, aes(x=targetFreq, y=Probability,size = 1)) +
    #set_theme(base=theme_bw())
    geom_point(stat="identity") +
    #facet_wrap(~factor(modelType,typeOrder), nrow = 2) +
    ylim(0,1) +
    xlim(2,6) +
    labs(y= "Experimental probability", x= "Word Zipf Frequency", title= "Redundancy vs. Target word frequency") +
    theme(axis.text.x = element_text(angle=15,hjust=1,vjust=1),legend.position="bottom")
  ggsave(filename = sprintf("targetFreq_%s.jpg",lang), path = "../graphs", device = "jpg")
}


makePlot(dfEng,"eng")
makePlot(dfFren,"fren")
