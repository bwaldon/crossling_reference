setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)

df_long <- read_csv("df_long.csv")

View(df_long)

# ONLY INCLUDE FIRST OCCURANCE OF EACH CONSTITUENT
clean = df_long %>%
  mutate(cpos = gsub("[0-9]+","", pos)) %>%
  mutate(cpos = gsub("\\?","", cpos)) %>%
  mutate(cpos = tolower(as.character(cpos))) %>%
  mutate(cpos = gsub("loc","", cpos)) %>%
  mutate(cpos = gsub("mod","", cpos)) %>%
  mutate(cpos = gsub("neg","", cpos)) %>%
  mutate(cpos = gsub("num","", cpos)) %>%
  mutate(cpos = gsub("clr","", cpos)) %>%
  mutate(cpos = gsub("other","",cpos)) %>%
  mutate(cpos = gsub("lr","",cpos)) %>%
  mutate(cpos = gsub("question","",cpos)) %>%
  mutate(cpos = gsub("verb","",cpos)) %>%
  mutate(cpos = gsub("cerb","",cpos)) %>%
  mutate(cpos = gsub("nnoun","noun",cpos)) %>%
  mutate(cpos = gsub("sizeb","size",cpos)) %>%
  mutate(cpos = gsub("noun","",cpos)) %>% #remove nouns
  mutate(cpos = gsub("  "," ", cpos)) %>%
  mutate(cpos = gsub("  "," ", cpos)) %>%
  mutate(cpos = gsub("  "," ", cpos)) %>%
  mutate(cpos = str_trim(cpos, side = "left")) %>%
  filter(!str_detect(cpos,"-")) %>%
  filter(cpos != "") %>%
  mutate(itemized = strsplit(cpos," "))
  
#View(clean)

clean$uniqueItemized=c()
clean$uniquePos=c()

for (i in 1:length(clean$itemized)){
  clean$uniqueItemized[i]=map(clean$itemized[i], ~ unique(.x))
  clean$uniquePos[i] =map(clean$uniqueItemized[i], ~ paste(.x,collapse=" "))
}

unique(clean$uniquePos)

#format for BDA

for_bda = clean %>%
  filter(language=="CTSL") %>%
  mutate(response = ifelse(uniquePos=="size color", "size_color", ifelse(uniquePos=="color size", "size_color", uniquePos))) %>%
  mutate(response=as.character(response)) %>%
  mutate(condition = ifelse(condition=="size_sufficient", "size31", ifelse(condition=="color_sufficient", "color31", NA))) %>%
  mutate(gameId = gameid) %>%
  mutate(roundNumber = roundNum) %>%
  mutate(size = "size") %>%
  mutate(color = "color") %>%
  mutate(othercolor = "othercolor") %>%
  mutate(item = "item") %>%
  select(gameId,roundNumber,condition, size, color, othercolor, item, response)

View(for_bda)

typeof(for_bda$redBDAUtterance)

write.csv(for_bda, "bda_data_2.csv", row.names=TRUE)



