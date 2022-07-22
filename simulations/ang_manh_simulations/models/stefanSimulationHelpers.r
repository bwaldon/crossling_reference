# runModel: a function for running speaker/listener models with fixed parameter values. 
# backend: either 'V8' or 'rwebppl'. The former is typically faster for running numerous sequential calls to WebPPL.
# engine: a string, typically the kernel of webppl code found under "_shared/engine.txt"
# modelAndSemantics: a string-type chunk of webppl code, where a model and a word-level semantics are defined, each as functions of free parameter values. (See the repo for examples).
# states: a vector of strings, each corresponding to a state.
# utterances: a vector of strings, each corresponding to a complete utterance.
createEnv <- function(envCode, refs, noun, adj, sizeAdj, sizeNoise, colorNoise, nounNoise) {
  preamble <- sprintf("var referents = %s
    var size_semvalue = %f
    var color_semvalue = %f
    var noun_semvalue = %f
    var noun = %s
    var adj = %s
    var sizeAdj = %s", refs, sizeNoise, colorNoise, nounNoise, noun, adj, sizeAdj)
  code <- paste(preamble, envCode, sep ='\n')
  
  write_file(code, "temp2.js")
  return (evalWebPPL_V8(code))
}

runModel_2 <- function(backend, engine, environment, lang, alpha = 1, size_noise = 1, color_noise = 1, noun_noise = 1, cost = 0){
  preamble <- sprintf("var states = [%s]
                      var semantics = [[%s]]
                      var words = [%s]
                      var utterances = [[%s]]", environment$states, environment$semantics, environment$words, environment$utterances)
  postamble <- sprintf("incrementalUtteranceSpeaker(\"START small blue pin STOP\", \"R1\", %f)", lang)
  code <- paste(preamble, engine, postamble, sep = '\n')
  write_file(code, 'temp3.js')
  return (evalWebPPL_V8(code))
}
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
