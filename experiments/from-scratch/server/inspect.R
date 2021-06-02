library(tidyverse)
library(jsonlite)

# set working directory to directory of script
this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

trials <- bind_rows(fromJSON("testOut.json")) %>%
  group_by(condition, TargetItem) %>%
  summarise(n = n()) %>%
  filter(condition %in% c("basicSuffType1", "basicSuffType2", "supSuff", "subNec"))