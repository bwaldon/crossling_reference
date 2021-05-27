estimate_mode <- function(s) {
  d <- density(s)
  return(d$x[which.max(d$y)])
}

getEstimates <- function(posteriors) {

  estimates <- posteriors %>%
    group_by(Parameter) %>%
    summarize(estimate = estimate_mode(value)) %>%
    mutate(estimate = ifelse(estimate < 0, 0, estimate)) %>%
    pivot_wider(names_from = Parameter, values_from = estimate)
  
  return(estimates)
  
}

wrapPrediction = function(model, estimates, inferenceType) {
  
  if(inferenceType == "incrementalContinuous" | inferenceType == "incremental" ) {
    
    predictionCommand <- read_file("inferenceCommands/WuGibson/getIncrementalPredictions.txt")
    
  } else if (inferenceType == "continuous" | inferenceType == "vanilla" ) {
    
    predictionCommand <- read_file("inferenceCommands/WuGibson/getGlobalPredictions.txt")
    
  }
  
  predictionCommand <- paste((sprintf("var estimates = %s[0]", toJSON(estimates, digits = NA))), predictionCommand, sep = "\n")
  
  return(paste(model, predictionCommand, sep = "\n"))
  
}
