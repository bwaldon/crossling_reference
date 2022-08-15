library(tidyverse)

#Import data
# we have two sets of cost parameters that we are interested in
dirname(rstudioapi::getActiveDocumentContext()$path)
genderOutput <- read.csv("stefanTestGenderNoise/scenariosOutputGender.csv", as.is = TRUE)

genderOutputCost0 <- genderOutput %>%
  filter(genderOutput$sizeCost == 0)

genderOutputCost1 <- genderOutput %>%
  filter(genderOutput$sizeCost == 0.1)

genderOutputCost2 <- genderOutput %>%
  filter(genderOutput$sizeCost == 0.2)

# Make plots for cost of words is 0
zeroCostSmallAlpha <- genderOutputCost0 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 0, ", "alpha: ", alpha,  ", nounNoise: 0.9", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

zeroCostBigAlpha <- genderOutputCost0 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 0, ", "alpha: ", alpha,  ", nounNoise: 0.9", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

oneCostSmallAlpha <- genderOutputCost1 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 1, ", "alpha: ", alpha,  ", nounNoise: 0.9", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

oneCostBigAlpha <- genderOutputCost1 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 1, ", "alpha: ", alpha,  ", nounNoise: 0.9", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

twoCostSmallAlpha <- genderOutputCost2 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 2, ", "alpha: ", alpha,  ", nounNoise: 0.9", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

twoCostBigAlpha <- genderOutputCost2 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 2, ", "alpha: ", alpha,  ", nounNoise: 0.9", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

#Export the plots
jpeg(file="stefanTestGenderNoise/Gender_zeroCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(zeroCostBigAlpha)
dev.off()

jpeg(file="stefanTestGenderNoise/Gender_zeroCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(zeroCostSmallAlpha)
dev.off()

jpeg(file="stefanTestGenderNoise/Gender_oneCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(oneCostBigAlpha)
dev.off()

jpeg(file="stefanTestGenderNoise/Gender_oneCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(oneCostSmallAlpha)
dev.off()

jpeg(file="stefanTestGenderNoise/Gender_twoCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(twoCostBigAlpha)
dev.off()

jpeg(file="stefanTestGenderNoise/Gender_twoCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(twoCostSmallAlpha)
dev.off()


########
# English Sanity Check
########
englishSanity <- read.csv("stefanTestGenderNoise/scenariosOutputEnglishSanityCheck.csv", as.is = TRUE)

sanityOutputCost0 <- englishSanity %>%
  filter(englishSanity$sizeCost == 0)

sanityOutputCost1 <- englishSanity %>%
  filter(englishSanity$sizeCost == 0.1)

sanityOutputCost2 <- englishSanity %>%
  filter(englishSanity$sizeCost == 0.2)

# Make plots for cost of words is 0
zeroCostSmallAlphaSanity <- sanityOutputCost0 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 0, ", "alpha: ", alpha, ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 5) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

zeroCostBigAlphaSanity <- sanityOutputCost0 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 0, ", "alpha: ", alpha, ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 5) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

oneCostSmallAlphaSanity <- sanityOutputCost1 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 1, ", "alpha: ", alpha, ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 5) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

oneCostBigAlphaSanity <- sanityOutputCost1 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 1, ", "alpha: ", alpha, ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 5) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

twoCostSmallAlphaSanity <- sanityOutputCost2 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 2, ", "alpha: ", alpha, ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 5) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

twoCostBigAlphaSanity <- sanityOutputCost2 %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 2, ", "alpha: ", alpha, ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 5) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

#Export the plots
jpeg(file="stefanTestGenderNoise/Sanity_zeroCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(zeroCostBigAlphaSanity)
dev.off()

jpeg(file="stefanTestGenderNoise/Sanity_zeroCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(zeroCostSmallAlphaSanity)
dev.off()

jpeg(file="stefanTestGenderNoise/Sanity_oneCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(oneCostBigAlphaSanity)
dev.off()

jpeg(file="stefanTestGenderNoise/Sanity_oneCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(oneCostSmallAlphaSanity)
dev.off()

jpeg(file="stefanTestGenderNoise/Sanity_twoCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(twoCostBigAlphaSanity)
dev.off()

jpeg(file="stefanTestGenderNoise/Sanity_twoCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(twoCostSmallAlphaSanity)
dev.off()




########
#Low Noun Noise
########
genderOutputLN <- read.csv("stefanTestGenderNoise/scenariosOutputGenderLowNounNoise.csv", as.is = TRUE)

genderOutputCost0LN <- genderOutputLN %>%
  filter(genderOutput$sizeCost == 0)

genderOutputCost1LN <- genderOutputLN %>%
  filter(genderOutput$sizeCost == 0.1)

genderOutputCost2LN <- genderOutputLN %>%
  filter(genderOutput$sizeCost == 0.2)

# Make plots for cost of words is 0
zeroCostSmallAlphaLN <- genderOutputCost0LN %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 0, ", "alpha: ", alpha,  ", nounNoise: 0.8", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

zeroCostBigAlphaLN <- genderOutputCost0LN %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 0, ", "alpha: ", alpha,  ", nounNoise: 0.8", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

oneCostSmallAlphaLN <- genderOutputCost1LN %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 1, ", "alpha: ", alpha,  ", nounNoise: 0.8", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

oneCostBigAlphaLN <- genderOutputCost1LN %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 1, ", "alpha: ", alpha,  ", nounNoise: 0.8", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

twoCostSmallAlphaLN <- genderOutputCost2LN %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("cost: 2, ", "alpha: ", alpha,  ", nounNoise: 0.8", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

twoCostBigAlphaLN <- genderOutputCost2LN %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("cost: 2, ", "alpha: ", alpha,  ", nounNoise: 0.8", ", genderNoise: ", genderNoise, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 4) +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90))

#Export the plots
jpeg(file="stefanTestGenderNoise/GenderLNN_zeroCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(zeroCostBigAlphaLN)
dev.off()

jpeg(file="stefanTestGenderNoise/GenderLNN_zeroCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(zeroCostSmallAlphaLN)
dev.off()

jpeg(file="stefanTestGenderNoise/GenderLNN_oneCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(oneCostBigAlphaLN)
dev.off()

jpeg(file="stefanTestGenderNoise/GenderLNN_oneCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(oneCostSmallAlphaLN)
dev.off()

jpeg(file="stefanTestGenderNoise/GenderLNN_twoCostBigAlpha.jpeg", width = 1500, height = 1000)
plot(twoCostBigAlphaLN)
dev.off()

jpeg(file="stefanTestGenderNoise/GenderLNN_twoCostSmallAlpha.jpeg", width = 1500, height = 1000)
plot(twoCostSmallAlphaLN)
dev.off()

