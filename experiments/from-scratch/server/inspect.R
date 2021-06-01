library(jsonlite)

# set working directory to directory of script
this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

trials <- bind_rows(fromJSON("testOut.json")) %>%
  group_by(TargetItem,NumDistractors) %>%
  summarise(n = n())

