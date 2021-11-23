# getPlayerGamePairs: gets the Empirica game IDs for a list of players by querying a Mongo database.
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
  d <- d %>%
    filter(!(chat == "NULL"))
  for(i in seq(nrow(d))) {
    chat_temp <- d[i,]$chat[[1]] %>% select(text,role)
    
    chat_temp$text <- as.character(chat_temp$text)
    
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
    
    if(is.na(sel) || sel == "NONE") {
      nameClickedObj[i] <- sel 
    } else {
      nameClickedObj[i] <- (images %>% filter(id == sel))$name
    }
    
  }
  rm(chat_temp, guesserChat, directorChat, i, sel, images)
  d <- cbind(d, directorAllMessages, directorFirstMessage, guesserAllMessages, nameClickedObj)
  rm(directorAllMessages, directorFirstMessage, guesserAllMessages, nameClickedObj)
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
    ggsave(g, file="viz/accuracy.pdf",width=5,height=3)
    print("Wrote graph to ./viz/accuracy.pdf")
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
  ggsave(file="viz/accuracy_trialType.pdf",width=6,height=4.5)
  print("Wrote graph to ./viz/accuracy_trialType.pdf")
}

# automaticAnnotate: performs automatic annotation of the raw data 
# Inputs: a dataframe (transformed via accuracyExclusions) and a series of grep disjunctions of form "term1|term2"
# Outputs: a dataframe

automaticAnnotate <- function(d, colorTerms, sizeTerms, nouns, bleachedNouns, articles) {
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

produceBDAandRegressionData <- function(d, colorTypicalityFile = "../../data/Degen2020_Typicality/typicality_exp1_colortypicality.csv",
                                        objectTypicalityFile = "../../data/Degen2020_Typicality/typicality_exp1_objecttypicality.csv",
                                        destinationFolder) {
  
  # Code for each trial: sufficient property, number of total distractors, number of distractors that differ on and that share insufficient dimension value with target
  d$SufficientProperty = as.factor(ifelse(d$condition %in% c("size21", "size22", "size31", "size32", "size33", "size41", "size42", "size43", "size44"), "size", "color"))
  d$RedundantProperty = ifelse(d$SufficientProperty == 'color',"size redundant","color redundant")
  d$NumDistractors = ifelse(d$condition %in% c("size21","size22","color21","color22"), 2, ifelse(d$condition %in% c("size31","size32","size33","color31","color32","color33"),3,4))
  d$NumDiffDistractors = ifelse(d$condition %in% c("size22","color22","size33","color33","size44","color44"), 0, ifelse(d$condition %in% c("size21","color21","size32","color32","size43","color43"), 1, ifelse(d$condition %in% c("size31","color31","size42","color42"),2,ifelse(d$condition %in% c("size41","color41"),3, 4))))
  d$NumSameDistractors = ifelse(d$condition %in% c("size21","size31","size41","color21","color31","color41"), 1, ifelse(d$condition %in% c("size22","size32","size42","color22","color32","color42"), 2, ifelse(d$condition %in% c("size33","color33","size43","color43"),3,ifelse(d$condition %in% c("size44","color44"),4,NA))))
  d$SceneVariation = d$NumDiffDistractors/d$NumDistractors
  d$TypeMentioned = d$typeMentioned
  
  # Add empirical typicality ratings
  # Add color typicality ratings ("how typical is this color for a stapler?" wording)
  typicalities = read.table(colorTypicalityFile,header=T)
  head(typicalities)
  typicalities = typicalities %>%
    group_by(Item) %>%
    mutate(OtherTypicality = c(Typicality[2],Typicality[1]),OtherColor = c(as.character(Color[2]),as.character(Color[1])))
  typicalities = as.data.frame(typicalities)
  row.names(typicalities) = paste(typicalities$Item,typicalities$Color)
  d$ColorTypicality = typicalities[paste(d$clickedType,d$clickedColor),]$Typicality
  d$OtherColorTypicality = typicalities[paste(d$clickedType,d$clickedColor),]$OtherTypicality
  d$OtherColor = typicalities[paste(d$clickedType,d$clickedColor),]$OtherColor
  d$TypicalityDiff = d$ColorTypicality-d$OtherColorTypicality  
  d$normTypicality = d$ColorTypicality/(d$ColorTypicality+d$OtherColorTypicality)
  
  # Add typicality norms for objects with modified and unmodified utterances ("how typical is this for a stapler?" vs "how typical is this for a red stapler?" wording)
  typs = read.table(objectTypicalityFile,header=T)
  head(typs)
  typs = typs %>%
    group_by(Item) %>%
    mutate(OtherTypicality = c(Typicality[3],Typicality[4],Typicality[1],Typicality[2])) 
  typs = as.data.frame(typs)
  row.names(typs) = paste(typs$Item,typs$Color,typs$Modification)
  d$ColorTypicalityModified = typs[paste(d$clickedType,d$clickedColor,"modified"),]$Typicality
  d$OtherColorTypicalityModified = typs[paste(d$clickedType,d$clickedColor,"modified"),]$OtherTypicality
  d$TypicalityDiffModified = d$ColorTypicalityModified-d$OtherColorTypicalityModified  
  d$normTypicalityModified = d$ColorTypicalityModified/(d$ColorTypicalityModified+d$OtherColorTypicalityModified)
  d$ColorTypicalityUnModified = typs[paste(d$clickedType,d$clickedColor,"unmodified"),]$Typicality
  d$OtherColorTypicalityUnModified = typs[paste(d$clickedType,d$clickedColor,"unmodified"),]$OtherTypicality
  d$TypicalityDiffUnModified = d$ColorTypicalityUnModified-d$OtherColorTypicalityUnModified  
  d$normTypicalityUnModified = d$ColorTypicalityUnModified/(d$ColorTypicalityUnModified+d$OtherColorTypicalityUnModified)
  
  # Reduce dataset to target trials for visualization and analysis
  
  # Exclude trials on which target wasn't selected
  targets = d %>% filter(correct == 1)
  # nrow(targets) # 2138 cases in Degen 2020
  
  # Categorize everything that isn't a size, color, or size-and-color mention as OTHER
  targets$UtteranceType = as.factor(ifelse(targets$sizeMentioned & targets$colorMentioned, "size and color", ifelse(targets$sizeMentioned, "size", ifelse(targets$colorMentioned, "color","OTHER"))))
  
  # examples of what people say when utterance is not clearly categorizable:
  targets[targets$UtteranceType == "OTHER",]$directorFirstMessage
  
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
           clickedType = as.character(clickedType)) %>%
    select(gameid,Trial,TargetItem,UtteranceType,redUtterance,SufficientProperty,RedundantProperty,NumDistractors,NumSameDistractors,SceneVariation,speakerMessages,listenerMessages,refExp,minimal,redundant,clickedType,clickedSize,clickedColor,colorMentioned,sizeMentioned,typeMentioned,oneMentioned,theMentioned,ColorTypicality,OtherColorTypicality,OtherColor,TypicalityDiff,normTypicality,ColorTypicalityModified,ColorTypicalityUnModified,OtherColorTypicalityModified,OtherColorTypicalityUnModified,TypicalityDiffModified,normTypicalityModified,TypicalityDiffUnModified,normTypicalityUnModified) #alt1Name,alt1SpLocs,alt1LisLocs,alt2Name,alt2SpLocs,alt2LisLocs,alt3Name,alt3SpLocs,alt3LisLocs,alt4Name,alt4SpLocs,alt4LisLocs)
  nrow(dd)
  
  write_delim(dd, sprintf("%s/data_exp1.tsv", destinationFolder),delim="\t")
  print(sprintf("Wrote regression-ready data to %s/data_exp1.tsv",destinationFolder))
}
