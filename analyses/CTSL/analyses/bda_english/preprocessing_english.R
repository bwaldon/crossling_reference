setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)

df_long <- read_csv("../../data/df_long_english.csv")

View(df_long)

formatted = df_long %>%
  mutate(size = ifelse(grepl("size", replacedGloss),1,0)) %>%
  mutate(color = ifelse(grepl("color", replacedGloss),1,0)) %>%
  mutate(size_color = ifelse(size==1 & color==1,1,0)) %>%
  mutate(response = ifelse(size_color==1,"size_color",ifelse(size==1,"size",ifelse(color==1,"color", NA)))) %>%
  drop_na()

#format for BDA
for_bda = formatted %>%
  mutate(response=as.character(response)) %>%
  mutate(condition = ifelse(clickedObjCondition=="size_sufficient", "size31", ifelse(clickedObjCondition=="color_sufficient", "color31", NA))) %>%
  mutate(gameId = gameid) %>%
  mutate(roundNumber = roundNum) %>%
  mutate(size = "size") %>%
  mutate(color = "color") %>%
  mutate(othercolor = "othercolor") %>%
  mutate(item = "item") %>%
  select(gameId,roundNumber,condition, size, color, othercolor, item, response)

View(for_bda)

write.csv(for_bda, "bda_data_english.csv", row.names=TRUE)

