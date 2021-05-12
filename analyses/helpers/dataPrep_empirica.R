library(tidyverse)
library(jsonlite)

# d <- read_csv("rounds.csv")

transformData <- function(d) {
  
  convertedData <- data.frame(matrix(ncol = 7, nrow = nrow(d)))
  colnames(convertedData) <- c('game','condition','target','images','selection','chat_speaker', 'chat_listener')
  
  for(i in seq(nrow(d))) {
    
    # Fetch game id, condition and target
    convertedData[i,]$condition <- d[i,]$data.condition
    convertedData[i,]$game <- d[i,]$gameId
    convertedData[i,]$target <- fromJSON(d[i,]$data.target)$name
    
    # Fetch round images, return as a string (list of image names)
    images <- fromJSON(paste("[",d[i,]$data.images,"]"))
    convertedData[i,]$images <- toString(paste(images$name, sep = ","))
    
    # Return the item that the listener selected
    selection <- d[i,]$data.listenerSelection
    if(is.na(selection) || selection == "NONE") {
      convertedData[i,]$selection <- selection
    } else {
      convertedData[i,]$selection <- (images %>%
                                        filter(id == selection))$name
    }
    
    # Return the chat entries for speaker and listener (as a string for each)
    
    chat <- d[i,]$data.chatLog
    # print(chat)
    if(is.na(chat)){
      convertedData[i,]$chat_speaker <- NA
      convertedData[i,]$chat_listener <- NA
    } else {
      chatFull <- flatten(fromJSON((paste("[",chat,"]"))))
      
      speakerMessages <- chatFull %>%
        filter(player.name == "Director")
      if(nrow(speakerMessages) > 0) {
        speakerText = paste(speakerMessages$text, sep = "\n")
      } else {
        speakerText = NA
      }
      
      listenerMessages <- chatFull %>%
        filter(player.name == "Guesser")
      if(nrow(listenerMessages) > 0) {
        listenerText = paste(listenerMessages$text, sep = "\n")
      } else {
        listenerText = NA
      }
      
      convertedData[i,]$chat_speaker <- speakerText
      convertedData[i,]$chat_listener <- listenerText
      
      rm(chatFull, speakerText, listenerText)
    }
    
    rm(chat,i,selection,images)
    
  }
  
  return(convertedData)
}


# write_csv(convertedData, "convertedData.csv")

         