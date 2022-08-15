library(tidyverse)

#Import data
# we have two sets of cost parameters that we are interested in
dirname(rstudioapi::getActiveDocumentContext()$path)
smallCostData <- read.csv("stefanTestCost/scenariosOutputSmallTestCost.csv", as.is = TRUE)
bigCostData <- read.csv("stefanTestCost/scenariosOutputBigTestCost.csv", as.is = TRUE)

# Make plots for the two sets of cost parameters
smallCostSmallAlpha <- smallCostData %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("alpha: ", alpha, ", sizeCost: ", sizeCost, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 3) +
  theme(axis.text.x = element_text(angle = 90))

smallCostBigAlpha <- smallCostData %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("alpha: ", alpha, ", sizeCost: ", sizeCost, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 3) +
  theme(axis.text.x = element_text(angle = 90))

bigCostSmallAlpha <- bigCostData %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha < 10) %>%
  mutate(identifier = paste("alpha: ", alpha, ", sizeCost: ", sizeCost, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 3) +
  theme(axis.text.x = element_text(angle = 90))

bigCostBigAlpha <- bigCostData %>%
  group_by(alpha,sizeCost) %>%
  filter(alpha > 10) %>%
  mutate(identifier = paste("alpha: ", alpha, ", sizeCost: ", sizeCost, sep = '')) %>%
  ggplot(aes(x=utterance,y=output)) + 
  geom_bar(stat="identity") + 
  facet_wrap(~identifier, ncol = 3) +
  theme(axis.text.x = element_text(angle = 90))

#Export the plots
jpeg(file="stefanTestCost/smallCostSmallAlpha.jpeg", width = 1000, height = 1300)
plot(smallCostSmallAlpha)
dev.off()

jpeg(file="stefanTestCost/smallCostBigAlpha.jpeg", width = 1000, height = 1300)
plot(smallCostBigAlpha)
dev.off()

jpeg(file="stefanTestCost/bigCostSmallAlpha.jpeg", width = 1000, height = 1300)
plot(bigCostSmallAlpha)
dev.off()

jpeg(file="stefanTestCost/bigCostBigAlpha.jpeg", width = 1000, height = 1300)
plot(bigCostBigAlpha)
dev.off()
