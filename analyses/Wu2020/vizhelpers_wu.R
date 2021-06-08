graphPosteriors <- function(posteriors) {
  return(ggplot(posteriors, aes(x = value)) +
           theme_bw() +
           facet_wrap(~Parameter, scales = "free") +
           geom_density(alpha = 0.05))
}

graphPredictives <- function(predictives, df) {
  
  d <- cbind(predictives,df)
  d <- d[, !duplicated(colnames(d))] %>%
    gather("type", "value", predictedMention, observedMention) %>%
    group_by(language,type,kind) %>%
    summarize(mean = mean(value))
  
  ggplot()
  ggplot(d, aes(x = type, y = mean, fill = language)) +
    facet_wrap(~kind) +
    geom_bar(stat="identity", position = "dodge") +
    theme_bw() # +
    # annotate("text", x = 0.75, y = 0, label = sprintf("r = %f", cor(d$observedMention,d$predictedMention)))
  
}
