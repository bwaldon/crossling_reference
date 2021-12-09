this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

library(tidyverse)

materials2021 <- read_file("2021materials")
materials2021 <- strsplit(materials2021, "|", fixed = T)[[1]]
features2021 <- data.frame(strsplit(materials2021, "_", fixed = T))
uniqueNouns2021 <- sort(unique(as.character(features2021[3,])))
uniqueColorAdjectives2021 <- sort(unique(as.character(features2021[2,])))
uniqueSizeAdjectives2021 <- sort(unique(as.character(features2021[1,])))

materials2020 <- list.files("../../experiments/langcog/production/production_exp1_exp3/experiment/stimuli", ".jpg")
materials2020 <- str_remove(materials2020, ".jpg") %>% .[grepl("small", ., fixed = TRUE) | grepl("big", ., fixed = TRUE)]
features2020 <- data.frame(strsplit(materials2020, "_", fixed = T))
uniqueNouns2020 <- sort(unique(as.character(features2020[3,])))
uniqueColorAdjectives2020 <- sort(unique(as.character(features2020[2,])))
uniqueSizeAdjectives2020 <- sort(unique(as.character(features2020[1,])))

setdiff(uniqueNouns2020, uniqueNouns2021)

write_file(toString(uniqueNouns2021), "uniqueNouns2021")
write_file(toString(uniqueColorAdjectives2021), "uniqueColorAdjectives2021")
write_file(toString(uniqueSizeAdjectives2021), "uniqueSizeAdjectives2021")

write_file(toString(uniqueNouns2020), "uniqueNouns2020")
write_file(toString(uniqueColorAdjectives2020), "uniqueColorAdjectives2020")
write_file(toString(uniqueSizeAdjectives2020), "uniqueSizeAdjectives2020")
