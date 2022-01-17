setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(jsonlite)
library(rwebppl)

# MAKE THE STATES (REFERENTS ASSOCIATED WITH EACH CONDITION TYPE)

getStates = function(condName) {
  
  states = c("color_size")
  sufficientDimension = substr(condName, 0, nchar(condName)-2)
  numDistractors = as.numeric(substr(condName, nchar(condName)-1, nchar(condName)-1))
  numShared = as.numeric(substr(condName, nchar(condName), nchar(condName)))
  numDiff = numDistractors - numShared
  
  if(sufficientDimension == "color") {
    
  states <- append(states, replicate(numShared, "otherColor_size"))
  states <- append(states, replicate(numDiff, "otherColor_otherSize"))
    
  } else if(sufficientDimension == "size") {
    
  states <- append(states, replicate(numShared, "color_otherSize"))
  states <- append(states, replicate(numDiff, "otherColor_otherSize"))
    
  }

  return(unlist(states))
  
}

# MAKE THE UTTERANCES FOR EACH CONDITION (FROM THE STATE TYPES, WHICH HAVE NAME FORM COLOR_SIZE)

getUtterances = function(states, language) {
  
  utterances = c()
  two_word_utterances = c()
  
  for(state in states) {
  
    one_word_utterances = str_split(state, "_")
    utterances = append(utterances,one_word_utterances)
    
    if(language == "spanish") {
      two_word_utterances = str_replace(state, "_", " ")
      
    } else if (language == "english") {
      words = str_split(state, "_")[[1]]
      colorWord = words[1]
      sizeWord = words[2]
      two_word_utterances = paste(sizeWord,colorWord, sep = " ")
      
    } else if  (language == "ctsl") {
      words = str_split(state, "_")[[1]]
      colorWord = words[1]
      sizeWord = words[2]
      
      size_color_utterances = paste(sizeWord,colorWord, sep = " ")
      color_size_utterances = str_replace(state, "_", " ")
      two_word_utterances = append(size_color_utterances,color_size_utterances)
      
    }
    
    utterances = append(utterances,two_word_utterances)
  
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
    select(condition, size_color, size, color)
}
