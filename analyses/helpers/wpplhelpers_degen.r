makeModel <- function(header) {
  
  return(paste(read_file(header), read_file("../_shared/engine.txt"), sep = "\n"))
  
}

wrapInference <- function(model, overmodifyingUtterance, targetReferent, inferenceType) {
  
  if(inferenceType == "incrementalContinuous") {
    inferenceCommand <- read_file("inferenceCommands/Degenetal/incrementalContinuous.txt")
    
  } else if(inferenceType == "incremental") {
    inferenceCommand <- read_file("inferenceCommands/Degenetal/incremental.txt")
    
  } else if(inferenceType == "continuous") {
    inferenceCommand <- read_file("inferenceCommands/Degenetal/continuous.txt")
    
  } else if(inferenceType == "vanilla") {
    inferenceCommand <- read_file("inferenceCommands/Degenetal/vanilla.txt")
    
  }
  
  inferenceCommand <- gsub("OVERMODIFYING_UTTERANCE", overmodifyingUtterance, inferenceCommand, fixed = TRUE)
  inferenceCommand <- gsub("TARGET_REFERENT", targetReferent, inferenceCommand, fixed = TRUE)
  
  return(paste(read_file(model), inferenceCommand, sep = "\n"))
  
}

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

wrapPrediction = function(model, estimates, overmodifyingUtterance, targetReferent, inferenceType) {
  
  if(inferenceType == "incrementalContinuous" | inferenceType == "incremental" ) {
    
    predictionCommand <- read_file("inferenceCommands/getIncrementalPredictions.txt")
    
  } else if (inferenceType == "continuous" | inferenceType == "vanilla" ) {
    
    predictionCommand <- read_file("inferenceCommands/getGlobalPredictions.txt")
    
  }
  
  predictionCommand <- paste((sprintf("var estimates = %s[0]", toJSON(estimates, digits = NA))), predictionCommand, sep = "\n")
  predictionCommand <- gsub("OVERMODIFYING_UTTERANCE", overmodifyingUtterance, predictionCommand, fixed = TRUE)
  predictionCommand <- gsub("TARGET_REFERENT", targetReferent, predictionCommand, fixed = TRUE)
  
  return(paste(read_file(model), predictionCommand, sep = "\n"))
  
}
