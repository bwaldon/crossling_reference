# runModel: a function for running speaker/listener models with fixed parameter values. 
# backend: either 'V8' or 'rwebppl'. The former is typically faster for running numerous sequential calls to WebPPL.
# engine: a string, typically the kernel of webppl code found under "_shared/engine.txt"
# modelAndSemantics: a string-type chunk of webppl code, where a model and a word-level semantics are defined, each as functions of free parameter values. (See the repo for examples).
# states: a vector of strings, each corresponding to a state.
# utterances: a vector of strings, each corresponding to a complete utterance.

runModel <- function(backend, engine, model, semantics, semanticHelperFunctions, cmd, states, allUtterances,
                    alpha = 1, sizeNoiseVal = 1, colorNoiseVal = 1, 
                     genderNoiseVal = 1, nounNoiseVal = 1,
                     sizeCost = 0, colorCost = 0, nounCost = 0) {

  preamble <- sprintf("var params = {
    alpha : %f,
    sizeNoiseVal : %f,
    colorNoiseVal : %f,
    genderNoiseVal : %f,
    nounNoiseVal : %f,
    sizeCost : %f,
    colorCost : %f,
    nounCost : %f
  }
  
var semantics = semantics(params)
    
var model = extend(model(params), \n {states : %s, utterances : %s}) 
                 ", alpha, sizeNoiseVal, colorNoiseVal, genderNoiseVal, nounNoiseVal, sizeCost, colorCost, nounCost, states, allUtterances)
  code <- paste(semantics, semanticHelperFunctions, model, preamble, engine, cmd, sep = "\n")
  
  write_file(code, "temp.js")
  
  if(backend == "rwebppl") {
    
    return(webppl(code))
    
  } else if(backend == "V8") {
    
    return(evalWebPPL_V8(code))
    
  }
  
}
