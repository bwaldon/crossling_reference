setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

# MAKE THE STATES (REFERENTS ASSOCIATED WITH EACH CONDITION TYPE)
#FREnch studies are noun informative, so have to be adjusted

getStates = function(condName) {
  condSplit = strsplit(condName, "_")
  states = c("sameColor_sameSize_sameType")
  if (!grepl("filler",condName)){
  red = condSplit[[1]][1]
  type = condSplit[[1]][2]
  sufficientDimension = ifelse(red == "color","size","color")
  numDistractors = ifelse(type=="basic", 3, 5)
  if (type != "basic") {
    noun = type
    redprop = condSplit[[1]][3]
    if (sufficientDimension == "size"){
      states <- append(states, replicate(2, sprintf("%sColor_%sSize_%sType",redprop,"diff",noun)))
    }
    else if(sufficientDimension == "color") { 
      states <- append(states, replicate(2, sprintf("%sColor_%sSize_%sType","diff",redprop,noun)))
  }
  }
  if (sufficientDimension == "size") {
    states <- append(states, "sameColor_diffSize_sameType")
    states <- append(states, "diffColor_sameSize_diffType")
    states <- append(states, "diffColor_diffSize_sameType")
  }
  if (sufficientDimension == "color") {
    states <- append(states, "diffColor_sameSize_sameType")
    states <- append(states, "sameColor_diffSize_diffType")
    states <- append(states, "diffColor_diffSize_sameType")
  }
  
  return(unlist(states))
  }
  else {
    return(condName)
  }
  
}

# MAKE THE UTTERANCES FOR EACH CONDITION (FROM THE STATE TYPES, WHICH HAVE NAME FORM COLOR_SIZE)

#no noun omission, only works for French
getUtterances = function(states, language) {
  
  utterances = c()
  
  for(state in states) {
    words = str_split(state, "_")[[1]]
    colorWord = words[1]
    sizeWord = words[2]
    typeWord = words[3]
    
    one_word_utterance = typeWord
    
    size_noun_utterance = paste(sizeWord, typeWord, sep = " ")
    
    if(language == "english") {
      color_noun_utterance = paste(colorWord, typeWord, sep = " ")
      three_word_utterance = paste(sizeWord,colorWord, typeWord, sep = " ")
    } 
    if (language == "french") {
      color_noun_utterance = paste(typeWord,colorWord, sep = " ")
      three_word_utterance = paste(sizeWord,typeWord, colorWord, sep = " ")
    }
    
    utterances = append(utterances,one_word_utterance)
    utterances = append(utterances,size_noun_utterance)
    utterances = append(utterances,color_noun_utterance)
    utterances = append(utterances,three_word_utterance)
    
  }
  
  # print(utterances)
  
  utterances <- lapply(unique(utterances), function(utterance) { 
    
    utterance <- paste("START", utterance, sep = " ")
    utterance <- paste(utterance, "STOP", sep = " ")
    
    return(utterance)
    
  })
  
  return(unlist(utterances))
}

makeStatesUtterances = function(d_uncollapsed, language) {
  
  dictionary = tibble(unique(d_uncollapsed$condition)) %>%
    setNames(c("condition")) 
  
  dictionary$states <- lapply(dictionary$condition, getStates)
  dictionary$utterances <- lapply(dictionary$states, getUtterances, language=language)
  
  return(dictionary)
  
}

collapse_dataset <- function(d_uncollapsed) {
  d_uncollapsed %>% 
    group_by(condition, response) %>%
    summarise(n = n()) %>%
    spread(response, n) %>%
    replace(is.na(.), 0) %>%
    mutate(total = color + size + size_color) %>%
    mutate(color = color / total, size = size / total, size_color = size_color / total) %>%
    select(condition, size_color, size, color,response)
}

