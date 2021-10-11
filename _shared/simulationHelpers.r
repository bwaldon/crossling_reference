runModel <- function(backend, engine, modelAndSemantics, cmd, states, utterances, alpha = 1, sizeNoiseVal = 1, colorNoiseVal = 1, 
                     sizeCost = 0, colorCost = 0, nounCost = 0) {
  
  preamble <- sprintf("var params = {
    alpha : %f,
    sizeNoiseVal : %f,
    colorNoiseVal : %f,
    sizeCost : %f,
    colorCost : %f,
    nounCost : %f
  }
    
var model = extend(model(params), \n {states : %s, utterances : %s}) 
                 ", alpha, sizeNoiseVal, colorNoiseVal, sizeCost, colorCost, nounCost, toJSON(states), toJSON(utterances))
  
  code <- paste(modelAndSemantics, preamble, engine, cmd, sep = "\n")
  
  write_file(code, "temp.js")
  
  if(backend == "rwebppl") {
    
    return(webppl(code))
    
  } else if(backend == "V8") {
    
    return(evalWebPPL_V8(code))
    
  }
  
}
