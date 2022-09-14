library(tidyverse)
library(GGally)
theme_set(theme_bw(18))

this.dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(this.dir)

# READ DATA

freq = read.csv(file = '../shared/frequencies.csv')

my_fn <- function(data, mapping, ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_point() + 
    geom_smooth(method = 'lm', formula = 'y ~ x')
  p
}

#Pm stands for per million
#CD stands for context diversity 
#nbcar is number of characters

freq <- freq %>%
  select(colorScheme, gender, eng, bcs, 
         BosBlogFreqPm, BosTwitterFreqPm, BosNewsFreqPm,
         CroBlogFreqPm, CroTwitterFreqPm, CroNewsFreqPm,
         SrbBlogFreqPm, SrbTwitterFreqPm, SrbNewsFreqPm) %>%
  mutate(BosnianAverage = (BosBlogFreqPm + BosNewsFreqPm)/2,
         CroatianAverage = (CroBlogFreqPm + CroTwitterFreqPm + CroNewsFreqPm)/3,
         SerbianAverage = (SrbBlogFreqPm + SrbTwitterFreqPm + SrbNewsFreqPm)/3,
         blogAverage = (BosBlogFreqPm + CroBlogFreqPm + SrbBlogFreqPm)/3,
         twitterAverage = (CroTwitterFreqPm + SrbTwitterFreqPm)/2,
         newsAverage = (BosNewsFreqPm + CroNewsFreqPm + SrbNewsFreqPm)/3,
         BosnianLog = -log((BosBlogFreqPm + BosNewsFreqPm)/2000000),
         CroatianLog = -log((CroBlogFreqPm + CroTwitterFreqPm + CroNewsFreqPm)/3000000),
         SerbianLog = -log((SrbBlogFreqPm + SrbTwitterFreqPm + SrbNewsFreqPm)/3000000),
         blogLog = -log((BosBlogFreqPm + CroBlogFreqPm + SrbBlogFreqPm)/3000000),
         twitterLog = -log((CroTwitterFreqPm + SrbTwitterFreqPm)/2000000),
         newsLog = -log((BosNewsFreqPm + CroNewsFreqPm + SrbNewsFreqPm)/3000000)) %>%
  mutate(BosnianLog = case_when(BosnianLog == Inf ~ 18,
                                TRUE ~ BosnianLog),
         CroatianLog = case_when(CroatianLog == Inf ~ 18,
                                TRUE ~ CroatianLog),
         SerbianLog = case_when(SerbianLog == Inf ~ 18,
                                TRUE ~ SerbianLog),
         blogLog = case_when(blogLog == Inf ~ 25,
                                TRUE ~ blogLog),
         twitterLog = case_when(twitterLog == Inf ~ 18,
                                TRUE ~ twitterLog),
         newsLog = case_when(newsLog == Inf ~ 18,
                                TRUE ~ newsLog))

freq <- freq %>%
  mutate(BosnianNewsLog = -log(BosNewsFreqPm),
         BosnianBlogLog = -log(BosBlogFreqPm),
         CroatianNewsLog = -log(CroNewsFreqPm),
         CroatianTwitterLog = -log(CroTwitterFreqPm),
         CroatianBlogLog = -log(CroBlogFreqPm),
         SerbianNewsLog = -log(SrbNewsFreqPm),
         SerbianTwitterLog = -log(SrbTwitterFreqPm),
         SerbianBlogLog = -log(SrbBlogFreqPm)) %>%
  mutate(BosnianNewsLog = case_when(BosnianNewsLog == Inf ~ 3,
                                    TRUE ~ BosnianNewsLog),
         BosnianBlogLog = case_when(BosnianBlogLog == Inf ~ 3,
                                    TRUE ~ BosnianBlogLog),
         CroatianNewsLog = case_when(CroatianNewsLog == Inf ~ 3,
                                     TRUE ~ CroatianNewsLog),
         CroatianTwitterLog = case_when(CroatianTwitterLog == Inf ~ 3,
                                        TRUE ~ CroatianTwitterLog),
         CroatianBlogLog = case_when(CroatianBlogLog == Inf ~ 3,
                                     TRUE ~ CroatianBlogLog),
         SerbianNewsLog = case_when(SerbianNewsLog == Inf ~ 3,
                                    TRUE ~ SerbianNewsLog),
         SerbianTwitterLog = case_when(SerbianTwitterLog == Inf ~ 3,
                                       TRUE ~ SerbianTwitterLog),
         SerbianBlogLog = case_when(SerbianBlogLog == Inf ~ 3,
                                    TRUE ~ SerbianBlogLog)
  )

# Language Frequency pairwise plots
pairwiseLanguagePlot <- freq %>%
  ggpairs(columns = c("BosnianLog", "CroatianLog", "SerbianLog"), 
            lower = list(continuous = my_fn)) +
  ggtitle("Pairwise correlation of Languages")

pairwiseLanguagePlot
ggsave(filename = "viz/pairwiseLanguageFreqCorr.pdf", plot = pairwiseLanguagePlot,
       width = 6, height = 6, units = "in", device = "pdf")

#idk where the three 20.0 values are coming from in SerbianLog


# Frequency Type Pairwise correlation plots
pairwiseFreqTypePlot <- freq %>%
  ggpairs(columns = c("newsLog", "blogLog", "twitterLog"), 
          lower = list(continuous = my_fn)) +
  ggtitle("Pairwise corr. of frequency corpora")

pairwiseFreqTypePlot

ggsave(filename = "viz/pairwiseFreqTypeCorr.pdf", plot = pairwiseFreqTypePlot,
       width = 6, height = 6, units = "in", device = "pdf")

## Frequency type by language

BosnianFreqTypePlot <- freq %>%
  ggpairs(columns = c("BosnianNewsLog", "BosnianBlogLog"), 
          lower = list(continuous = my_fn)) +
  ggtitle("Pairwise corr. of Bosnian corpora")

BosnianFreqTypePlot
ggsave(filename = "viz/bosnianFreqCorr.pdf", plot = BosnianFreqTypePlot,
       width = 6, height = 6, units = "in", device = "pdf")



CroatianFreqTypePlot <- freq %>%
  ggpairs(columns = c("CroatianNewsLog", "CroatianTwitterLog", "CroatianBlogLog"), 
          lower = list(continuous = my_fn))+
  ggtitle("Pairwise corr. of Croatian corpora")

CroatianFreqTypePlot

ggsave(filename = "viz/croatianFreqCorr.pdf", plot = CroatianFreqTypePlot,
       width = 6, height = 6, units = "in", device = "pdf")




SerbianFreqTypePlot <- freq %>%
  ggpairs(columns = c("SerbianNewsLog", "SerbianTwitterLog", "SerbianBlogLog"), 
          lower = list(continuous = my_fn))+
  ggtitle("Pairwise corr. of Serbian corpora")

SerbianFreqTypePlot

ggsave(filename = "viz/serbianFreqCorr.pdf", plot = SerbianFreqTypePlot,
       width = 6, height = 6, units = "in", device = "pdf")
