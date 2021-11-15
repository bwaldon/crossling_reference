# Lexicon
# 
nouns = c("plate_masc", "cup_fem")
colors = c("blue_masc", "blue_fem", "blue_neut", "red_masc", "red_fem", "red_neut")
sizes = c("big_masc", "big_fem", "big_neut", "small_masc", "small_fem", "small_neut")

#Take in states and return individual words with their gender marking
#Assumes gender marking is a suffix
# returns 
makeWords <- function(states) {
  allWord <- strsplit(states, split = "_")
  
  #add gender morpheme to the words
  addGender <- function(currentWords) {
    # take gender
    if ("masc" %in% currentWords) {
      gender = "masc"
    } else if ("fem" %in% currentWords) {
      gender = "fem"
    } else {
      gender = "neut"
    }
    # delete the gender as its own word
    currentWords <- currentWords[currentWords != "masc" & currentWords != "fem" & currentWords != "neut"]
    #append gender to all words
    currentWords <- paste(currentWords, "_", gender, sep = "")
  }
  
  # apply addGender to all words per state
  return(lapply(allWord, addGender))
}

#Take in words and return a list with three lists, each containing one type of word
# assumes there are only three types of words
getWordType <- function(words) {
  #get color adjectives
  colorAdj <- words[words %in% colors]
  #get size adjectives
  sizeAdj <- words[words %in% sizes]
  #get nouns
  currentNouns <- words[words %in% nouns]
  return(c(colorAdj, sizeAdj, currentNouns))
}

# assumes at most two adjectives (color and size)
makeUtterances <- function(states) {

  allWord <- makeWords(states)
  allUtterances <- c()
  
  #create all utterance combinations
  createUtt <- function(words) {
    
    wordUtterances <- c()
    
    wordTypes <- getWordType(words)
    colorAdj <- wordTypes[1]
    sizeAdj <- wordTypes[2]
    currentNouns <- wordTypes[3]
    
    #add "start" "end" parts of strings
    startEndString <- function(currentUtterance) {
      if(length(currentUtterance) == 0) {
        return()
      }
      return(paste("START", currentUtterance, "END", sep = " "))
    }
    
    # create single word utterances
    wordUtterances <- append(wordUtterances, startEndString(colorAdj))
    wordUtterances <- append(wordUtterances, startEndString(sizeAdj))
    wordUtterances <- append(wordUtterances, startEndString(currentNouns))
    
    # create single adjective utterances with noun
    if (length(colorAdj) != 0) {
      wordUtterances <- append(wordUtterances, startEndString(paste(colorAdj, currentNouns, sep = " ")))
    }
    
    if (length(sizeAdj) != 0) {
      wordUtterances <- append(wordUtterances, startEndString(paste(sizeAdj, currentNouns, sep = " ")))
    }
    
    # create double adjective utterances with no noun
    if (length(colorAdj) != 0 & length(sizeAdj) != 0) {
      wordUtterances <- append(wordUtterances, startEndString(paste(sizeAdj, colorAdj, sep = " ")))
    }
    
    # create double adjective utterances with noun
    if (length(colorAdj) != 0 & length(sizeAdj) != 0) {
      wordUtterances <- append(wordUtterances, startEndString(paste(sizeAdj, colorAdj, currentNouns, sep = " ")))
    }
    
    return(wordUtterances)
  }
  
  allUtterances <- lapply(allWord, createUtt)
  
  #flatten the list into a single vector and delete duplicates
  allUtterances <- unique(unlist(allUtterances, recursive = FALSE))
  return(allUtterances)
}


makeModel <- function(states, colorCost, sizeCost, nounCost) {
  # words <- makeWords(states)
  words <- c("blue_masc", "red_masc")
  words <- unique(unlist(words, recursive = FALSE))
  # Flatten the words into a single list
  print(words)
  wordTypes <- getWordType(words)
  # word types --> c(colorAdj, sizeAdj, currentNouns)
  #output string with correct format
  #check what that format is in stefan_simulations after it is read in fromt the modelAndSemantics.txt
  
  masterString <- "var model = function(params) {  return { words : ["
  # doesn't work
  allWordsAsString <- paste(words, sep = ",")
  print(allWordsAsString)
  #add words
  masterString <- masterString %>% paste(allWordsAsString, sep = ",")
  print(masterString)
  
  masterString <- masterString %>% paste("'STOP', 'START'], wordCost: {", sep = "")
  print("final")
  print(masterString)
  print("HERE")
  addParameters <- function(currentWord) {
    costParameter <- 0
    if(currentWord %in% wordTypes[1]) {
      #color
      costParameter <- colorCost
    } else if(currentWord %in% wordTypes[2]) {
      #size
      costParameter <-sizeCost
    } else {
      #noun
      costParameter <- nounCost
    }
    masterString <- masterString %>% paste("'", currentWord, "'", " : ", colorCost, ",", sep = "")
  }
  lapply(words, addParameters)
  masterString <- masterString %>% paste("'STOP'  : 0, 'START'  : 0 }, } }")
}



# make semantics


