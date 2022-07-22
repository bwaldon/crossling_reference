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

View(modelAndSemantics)
View(engine)
# STATES

states_ss = c("smallbluepin", "bigbluepin", "bigredpin", "smallblueball", "bigredpin", "bigredpin")
states_cs = c("smallbluepin", "smallredpin", "bigredpin", "smallblueball", "bigredpin", "bigredpin")

states_color <- "smallbluepin, smallredpin, bigredpin, smallblueball, bigredpin, bigredpin"
states_size <- "smallbluepin, bigbluepin, bigredpin, smallblueball, bigredpin, bigredpin"

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

# VALDF FOR SCIL PAPER

valDF <- data.frame("colorNoise" = c(0.95), "sizeNoise" = c(0.8), "alpha" = c(1,5,10, 20))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha) %>%
  filter(alpha %in% c(1,5,10, 20))

# VALDF FOR SCIL APP

valDF <- data.frame("colorNoise" = c(0.95), "sizeNoise" = c(0.8), "alpha" = c(1,5,10, 20))
valDF <- valDF %>%
  expand(colorNoise, sizeNoise, alpha)

# COLOR-SUFFICIENT SCENARIO 

## English

english_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_cs, utterances_eng_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

english_sizeOvermodification = mutate(english_sizeOvermodification, state = states_color, .before = colorNoise)
english_sizeOvermodification = mutate(english_sizeOvermodification, nounNoise = 0.99, .before = alpha)
 english_sizeOvermodification$language <- "English"

## Spanish

sp_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp, states_cs, utterances_sp_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

sp_sizeOvermodification = mutate(sp_sizeOvermodification, state = states_color, .before = colorNoise)
sp_sizeOvermodification = mutate(sp_sizeOvermodification, nounNoise = 0.99, .before = alpha)
sp_sizeOvermodification$language <- "Spanish"

## French

fr_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_fr, states_cs, utterances_fr_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

fr_sizeOvermodification = mutate(fr_sizeOvermodification, state = states_color, .before = colorNoise)
fr_sizeOvermodification = mutate(fr_sizeOvermodification, nounNoise = 0.99, .before = alpha)
fr_sizeOvermodification$language <- "French"

## Vietnamese

vt_sizeOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_vt, states_cs, utterances_vt_cs, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise, 
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

vt_sizeOvermodification = mutate(vt_sizeOvermodification, state = states_color, .before = colorNoise)
vt_sizeOvermodification = mutate(vt_sizeOvermodification, nounNoise = 0.99, .before = alpha)
vt_sizeOvermodification$language <- "Vietnamese"

sizeOvermodification <- rbind(english_sizeOvermodification, rbind(sp_sizeOvermodification,rbind(fr_sizeOvermodification,vt_sizeOvermodification)))

# SIZE-SUFFICIENT SCENARIO

## English

english_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_eng, states_ss, utterances_eng_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

english_colorOvermodification = mutate(english_colorOvermodification, state = states_size, .before = colorNoise)
english_colorOvermodification = mutate(english_colorOvermodification, nounNoise = 0.99, .before = alpha)
english_colorOvermodification$language <- "English"

## Spanish

sp_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_sp, states_ss, utterances_sp_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

sp_colorOvermodification = mutate(sp_colorOvermodification, state = states_size, .before = colorNoise)
sp_colorOvermodification = mutate(sp_colorOvermodification, nounNoise = 0.99, .before = alpha)
sp_colorOvermodification$language <- "Spanish"

## French

fr_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_fr, states_ss, utterances_fr_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))
fr_colorOvermodification = mutate(fr_colorOvermodification, state = states_size, .before = colorNoise)
fr_colorOvermodification = mutate(fr_colorOvermodification, nounNoise = 0.99, .before = alpha)
fr_colorOvermodification$language <- "French"

## Vietnamese

vt_colorOvermodification <- valDF %>%
  group_by(colorNoise, sizeNoise, alpha) %>%
  mutate(speakerProb = runModel('V8', engine, modelAndSemantics, cmd_vt, states_ss, utterances_vt_ss, alpha, sizeNoiseVal = sizeNoise, colorNoiseVal = colorNoise,
                                colorCost = 0.1, sizeCost = 0.1, nounCost = 0.1))

vt_colorOvermodification = mutate(vt_colorOvermodification, state = states_size, .before = colorNoise)
vt_colorOvermodification = mutate(vt_colorOvermodification, nounNoise = 0.99, .before = alpha)
vt_colorOvermodification$language <- "Vietnamese"

colorOvermodification <- rbind(english_colorOvermodification, rbind(sp_colorOvermodification,rbind(fr_colorOvermodification,vt_colorOvermodification)))

#write.csv(colorOvermodification, "/Users/simonscholar/Desktop/Ling_Repo/crossling_reference/simulations/ang_manh_simulations/series/series1/model_output/color_overmodification_four_red_pin_medium_var.csv", row.names = FALSE)
#write.csv(sizeOvermodification, "/Users/simonscholar/Desktop/Ling_Repo/crossling_reference/simulations/ang_manh_simulations/series/series1/model_output/size_overmodification_four_red_pin_medium_var.csv", row.names = FALSE)
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
# color_plot <- plot(colorOvermodification) +
#   theme(strip.text.y = element_blank(),
#         legend.position = "none") +
#   ggtitle("Redundant color modification")
# 
# size_plot <- plot(sizeOvermodification) +
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


