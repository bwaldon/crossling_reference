library(tidyverse)
library(grid)
library(gridExtra)
library(cowplot)
library(viridis)
library(jsonlite)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# RUN WEBPPL FROM A V8 JS ENGINE (FASTER WHEN YOU NEED TO RUN MANY, MANY CALLS TO WEBPPL)

source("../../../_shared/V8wppl.R")

# SOURCE SOME HELPER SCRIPTS

source("../../../_shared/simulationHelpers.R")

# SOURCE THE ENGINE

engine <- read_file("../../../_shared/engine.txt")

modelAndSemantics <- read_file("manh_semantics.txt")

# STATES

states_ss_med = c("smallbluepin", "bigbluepin", "bigredpin", "smallblueball", "bigredpin", "bigredpin")
states_cs_med = c("smallbluepin", "smallredpin", "bigredpin", "smallblueball", "bigredpin", "bigredpin")
states_ss_high = c("smallbluepin", "bigbluepin", "bigredpin", "smallblueball", "bigredpin", "bigredpin", "bigredpin", "bigredpin")
states_cs_high = c("smallbluepin", "smallredpin", "bigredpin", "smallblueball", "bigredpin", "bigredpin", "bigredpin", "bigredpin")


states_color_med <- "smallbluepin, smallredpin, bigredpin, smallblueball, bigredpin, bigredpin"
states_size_med <- "smallbluepin, bigbluepin, bigredpin, smallblueball, bigredpin, bigredpin"
states_color_high <- "smallbluepin, smallredpin, bigredpin, smallblueball, bigredpin, bigredpin, bigredpin, bigredpin"
states_size_high <- "smallbluepin, bigbluepin, bigredpin, smallblueball, bigredpin, bigredpin, bigredpin, bigredpin"

# UTTERANCES: SIZE SUFFICIENT

utterances_eng_ss <- c("START red pin STOP", "START blue pin STOP",
                       "START big pin STOP", "START small pin STOP",
                       "START small ball STOP", "START blue ball STOP",
                       "START pin STOP", "START ball STOP",
                       "START big blue pin STOP",
                       "START big red pin STOP",
                       "START small blue pin STOP",
                       "START small blue ball STOP")

utterances_sp_ss <- c("START pin STOP", "START ball STOP",
                            "START pin red STOP", "START pin blue STOP", "START ball blue STOP",
                            "START pin big STOP", "START pin small STOP","START ball small STOP",
                            "START pin blue small STOP",
                            "START pin blue big STOP",
                            "START pin red big STOP", "START ball blue small STOP")

utterances_fr_ss <- c("START pin STOP", "START ball STOP",
                      "START pin red STOP", "START pin blue STOP","START ball blue STOP",
                           "START big pin STOP", "START small pin STOP", "START small ball STOP",
                           "START big pin blue STOP",
                           "START small pin blue STOP",
                           "START big pin red STOP",
                           "START small ball blue STOP")

utterances_vt_ss <- c("START pin STOP", "START ball STOP", "START pin red STOP", "START pin blue STOP", "START ball blue STOP",
                              "START pin big STOP", "START pin small STOP","START ball small STOP",
                              "START pin blue and big STOP",
                              "START pin big and blue STOP",
                              "START pin red and big STOP", "START pin big and red STOP",
                              "START pin blue and small STOP", "START pin small and blue STOP",
                      "START ball blue and small STOP", "START ball small and blue STOP")

# UTTERANCES: COLOR SUFFICIENT

utterances_eng_cs <- c("START pin STOP", "START ball STOP","START red pin STOP", "START blue pin STOP","START blue ball STOP",
                       "START big pin STOP", "START small pin STOP","START small ball STOP",
                       "START big red pin STOP",
                       "START small blue pin STOP","START small blue ball STOP",
                       "START small red pin STOP")

utterances_sp_cs <- c("START pin STOP", "START ball STOP","START pin red STOP", "START pin blue STOP", "START ball blue STOP",
                            "START pin big STOP", "START pin small STOP","START ball small STOP",
                            "START pin red small STOP", "START pin red big STOP",
                            "START pin blue small STOP",
                            "START ball blue small STOP")

utterances_fr_cs <- c("START pin STOP", "START ball STOP","START pin red STOP", "START pin blue STOP", "START ball blue STOP",
                           "START big pin STOP", "START small pin STOP", "START small ball STOP",
                           "START big pin red STOP",
                           "START small pin red STOP",
                           "START small pin blue STOP",
                           "START small ball blue STOP")

utterances_vt_cs <- c("START pin STOP", "START ball STOP","START pin red STOP", "START pin blue STOP","START ball blue STOP",
                              "START pin big STOP", "START pin small STOP","START ball small STOP",
                              "START pin red and big STOP","START pin big and red STOP",
                      "START pin blue and small STOP", "START pin small and blue STOP",
                      "START ball blue and small STOP", "START ball small and blue STOP",
                              "START pin red and small STOP", "START pin small and red STOP")


# COMMANDS

cmd_eng = 'incrementalUtteranceSpeaker("START small blue pin STOP", "smallbluepin", model, params, semantics)'
cmd_sp = 'incrementalUtteranceSpeaker("START pin blue small STOP", "smallbluepin", model, params, semantics)'
cmd_fr = 'incrementalUtteranceSpeaker("START small pin blue STOP", "smallbluepin", model, params, semantics)'
cmd_vt = 'incrementalUtteranceSpeaker("START pin blue and small STOP", "smallbluepin", model, params, semantics) + incrementalUtteranceSpeaker("START pin small and blue STOP", "smallbluepin", model, params, semantics)'

# redundant phrase

utterance_eng <- "small blue pin"
utterance_sp <- "pin blue small"
utterance_fr <- "small pin blue"
utterance_vt <- "pin blue and small + pin small and blue"


# VALDF FOR SCIL PAPER

valDF <- data.frame("colorNoise" = c(0.95), "sizeNoise" = c(0.8), "alpha" = c(1,5,10, 20))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha) %>%
  filter(alpha %in% c(1,5,10, 20))

# VALDF FOR SCIL APP

valDF <- data.frame("colorNoise" = c(0.95), "sizeNoise" = c(0.8), "alpha" = c(1,5,10, 20))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha)

# COLOR-SUFFICIENT SCENARIO Medium Variation

## English

english_sizeOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_cs_med, utterances_eng_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

english_sizeOvermodification_med = mutate(english_sizeOvermodification_med, state = states_color_med, .before = colorNoise)
english_sizeOvermodification_med = mutate(english_sizeOvermodification_med, nounNoise = 0.99, .before = alpha)
english_sizeOvermodification_med = mutate(english_sizeOvermodification_med, Utterance = utterance_eng, .before = speakerProb)
english_sizeOvermodification_med$Language <- "English"

## Spanish

sp_sizeOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp, states_cs_med, utterances_sp_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

sp_sizeOvermodification_med = mutate(sp_sizeOvermodification_med, state = states_color_med, .before = colorNoise)
sp_sizeOvermodification_med = mutate(sp_sizeOvermodification_med, nounNoise = 0.99, .before = alpha)
sp_sizeOvermodification_med = mutate(sp_sizeOvermodification_med, Utterance = utterance_sp, .before = speakerProb)
sp_sizeOvermodification_med$Language <- "Spanish"

## French

fr_sizeOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_fr, states_cs_med, utterances_fr_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

fr_sizeOvermodification_med = mutate(fr_sizeOvermodification_med, state = states_color_med, .before = colorNoise)
fr_sizeOvermodification_med = mutate(fr_sizeOvermodification_med, nounNoise = 0.99, .before = alpha)
fr_sizeOvermodification_med = mutate(fr_sizeOvermodification_med, Utterance = utterance_fr, .before = speakerProb)
fr_sizeOvermodification_med$Language <- "French"

## Vietnamese

vt_sizeOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_vt, states_cs_med, utterances_vt_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

vt_sizeOvermodification_med = mutate(vt_sizeOvermodification_med, state = states_color_med, .before = colorNoise)
vt_sizeOvermodification_med = mutate(vt_sizeOvermodification_med, nounNoise = 0.99, .before = alpha)
vt_sizeOvermodification_med = mutate(vt_sizeOvermodification_med, Utterance = utterance_vt, .before = speakerProb)
vt_sizeOvermodification_med$Language <- "Vietnamese"

sizeOvermodification_med <- rbind(english_sizeOvermodification_med, rbind(sp_sizeOvermodification_med,rbind(fr_sizeOvermodification_med,vt_sizeOvermodification_med)))
sizeOvermodification_med = mutate(sizeOvermodification_med, Context = "Medium Scene Variation", .before = Utterance)
sizeOvermodification_med = mutate(sizeOvermodification_med, Semantics = "Continuous", .before = Context)
sizeOvermodification_med = mutate(sizeOvermodification_med, Utility = "Incremental", .after = Semantics)
sizeOvermodification_med = mutate(sizeOvermodification_med, Redundancy = "Size Redundant", .before = Semantics)

# SIZE-SUFFICIENT SCENARIO Medium Variation

## English

english_colorOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_ss_med, utterances_eng_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

english_colorOvermodification_med = mutate(english_colorOvermodification_med, state = states_size_med, .before = colorNoise)
english_colorOvermodification_med = mutate(english_colorOvermodification_med, nounNoise = 0.99, .before = alpha)
english_colorOvermodification_med = mutate(english_colorOvermodification_med, Utterance = utterance_eng, .before = speakerProb)
english_colorOvermodification_med$Language <- "English"

## Spanish

sp_colorOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp, states_ss_med, utterances_sp_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

sp_colorOvermodification_med = mutate(sp_colorOvermodification_med, state = states_size_med, .before = colorNoise)
sp_colorOvermodification_med = mutate(sp_colorOvermodification_med, nounNoise = 0.99, .before = alpha)
sp_colorOvermodification_med = mutate(sp_colorOvermodification_med, Utterance = utterance_sp, .before = speakerProb)
sp_colorOvermodification_med$Language <- "Spanish"

## French

fr_colorOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_fr, states_ss_med, utterances_fr_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))
fr_colorOvermodification_med = mutate(fr_colorOvermodification_med, state = states_size_med, .before = colorNoise)
fr_colorOvermodification_med = mutate(fr_colorOvermodification_med, nounNoise = 0.99, .before = alpha)
fr_colorOvermodification_med = mutate(fr_colorOvermodification_med, Utterance = utterance_fr, .before = speakerProb)
fr_colorOvermodification_med$Language <- "French"

## Vietnamese

vt_colorOvermodification_med <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_vt, states_ss_med, utterances_vt_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

vt_colorOvermodification_med = mutate(vt_colorOvermodification_med, state = states_size_med, .before = colorNoise)
vt_colorOvermodification_med = mutate(vt_colorOvermodification_med, nounNoise = 0.99, .before = alpha)
vt_colorOvermodification_med = mutate(vt_colorOvermodification_med, Utterance = utterance_vt, .before = speakerProb)
vt_colorOvermodification_med$Language <- "Vietnamese"

colorOvermodification_med <- rbind(english_colorOvermodification_med, rbind(sp_colorOvermodification_med,rbind(fr_colorOvermodification_med,vt_colorOvermodification_med)))
colorOvermodification_med = mutate(colorOvermodification_med, Context = "Medium Scene Variation", .before = Utterance)
colorOvermodification_med = mutate(colorOvermodification_med, Semantics = "Continuous", .before = Context)
colorOvermodification_med = mutate(colorOvermodification_med, Utility = "Incremental", .after = Semantics)
colorOvermodification_med = mutate(colorOvermodification_med, Redundancy = "Color Redundant", .before = Semantics)

data_med <- rbind(colorOvermodification_med, sizeOvermodification_med)

# COLOR-SUFFICIENT SCENARIO High Variation

## English

english_sizeOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_cs_high, utterances_eng_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

english_sizeOvermodification_high = mutate(english_sizeOvermodification_high, state = states_color_high, .before = colorNoise)
english_sizeOvermodification_high = mutate(english_sizeOvermodification_high, nounNoise = 0.99, .before = alpha)
english_sizeOvermodification_high = mutate(english_sizeOvermodification_high, Utterance = utterance_eng, .before = speakerProb)
english_sizeOvermodification_high$Language <- "English"

## Spanish

sp_sizeOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp, states_cs_high, utterances_sp_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

sp_sizeOvermodification_high = mutate(sp_sizeOvermodification_high, state = states_color_high, .before = colorNoise)
sp_sizeOvermodification_high = mutate(sp_sizeOvermodification_high, nounNoise = 0.99, .before = alpha)
sp_sizeOvermodification_high = mutate(sp_sizeOvermodification_high, Utterance = utterance_sp, .before = speakerProb)
sp_sizeOvermodification_high$Language <- "Spanish"

## French

fr_sizeOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_fr, states_cs_high, utterances_fr_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

fr_sizeOvermodification_high = mutate(fr_sizeOvermodification_high, state = states_color_high, .before = colorNoise)
fr_sizeOvermodification_high = mutate(fr_sizeOvermodification_high, nounNoise = 0.99, .before = alpha)
fr_sizeOvermodification_high = mutate(fr_sizeOvermodification_high, Utterance = utterance_fr, .before = speakerProb)
fr_sizeOvermodification_high$Language <- "French"

## Vietnamese

vt_sizeOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_vt, states_cs_high, utterances_vt_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

vt_sizeOvermodification_high = mutate(vt_sizeOvermodification_high, state = states_color_high, .before = colorNoise)
vt_sizeOvermodification_high = mutate(vt_sizeOvermodification_high, nounNoise = 0.99, .before = alpha)
vt_sizeOvermodification_high = mutate(vt_sizeOvermodification_high, Utterance = utterance_vt, .before = speakerProb)
vt_sizeOvermodification_high$Language <- "Vietnamese"

sizeOvermodification_high <- rbind(english_sizeOvermodification_high, rbind(sp_sizeOvermodification_high,rbind(fr_sizeOvermodification_high,vt_sizeOvermodification_high)))
sizeOvermodification_high = mutate(sizeOvermodification_high, Context = "High Scene Variation", .before = Utterance)
sizeOvermodification_high = mutate(sizeOvermodification_high, Semantics = "Continuous", .before = Context)
sizeOvermodification_high = mutate(sizeOvermodification_high, Utility = "Incremental", .after = Semantics)
sizeOvermodification_high = mutate(sizeOvermodification_high, Redundancy = "Size Redundant", .before = Semantics)

# SIZE-SUFFICIENT SCENARIO High Variation

## English

english_colorOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_ss_high, utterances_eng_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

english_colorOvermodification_high = mutate(english_colorOvermodification_high, state = states_size_high, .before = colorNoise)
english_colorOvermodification_high = mutate(english_colorOvermodification_high, nounNoise = 0.99, .before = alpha)
english_colorOvermodification_high = mutate(english_colorOvermodification_high, Utterance = utterance_eng, .before = speakerProb)
english_colorOvermodification_high$Language <- "English"

## Spanish

sp_colorOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp, states_ss_high, utterances_sp_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

sp_colorOvermodification_high = mutate(sp_colorOvermodification_high, state = states_size_high, .before = colorNoise)
sp_colorOvermodification_high = mutate(sp_colorOvermodification_high, nounNoise = 0.99, .before = alpha)
sp_colorOvermodification_high = mutate(sp_colorOvermodification_high, Utterance = utterance_sp, .before = speakerProb)
sp_colorOvermodification_high$Language <- "Spanish"

## French

fr_colorOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_fr, states_ss_high, utterances_fr_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))
fr_colorOvermodification_high = mutate(fr_colorOvermodification_high, state = states_size_high, .before = colorNoise)
fr_colorOvermodification_high = mutate(fr_colorOvermodification_high, nounNoise = 0.99, .before = alpha)
fr_colorOvermodification_high = mutate(fr_colorOvermodification_high, Utterance = utterance_fr, .before = speakerProb)
fr_colorOvermodification_high$Language <- "French"

## Vietnamese

vt_colorOvermodification_high <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_vt, states_ss_high, utterances_vt_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0, sizeCost = 0, nounCost = 0))

vt_colorOvermodification_high = mutate(vt_colorOvermodification_high, state = states_size_high, .before = colorNoise)
vt_colorOvermodification_high = mutate(vt_colorOvermodification_high, nounNoise = 0.99, .before = alpha)
vt_colorOvermodification_high = mutate(vt_colorOvermodification_high, Utterance = utterance_vt, .before = speakerProb)
vt_colorOvermodification_high$Language <- "Vietnamese"

colorOvermodification_high <- rbind(english_colorOvermodification_high, rbind(sp_colorOvermodification_high,rbind(fr_colorOvermodification_high,vt_colorOvermodification_high)))
colorOvermodification_high = mutate(colorOvermodification_high, Context = "High Scene Variation", .before = Utterance)
colorOvermodification_high = mutate(colorOvermodification_high, Semantics = "Continuous", .before = Context)
colorOvermodification_high = mutate(colorOvermodification_high, Utility = "Incremental", .after = Semantics)
colorOvermodification_high = mutate(colorOvermodification_high, Redundancy = "Color Redundant", .before = Semantics)

data_high <- rbind(colorOvermodification_high, sizeOvermodification_high)

total_data <- rbind(data_med, data_high)

write.csv(total_data, "../series/series1/model_output/total_data_all_simulations.csv", row.names = FALSE)

# write.csv(colorOvermodification_med, "../series/series1/model_output/color_Overmodification_med_six_red_pin_no_cost_medium_var.csv", row.names = FALSE)
# write.csv(sizeOvermodification_med, "../series/series1/model_output/size_Overmodification_med_six_red_pin_no_cost_medium_var.csv", row.names = FALSE)
#view(modelAndSemantics)

# # PREDICTIONS PLOTS
#
# plot <- function(probDF) {
#   probDF$speakerProb <- as.numeric(probDF$speakerProb)
#   p <- ggplot(probDF, aes(x=sizeNoise,y=colorNoise,color=speakerProb)) +
#     geom_point(size=5,shape=15) +
#     scale_x_continuous(limits=c(.45,1.0),breaks=seq(.475,1.0,.525),labels=c(0.5,1)) +
#     scale_y_continuous(limits=c(.45,1.0),breaks=seq(.475,1.0,.525),labels=c(0.5,1)) +
#     scale_colour_viridis(limits=c(0,1), name="Probability of\nutterance") +
#     facet_grid(alpha~language) +
#     xlab("Semantic value of size") +
#     ylab("Semantic value of color") +
#     theme(panel.spacing=unit(.25, "lines"),
#           panel.border = element_rect(color = "black", fill = NA, size = 1),
#           # axis.text.x = element_text(angle = 20, hjust=1),
#           axis.text.y = element_text(hjust=0.5)) +
#     xlab(element_blank()) +
#     ylab(element_blank())
#   return(p)
# }
#
# color_plot <- plot(colorOvermodification_med) +
#   theme(strip.text.y = element_blank(),
#         legend.position = "none") +
#   ggtitle("Redundant color modification")
#
# size_plot <- plot(sizeOvermodification_med) +
#   theme(axis.text.y = element_blank(),
#         axis.ticks.y = element_blank(),
#         legend.position = "none") +
#   ylab(element_blank()) +
#   ggtitle("Redundant size modification")
#
# legend <- plot_grid(get_legend(color_plot + theme(legend.position = "right")))
#
# graphs <- arrangeGrob(grobs = list(color_plot, size_plot), ncol = 2, bottom = 'Semantic value of size', left = 'Semantic value of color', right = 'Alpha')
#
# g <- arrangeGrob(graphs, legend, ncol = 2, widths = c(0.85, 0.15))
#
# ggsave(g, filename = "scilpreds.pdf", height = 4, width = 8, units = "in", dpi = 1000)
#
# ### SCIL MODEL COMPARISON
#
# ### W/ RENAMING FOR NSF APPLICATION
#
# base = 6
# expand = 3
#
# graph <- function(probArray) {
#
#   toGraph <- data.frame(matrix(NA, nrow = 4, ncol = 3))
#   colnames(toGraph) <- c("language", "behavior", "probability")
#   # toGraph$language <- c("English", "English", "Spanish-postnom.", "Spanish-postnom.")
#   toGraph$language <- c("English", "English", "Spanish", "Spanish")
#   # toGraph$behavior <- c("Redundant color adjective (SS)", "Redundant size adjective (CS)",
#                         # "Redundant color adjective (SS)", "Redundant size adjective (CS)")
#   # LABELS FOR POSTER
#   toGraph$behavior <- c("Redundant color adjective", "Redundant size adjective",
#                         "Redundant color adjective", "Redundant size adjective")
#   toGraph$probability <- probArray
#
#   p <- ggplot(toGraph, aes(x=language, y=probability, fill = behavior)) +
#     theme_bw() +
#     theme(text = element_text(size = base * expand / 2, face = "bold")) +
#     ylab(element_blank()) +
#     xlab(element_blank()) +
#     geom_bar(stat="identity",position = "dodge") +
#     # scale_fill_viridis(discrete = TRUE) +
#     # color for the poster
#     scale_fill_manual(values=c("#4287f5","#fff200")) +
#     # for hypothetical graphs
#     theme(legend.title = element_blank(), legend.position="none", # axis.text.x = element_blank(),
#           axis.text.x = element_text(angle = 20, hjust=1),
#     )
#
#   return(p)
