# runModel: a function for running speaker/listener models with fixed parameter values. 
# backend: either 'V8' or 'rwebppl'. The former is typically faster for running numerous sequential calls to WebPPL.
# engine: a string, typically the kernel of webppl code found under "_shared/engine.txt"
# modelAndSemantics: a string-type chunk of webppl code, where a model and a word-level semantics are defined, each as functions of free parameter values. (See the repo for examples).
# states: a vector of strings, each corresponding to a state.
# utterances: a vector of strings, each corresponding to a complete utterance.
createEnv <- function(envCode, refs, noun, adj, sizeAdj, sizeNoise, colorNoise, nounNoise) {
  preamble <- sprintf("var referents = %s
    var size_semvalue = %s
    var color_semvalue = %s
    var noun_semvalue = %s
    var noun = %s
    var adj = %s
    var sizeAdj = %s", refs, sizeNoise, colorNoise, nounNoise, noun, adj, sizeAdj)
  code <- paste(preamble, envCode, sep ='\n')
  
  write_file(code, "temp2.js")
  return (evalWebPPL_V8(code))
}

runModel_2 <- function(backend, engine, environment,adjCost, nounCost, alpha, modelType,lang, adj, noun){
  preamble <- sprintf("var alpha = %s
                      var adj_cost = %s
                      var noun_cost = %s
                      var adj = %s
                      var noun = %s
                      var states = [%s]
                      var semantics = [[%s]]
                      var words = [%s]
                      var utterances = [[%s]]", alpha, adjCost, nounCost, adj, noun,
                      environment$states, environment$semantics, environment$words, environment$utterances)
  if (modelType == "inc"){
    if (lang == 0) postamble <- sprintf("incrementalUtteranceSpeaker(\"START small blue pin STOP\", \"R1\", %s)", lang)
    else if (lang == 1) postamble <- sprintf("incrementalUtteranceSpeaker(\"START pin blue small STOP\", \"R1\", %s)", lang)
    else if (lang == 2) postamble <- sprintf("incrementalUtteranceSpeaker(\"START small pin blue STOP\", \"R1\", %s)", lang)
    else if (lang == 3) postamble <- 
              sprintf("VietWrapper(\"START pin blue and small STOP\", \"R1\", %s)", lang)
  }
  else if (modelType == "global"){
    if (lang == 0) postamble <- sprintf("globalUtteranceSpeakerWrapper(\"START small blue pin STOP\", \"R1\", %s)", lang)
    else if (lang == 1) postamble <- sprintf("globalUtteranceSpeakerWrapper(\"START pin blue small STOP\", \"R1\", %s)", lang)
    else if (lang == 2) postamble <- sprintf("globalUtteranceSpeakerWrapper(\"START small pin blue STOP\", \"R1\", %s)", lang)
    else if (lang == 3) postamble <- 
        sprintf("globalUtteranceSpeakerWrapper(\"START pin blue and small STOP\", \"R1\", %s) + 
                      globalUtteranceSpeakerWrapper(\"START pin small and blue STOP\", \"R1\", %s)", lang, lang)
  }
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
