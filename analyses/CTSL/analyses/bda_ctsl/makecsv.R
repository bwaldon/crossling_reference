######################################################
# PLOTS FOR THE COGSCI PAPER
######################################################

load("Results/5000sample50000burnin/ctsl_results_50000burnin.RData")

# modification type
empirical_toplot = d_uncollapsed %>%
  mutate(size = ifelse(response=="size",1,0)) %>%
  mutate(color = ifelse(response=="color",1,0)) %>%
  mutate(size_color = ifelse(response=="size_color",1,0)) %>%
  select(gameId,roundNumber,condition,response,size,color,size_color) %>%
  gather(utterance,value,size:size_color) %>%
  group_by(utterance,condition) %>%
  #summarize(Mean=mean(value)) %>%
  summarise(Mean=mean(value),CILow=ci.low(value),CIHigh=ci.high(value)) %>%
  ungroup() %>%
  mutate(YMin=Mean-CILow,YMax=Mean+CIHigh) %>%
  mutate(model="empirical")

vanilla_toplot = vanillaPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="vanilla")

continuous_toplot = continuousPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="continuous")

incremental_toplot = incrementalPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="incremental")

incrementalContinuous_toplot = incrementalContinuousPredictives %>%
  gather(utterance,Mean,size_color:size) %>%
  mutate(model="incrementalContinuous")

#merge ctsl datasets
ctsl_models = rbind(vanilla_toplot,continuous_toplot,incremental_toplot,incrementalContinuous_toplot) %>%
  mutate(CILow=0,CIHigh=0,YMin=0,YMax=0)

ctsl_merged = rbind(empirical_toplot,ctsl_models) %>%
  mutate(condition=ifelse(condition=="color31","color sufficient",ifelse(condition=="size31","size sufficient",NA))) %>%
  mutate(language="CTSL")

#merge ctsl and english datasets 
english_merged = read_csv("english_modelComp.csv") %>% select(utterance,condition,Mean,CIHigh,CILow,YMin,YMax,model,language)

merged = rbind(ctsl_merged,english_merged)

merged$model = factor(merged$model, levels = c("empirical", "vanilla","continuous","incremental","incrementalContinuous"))

ggplot(merged, aes(x=utterance,y=Mean, fill=model)) +
  geom_bar(position="dodge", stat = "identity") +
  facet_grid(language~condition)

write.csv(merged, "utteranceProbabilities.csv", row.names=TRUE)

ggsave("results/merged_modelComparison.png")