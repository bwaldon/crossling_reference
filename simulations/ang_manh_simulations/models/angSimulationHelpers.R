# createEnv: a function that takes in the objects and creates an array with utterances
#words, states, and semantics.
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
# runModel: a function for running speaker/listener models with fixed parameter values. 
# backend: either 'V8' or 'rwebppl'. The former is typically faster for running numerous sequential calls to WebPPL.
# engine: a string, webppl code that runs the two types of models
# environment: created context parameters: utterances, states, words, semantics
#adjCost,nounCost,alpha,modelType,lang, adj, noun: parameters for this run of the model
#Note: small blue pin is always the target
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
  else if (modelType == "global"){ #global is the same for all languages, so if statements aren't necessary
    if (lang == 0) postamble <- sprintf("globalUtteranceSpeakerWrapper(\"START small blue pin STOP\", \"R1\", %s)", lang)
    else if (lang == 1) postamble <- sprintf("globalUtteranceSpeakerWrapper(\"START pin blue small STOP\", \"R1\", %s)", lang)
    else if (lang == 2) postamble <- sprintf("globalUtteranceSpeakerWrapper(\"START small pin blue STOP\", \"R1\", %s)", lang)
    else if (lang == 3) postamble <- 
        sprintf("globalUtteranceSpeakerWrapper(\"START pin blue and small STOP\", \"R1\", %s) + 
                      globalUtteranceSpeakerWrapper(\"START pin small and blue STOP\", \"R1\", %s)", lang, lang)
  }
  else if (modelType == "inc_greedy"){ 
    if (lang == 0) postamble <- sprintf("incrementalUtteranceSpeakerGreedy(\"START small blue pin STOP\", \"R1\", %s)", lang)
    else if (lang == 1) postamble <- sprintf("incrementalUtteranceSpeakerGreedy(\"START pin blue small STOP\", \"R1\", %s)", lang)
    else if (lang == 2) postamble <- sprintf("incrementalUtteranceSpeakerGreedy(\"START small pin blue STOP\", \"R1\", %s)", lang)
    else if (lang == 3) postamble <- 
        sprintf("incrementalUtteranceSpeakerGreedy(\"START pin blue and small STOP\", \"R1\", %s) + 
                      incrementalUtteranceSpeakerGreedy(\"START pin small and blue STOP\", \"R1\", %s)", lang, lang)
  }
  else if (modelType == "inc_cost"){
    if (lang == 0) postamble <- sprintf("incrementalUtteranceSpeakerCost(\"START small blue pin STOP\", \"R1\", %s)", lang)
    else if (lang == 1) postamble <- sprintf("incrementalUtteranceSpeakerCost(\"START pin blue small STOP\", \"R1\", %s)", lang)
    else if (lang == 2) postamble <- sprintf("incrementalUtteranceSpeakerCost(\"START small pin blue STOP\", \"R1\", %s)", lang)
    else if (lang == 3) postamble <- 
        sprintf("incrementalUtteranceSpeakerCost(\"START pin blue and small STOP\", \"R1\", %s) + 
                      incrementalUtteranceSpeakerCost(\"START pin small and blue STOP\", \"R1\", %s)", lang, lang)
  }
  code <- paste(preamble, engine, postamble, sep = '\n')
  write_file(code, 'temp3.js')
  return (evalWebPPL_V8(code))
}

test_model <- function(backend, engine, environment,adjCost, nounCost, alpha, modelType,lang, adj, noun){
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
  postamble <- sprintf("globalLiteralListener(\"START small blue pin\")")
  code <- paste(preamble, engine, postamble, sep = '\n')
  write_file(code, 'temp4.js')
  return(evalWebPPL_V8(code))
}
