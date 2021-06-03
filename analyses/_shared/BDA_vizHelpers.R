graphPosteriors <- function(posteriors) {
  return(ggplot(posteriors, aes(x = value)) +
           theme_bw() +
           facet_wrap(~Parameter, scales = "free") +
           geom_density(alpha = 0.05))
}

graphPredictives <- function(predictives, df) {
  
  predictives$type = "prediction"
  df$type = "observation"
  
  predictives <- rbind(predictives %>% select(condition, size_color, color, size, type), 
                       df %>% select(condition, size_color, color, size, type)) %>%
    gather(utterance, value, c(-condition, -type)) %>%
    spread(type, value) %>%
    mutate(scene = ifelse(grepl("color", condition, fixed = TRUE), "Size redundant", "Color redundant"))
  
  ggplot(predictives, aes(x = prediction, y = observation, color = utterance, shape = scene)) +
    geom_point() +
    theme_bw() +
    annotate("text", x = 0.75, y = 0, label = sprintf("r = %f", cor(predictives$prediction, predictives$observation)))
  
}
