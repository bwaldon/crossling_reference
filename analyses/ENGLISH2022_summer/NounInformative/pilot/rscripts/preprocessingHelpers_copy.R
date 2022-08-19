# getPlayerGamePairs: gets the Empirica game IDs for a list of players by querying a Mongo database.
# (Convenient if you have a list of player IDs that match what was input to Empirica, e.g. from Prolific)
# Inputs: a vector of Empirica player IDs (playerIds); a string of MongoDB credentials (mongoCreds)
# Outputs: a dataframe with two columns: id [player id] and gameId

getPlayerGamePairs <- function(playerIds, mongoCreds) {
  con <- mongo("players", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
  playerGamePairs <- data.frame(con$find(sprintf('{ "id": { "$in": %s } } ', toJSON(playerIds)))) %>% 
  select(id, gameId)
  con$disconnect()
  rm(con)
  return(playerGamePairs)
}

# getRoundData_byLanguage: gets the by-round data for all games played in a particular language
# (Convenient if you know the language you want to collect data from but not necessarily the )
# Inputs: a vector of Empirica game IDs (gameIds); a string of MongoDB credentials (mongoCreds)
# Outputs: a dataframe with raw, anonymized by-round game data.

getRoundData_byLanguage <- function(language,mongoCreds) {
  con <- mongo("rounds", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
  d <- data.frame(con$find(sprintf('{ "data.language" : "%s" }   ', language))) %>%
    mutate(index = row_number())
  con$disconnect()
  rm(con)
  return(d)
}

# getRoundData: gets the by-round data for a list of games.
# Inputs: a vector of Empirica game IDs (gameIds); a string of MongoDB credentials (mongoCreds)
# Outputs: a dataframe with raw, anonymized by-round game data.

getRoundData <- function(gameIds,mongoCreds) {
  con <- mongo("rounds", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
  d <- data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(gameIds)))) %>%
    mutate(index = row_number())
  con$disconnect()
  rm(con)
  return(d)
}


# getPlayerDemographicData: gets the player responses to the debrief survey.
# Inputs: a vector of Empirica game IDs (gameIds); a string of MongoDB credentials (mongoCreds)
# Outputs: a dataframe with raw, anonymized player demographic data.

getPlayerDemographicData <- function(gameIds,mongoCreds) {
  con <- mongo("player_inputs", url = sprintf("mongodb+srv://%s@cluster0.xizoq.mongodb.net/crossling-ref", mongoCreds))
  player_info <- data.frame(con$find(sprintf('{ "gameId": { "$in": %s } } ', toJSON(gameIds)))) %>% 
    filter(gameId %in% d$gameId) 
  con$disconnect()
  rm(con)
  return(player_info)
}

# transformDataDegen2020Raw: massages data into something that looks like Degen et al.'s raw data format
# Inputs: a dataframe
# Outputs: a dataframe 

transformDataDegen2020Raw <- function(d) {
  d <- cbind(d$gameId, d$data)
  colnames(d)[1] <- "gameId"
  # Get the within-game round number
  d <- d %>%
    group_by(group = cumsum(gameId != lag(gameId, default = first(gameId)))) %>%
    mutate(roundNumber = row_number()) %>%
    ungroup() %>%
    select(-group)
  # Transform the speaker and listener chat into something more manageable, 
  # and return the item that the listener selected
  directorFirstMessage <- c()
  directorAllMessages <- c()
  guesserAllMessages <- c()
  nameClickedObj <- c()
  selectionSize <- c()
  distractorOne <- c()
  distractorTwo <- c()
  distractorThree <- c()
  distractorFour <- c()
  distractorFive <- c()
  directorViewOrdered <- c()
  guesserViewOrdered <- c()
  ItemID <- c()
  d <- d %>%
    filter(!(chat == "NULL"))
  for(i in seq(nrow(d))) {
    
    chat_temp <- d[i,]$chat[[1]] 
    
    # patch that creates empty text col. in case no lang. exchanged
    if(length(names(chat_temp) != 0)) {
      chat_temp <- chat_temp %>% select(text,role)
    } else {
      chat_temp <- data.frame(1)
      chat_temp$text <- " "
      chat_temp$role <- " "
      chat_temp <- chat_temp %>% select(text,role)
    }
    
    chat_temp$text <- tolower(as.character(chat_temp$text))
    
    guesserChat <- chat_temp %>% filter(role == "listener")
    guesserAllMessages[i] <- paste(guesserChat$text, collapse = "__")
    
    directorChat <- chat_temp %>% filter(role == "speaker")
    directorAllMessages[i] <- paste(directorChat$text, collapse = "__")
    
    if(nrow(directorChat) == 1) {
      directorFirstMessage[i] <- directorAllMessages[i]
    } else {
      directorFirstMessage[i] <- strsplit(directorAllMessages[i], split = "__", fixed = TRUE)[[1]][1]
    }
    
    # Return the item that the listener selected
    
    sel <- d[i,]$listenerSelection
    images<- data.frame(d[i,]$images)
    images$combined_name <- paste(images$size, images$name, sep = "_")
    
    if(is.na(sel) || sel == "NONE") {
      nameClickedObj[i] <- sel 
    } else {
      nameClickedObj[i] <- (images %>% filter(id == sel))$name
    }
    
    if(is.na(sel) || sel == "NONE") {
      selectionSize[i] <- sel 
    } else {
      selectionSize[i] <- (images %>% filter(id == sel))$size
    }
    nameClickedObj[i] <- paste(selectionSize[i],nameClickedObj[i], sep = "_")
    
    #adding identification code - pairwise for items
    pair <- ""
    for (j in seq(nrow(images))){
      imageFull <- (images %>% filter(id == j))$name
      imageType <- str_split(imageFull, "_")[[1]][2]
      if (!grepl(imageType, pair)){
        pair <- paste(imageType, pair, sep = "_")
      }
    }
    ItemID[i] <- substr(pair,0,nchar(pair)-1)
    
    # adding distractor items
    distractorOne[i] <- (images %>% filter(id == 2))$combined_name
    distractorTwo[i] <- (images %>% filter(id == 3))$combined_name
    distractorThree[i] <- (images %>% filter(id == 4))$combined_name
    if (nrow(images) > 4) {
      distractorFour[i] <- (images %>% filter(id == 5))$combined_name
      distractorFive[i] <- (images %>% filter(id == 6))$combined_name
    }
    
    speakerScene <- data.frame(d[i,]$speakerImages)
    speakerScene$combined_name <- paste(speakerScene$size, speakerScene$name, sep = "_")
    directorViewOrdered[i] <- speakerScene$combined_name[[1]]
    for (j in 2:4) {
      directorViewOrdered[i] <- paste(directorViewOrdered[i], speakerScene$combined_name[[j]], sep = ",")
    }
    if (nrow(speakerScene) > 4) {
      for (j in 5:6) {
        directorViewOrdered[i] <- paste(directorViewOrdered[i], speakerScene$combined_name[[j]], sep = ",")
      }
    }
    
    listenerScene <- data.frame(d[i,]$listenerImages)
    listenerScene$combined_name <- paste(listenerScene$size, listenerScene$name, sep = "_")
    guesserViewOrdered[i] <- listenerScene$combined_name[[1]]
    for (j in 2:4) {
      guesserViewOrdered[i] <- paste(guesserViewOrdered[i], listenerScene$combined_name[[j]], sep = ",")
    }
    if (nrow(listenerScene) > 4) {
      for (j in 5:6) {
        guesserViewOrdered[i] <- paste(guesserViewOrdered[i], listenerScene$combined_name[[j]], sep = ",")
      }
    }
    
  }
  rm(chat_temp, guesserChat, directorChat, i, sel, images)
  d <- cbind(d, ItemID, directorAllMessages, directorFirstMessage, guesserAllMessages, nameClickedObj, 
             distractorOne, distractorTwo,distractorThree, distractorFour,distractorFive, directorViewOrdered, guesserViewOrdered)
  rm(directorAllMessages, directorFirstMessage, guesserAllMessages, nameClickedObj,distractorOne, 
     distractorTwo,distractorThree, distractorFour,distractorFive, ItemID, directorViewOrdered, guesserViewOrdered)
  d <- d %>%
    mutate(correct = ifelse(d$target$id == listenerSelection, 1, 0))
  return(d)
}

# accuracyExclusions: returns data filtered for accuracy inclusion criteron (> .7)
# (optionally) makes a plot - x axis is individual games, y axis is guesser accuracy in the game
# Inputs: a dataframe (transformed via transformDataDegen2020Raw), makeGraph? (a boolean), and a label for the x axis (e.g. "English speakers")
# Outputs: a dataframe (and, if makeGraph == TRUE: renders a graph locally at viz/accuracy.pdf)
# Code adapted from https://github.com/leylakursat/ctsl_pragmatics/blob/master/analysis/02_ctsl_production/rscripts/analysis.Rmd

accuracyExclusions <- function(d, makeGraph = FALSE, xlab = "Speakers") {
  h=0.70
  toplot =  d %>%
    group_by(gameId) %>%
    summarise(Mean=mean(correct),CILow=ci.low(correct),CIHigh=ci.high(correct)) %>%
    ungroup() %>%
    mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
    mutate(lowacc=ifelse(Mean<h,"1","0"))
  if(makeGraph) {
    g <- ggplot(toplot, aes(x=reorder(gameId,Mean), y=Mean)) +
      geom_bar(stat="identity", fill="lightblue") +
      geom_hline(yintercept=h) +
      geom_text(aes(0, h, label=h, vjust=-1, hjust=-0.3)) +
      geom_errorbar(aes(ymin = YMin, ymax = YMax),width=.25) +
      theme(axis.text.x=element_blank()) +
      ylab("Accuracy") +
      xlab(xlab)
    ggsave(g, file="../graphs/accuracy.pdf",width=5,height=3)
    print("Wrote graph to ../graphs/accuracy.pdf")
  }
  excludeAccuracy = toplot %>%
    filter(lowacc==1)
  d = d[!(d$gameId %in% excludeAccuracy$gameId),]
  print(sprintf("Games remaining after exclusion: %d", length(unique(d$gameId))))
  return(d)
}

# plotAccuracyByTrialType: plots accuracy by trial type 
# Inputs: a dataframe (transformed via transformDataDegen2020Raw)
# Outputs: nothing (renders a graph locally at viz/accuracy_trialType.pdf)
# Code adapted from https://github.com/leylakursat/ctsl_pragmatics/blob/master/analysis/02_ctsl_production/rscripts/analysis.Rmd

plotAccuracyByTrialType <- function(d) {
  toplot =  d %>%
    group_by(condition) %>%
    summarise(Mean=mean(correct),CILow=ci.low(correct),CIHigh=ci.high(correct)) %>%
    ungroup() %>%
    mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
    mutate(lowacc=ifelse(Mean<0.70,"1","0"))
  
  ggplot(toplot, aes(x=reorder(condition,Mean), y=Mean, fill = condition)) +
    geom_bar(position="dodge", stat="identity") +
    geom_errorbar(aes(ymin = YMin, ymax = YMax),width=.25, position=position_dodge(width = 0.9)) +
    theme(axis.text.x = element_text(angle=90),
          legend.position = "none") +
    ylab("Accuracy") +
    xlab("Trial type")
  ggsave(file="../graphs/accuracy_trialType.pdf",width=6,height=4.5)
  print("Wrote graph to ../graphs/accuracy_trialType.pdf")
}

# automaticAnnotate: performs automatic annotation of the raw data 
# Inputs: a dataframe (transformed via accuracyExclusions) and a series of grep disjunctions of form "term1|term2"
# Outputs: a dataframe

automaticAnnotate <- function(d, colorTerms, sizeTerms, nouns, bleachedNouns, articles) {
  
  colorList <- strsplit(colorTerms, "|",fixed = TRUE)[[1]]
  sizeList <- strsplit(sizeTerms, "|", fixed = TRUE)[[1]]
  nounList <- strsplit(nouns, "|",fixed = TRUE)[[1]]
  bleachedList <- strsplit(bleachedNouns, "|",fixed = TRUE)[[1]]
  articlesList <- strsplit(articles, "|",fixed = TRUE)[[1]]
  
  d <- d %>%
    mutate(words = strsplit(directorFirstMessage, " ",fixed = TRUE)) %>%
    mutate(words = paste(map(words, function(word) {
      word <- tolower(word)
      ifelse(word %in% colorList,"C",ifelse(word %in% sizeList,"S",ifelse(word %in% nounList,"N",ifelse(word %in% bleachedList,"B",ifelse(word %in% articlesList,"A","")))))
    })), sep = "")
  
  # LEGACY COLUMNS
  
  # Was a color mentioned?
  d$colorMentioned = ifelse(grepl(colorTerms, d$directorFirstMessage, ignore.case = TRUE), T, F)
  
  # Was a size mentioned?
  d$sizeMentioned = ifelse(grepl(sizeTerms, d$directorFirstMessage, ignore.case = TRUE), T, F)
  
  # Was the object's type (noun) mentioned?
  d$typeMentioned = ifelse(grepl(nouns, d$directorFirstMessage, ignore.case = TRUE), T, F)
  
  # Was a bleached noun used?
  d$oneMentioned = ifelse(grepl(bleachedNouns, d$directorFirstMessage, ignore.case = TRUE), T, F)
  
  # Was an article used?
  d$theMentioned = ifelse(grepl(articles, d$directorFirstMessage, ignore.case = TRUE), T, F)
  
  return(d)
}

# Final transformations of data for regression and BDA analyses
# Inputs: a dataframe (post manual corrections)
# Outputs: nothing (writes output files to specified destinationFolder)
# (note: we read in typicality data as part of these transformations, but typicality data orthogonal for our purposes)
# (future step could be to elicit typicality data from same population to reproduce Degen 2020 typicality analyses)

produceBDAandRegressionData <- function(d, destinationFolder) {
  
  # Code for each trial: sufficient property, number of total distractors, number of distractors that differ on and that share insufficient dimension value with target
  d$NumDistractors = ifelse(grepl("basic", d$condition, fixed = TRUE), 3, 5)
  d$NumDiffDistractors = ifelse(grepl("basic", d$condition, fixed = TRUE), 2, ifelse(grepl("same_same", d$condition, fixed = TRUE), 2, ifelse(grepl("diff_same", d$condition, fixed = TRUE), 2, 4)))
  d$NumSameDistractors = ifelse(grepl("basic", d$condition, fixed = TRUE), 1, ifelse(grepl("same_same", d$condition, fixed = TRUE), 3, ifelse(grepl("diff_same", d$condition, fixed = TRUE), 3, 1)))
  d$DistractorsNoun = ifelse(grepl("basic", d$condition, fixed = TRUE), "no_extras", ifelse(grepl("same_same|same_diff", d$condition), "same", ifelse(grepl("diff_same|diff_diff", d$condition), "diff", "other")))
  d$DistractorsRedProp = ifelse(grepl("basic", d$condition, fixed = TRUE), "no_extras", ifelse(grepl("same_same|diff_same", d$condition), "same", ifelse(grepl("same_diff|diff_diff", d$condition), "diff", "other")))
  d$SceneVariation = d$NumDiffDistractors/d$NumDistractors
  d$TypeMentioned = d$typeMentioned
  
  # Reduce dataset to target trials for visualization and analysis
  
  # Exclude trials on which target wasn't selected
  targets = d %>% filter(correct == 1)
  # # nrow(targets) # 2138 cases in Degen 2020
  # 
  # # Categorize everything that isn't a size, color, or size-and-color mention as OTHER
  targets$UtteranceType = as.factor(ifelse(targets$sizeMentioned & targets$colorMentioned, "size and color", ifelse(targets$sizeMentioned, "size", ifelse(targets$colorMentioned, "color","OTHER"))))
  # 
  # # examples of what people say when utterance is not clearly categorizable:
  targets[targets$UtteranceType == "OTHER",]$directorFirstMessage
  # 
  targets = droplevels(targets)
  table(targets$UtteranceType)
  table(targets[targets$UtteranceType == "OTHER",]$gameId)
  targets$Color = ifelse(targets$UtteranceType == "color",1,0)
  targets$Size = ifelse(targets$UtteranceType == "size",1,0)
  targets$SizeAndColor = ifelse(targets$UtteranceType == "size and color",1,0)
  targets$Other = ifelse(targets$UtteranceType == "OTHER",1,0)
  targets$Item = sapply(strsplit(as.character(targets$nameClickedObj),"_"), "[", 3)
  targets$redUtterance = as.factor(ifelse(targets$UtteranceType == "size and color","redundant",ifelse(targets$UtteranceType == "size" & targets$SufficientProperty == "size", "minimal", ifelse(targets$UtteranceType == "color" & targets$SufficientProperty == "color", "minimal", "other"))))
  targets$RatioOfDiffToSame = targets$NumDiffDistractors/targets$NumSameDistractors
  targets$DiffMinusSame = targets$NumDiffDistractors-targets$NumSameDistractors

  # Prepare data for Bayesian Data Analysis by collapsing across specific size and color terms
  targets$redUtterance = as.factor(as.character(targets$redUtterance))
  targets$CorrectProperty = ifelse(targets$SufficientProperty == "color" & (targets$Color == 1 | targets$SizeAndColor == 1), 1, ifelse(targets$SufficientProperty == "size" & (targets$Size == 1 | targets$SizeAndColor == 1), 1, 0)) # 20 cases of incorrect property mention
  targets$minimal = ifelse(targets$SizeAndColor == 0 & targets$UtteranceType != "OTHER", 1, 0)
  targets$redundant = ifelse(targets$SizeAndColor == 1, 1, 0)
  targets$BDAUtterance = "size"#as.character(targets$clickedSize)
  targets[targets$Color == 1,]$BDAUtterance = as.character(targets[targets$Color == 1,]$clickedColor)
  targets[targets$SizeAndColor == 1,]$BDAUtterance = paste("size",targets[targets$SizeAndColor == 1,]$clickedColor,sep="_")
  targets$redBDAUtterance = "size_color"
  targets[targets$Color == 1,]$redBDAUtterance = "color"
  targets[targets$Size == 1,]$redBDAUtterance = "size"
  targets[targets$Other == 1,]$redBDAUtterance = "other"
  targets$BDASize = "size"
  targets$BDAColor = "color"
  targets$BDAFullColor = targets$clickedColor
  targets$BDAOtherColor = "othercolor"
  targets$BDAItem = "item"

  # Code non-sensical and "closest"/"Farthest" cases (BW: not sure what this is supposed to do)
  targets[targets$redBDAUtterance != "other" & targets$CorrectProperty == 0,c("gameId","condition","nameClickedObj","directorFirstMessage")]
  targets$WeirdCases = FALSE
  targets[targets$redBDAUtterance != "other" & targets$CorrectProperty == 0  & !targets$gameId %in% c(),]$WeirdCases = TRUE

  # Write Bayesian data analysis files (data and unique conditions)
  write.csv(targets[targets$redBDAUtterance != "other" & targets$WeirdCases == FALSE,c("gameId","roundNumber","condition","BDASize","BDAColor","BDAOtherColor","BDAItem","redBDAUtterance")],file=sprintf("%s/bda_data.csv",destinationFolder),quote=F,row.names=F)
  write.csv(unique(targets[targets$redBDAUtterance != "other" & targets$WeirdCases == FALSE,c("BDAColor","BDASize","condition","BDAOtherColor","BDAItem")]),file=sprintf("%s/unique_conditions.csv",destinationFolder),quote=F,row.names=F)
  print(sprintf("Wrote BDA-ready data to %s/bda_data.tsv",destinationFolder))

  # Write file for regression analysis and visualization

  dd = targets %>%
    filter(redUtterance != "other" & WeirdCases == FALSE) %>%
    rename(Trial=roundNumber, TargetItem=nameClickedObj, gameid = gameId,
           refExp = directorFirstMessage, speakerMessages = directorAllMessages,
           listenerMessages = guesserAllMessages) %>%
    mutate(clickedColor = as.character(clickedColor),
           clickedSize = as.character(clickedSize),
           clickedType = as.character(clickedType),
           TrialType = ifelse(grepl("filler",condition),"control","target"),
           ControlType = ifelse(grepl("filler_1",condition),"both_necessary",
                                ifelse(grepl("filler_2",condition),"noun_sufficient", 
                                ifelse(grepl("filler_3",condition),ifelse(grepl("size_",condition),"size_redundant","color_redundant"),"undefined")))) %>%
    select(gameid,Trial,condition, TrialType, ControlType, ItemID,TargetItem,UtteranceType,redUtterance,
           SufficientProperty,RedundantProperty,NumDistractors,NumSameDistractors,DistractorsNoun,DistractorsRedProp,speakerMessages,
           listenerMessages,refExp,minimal,redundant,clickedType,
           clickedSize,clickedColor,colorMentioned,sizeMentioned,typeMentioned,oneMentioned,theMentioned,
           distractorOne, distractorTwo, distractorThree, distractorFour,distractorFive, directorViewOrdered, guesserViewOrdered) #
  nrow(dd)

  write_delim(dd, sprintf("%s/data_exp1.tsv", destinationFolder),delim="\t")
  print(sprintf("Wrote regression-ready data to %s/data_exp1.tsv",destinationFolder))
}
