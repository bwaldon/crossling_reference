var semantics = function(params) {
  return function(state) {
    return {
      color: ["color_size","color_otherSize"].includes(state) ? params.colorNoiseVal : 1 - params.colorNoiseVal, 
      otherColor: ["otherColor_size","otherColor_otherSize"].includes(state) ? params.colorNoiseVal : 1 - params.colorNoiseVal,
      size: ["color_size","otherColor_size"].includes(state) ? params.sizeNoiseVal : 1 - params.sizeNoiseVal,
      otherSize: ["color_otherSize","otherColor_otherSize"].includes(state) ? params.sizeNoiseVal : 1 - params.sizeNoiseVal,
      STOP : 1,
      START : 1
    }
  }
}


var model = function(params) {
  return {
    words : ['color', 'size', 'otherColor', 'otherSize', 'STOP', 'START'],
    wordCost: {
      "color" : params.colorCost,
      "otherColor" : params.colorCost,
      "size" : params.sizeCost,
      "otherSize" : params.sizeCost,
      "pin" : params.nounCost,
      'STOP'  : 0,
      'START'  : 0
    },

  }
}
// safeDivide, getTransitions, licitTransitions: helper functions for incremental models 

var safeDivide = function(x , y){
  if(y == 0) {
  return(0)
  } else {
  return(x / y)
  }
}

var getTransitions = function(str) {
  var result = []
  var splitStr = str.split(" ")
  var indices = _.range(splitStr.length)
  map(function(i) {
    var transition = (splitStr.slice(0,i + 1)).join(" ")
    result.push(transition)
    },indices)
  return result
}

var licitTransitions = function(model) {
  return _.uniq(_.flatten(map(function(x) { 
  return getTransitions(x) }, model.utterances)))
}


var wordPrior = function(model) {
  return uniformDraw(model.words)
}

var stringCost = function(string,model) {
  var wordcosts = map(function(x) {return model.wordCost[x]}, string)
  return sum(wordcosts)
}

var stringMeanings = function (context, state, model, semantics) {
  var cSplit = context.split(" ")
     var meaning = semantics(state)
    return reduce(function(x, acc) { return meaning[x] * acc; }, 1, cSplit) }

// stringSemantics: defined according to Cohn-Gordon et al. (2019), in prose on the bottom of page 83
// outputs values on the interval [0,1]: a string s's semantic value at a world w 
// is the sum of semantic values of complete continuations of s true at w, 
// divided by the total number of complete continuations of s:
var stringSemantics = function(context, state, model, semantics) {
  var allContinuations = filter(function(x) {
    return x.startsWith(context)
  } , model.utterances)
  var trueContinuations = reduce(function(x, acc) { return stringMeanings(x, state, model, semantics) + acc; }, 
                                 0, allContinuations)
  return safeDivide(trueContinuations,allContinuations.length)
}

// the normal, utterance-level RSA literal listener
var globalLiteralListener =  function(utterance, model, params, semantics) {
  return Infer(function() {
    var state = uniformDraw(model.states)
    var meaning = stringMeanings(utterance,state,model,semantics)
    if(params.sizeNoiseVal == 1 & params.colorNoiseVal == 1) {
      condition(meaning)
    } else {
      factor(Math.log(meaning))
    } 
    return state
  }
              )}

// the normal, utterance-level RSA pragmatic speaker
var globalUtteranceSpeaker = cache(function(state, model, params, semantics) {
  return Infer({model: function() {
  var utterance = uniformDraw(model.utterances)
  var listener = globalLiteralListener(utterance, model, params, semantics)
  factor(params.alpha * (listener.score(state) - stringCost(utterance.split(" "),model)))
    return utterance } })
})

// L0^{WORD} from Cohn Gordon et al. (2019): defined according to equation (4) of that paper
var incrementalLiteralListener = function(string,model,semantics) {
  return Infer({model: function(){
    var state = uniformDraw(model.states)
    var meaning = Math.log(stringSemantics(string, state, model, semantics))
    factor(meaning)
    return state
  }}
)}

// S1^{WORD} from Cohn Gordon et al. (2019): defined according to equation (5) of that paper
var wordSpeaker = function(context, state, model, params, semantics) {
  return Infer({model: function(){
    var word = wordPrior(model)
    var newContext = context.concat([word])
    // grammar constraint: linear order must be allowed in language
    condition(licitTransitions(model).includes(newContext.join(" "))) 
    // note: condition basically goes away
    var result = (stringMeanings(context.join(" "),state,model,semantics) == 0) ? 1 : params.alpha * (incrementalLiteralListener(newContext.join(" "),model,semantics).score(state) - stringCost(newContext,model))
    factor(result)
    return word
  }})
}

// L1^{WORD} from Cohn Gordon et al. (2019): defined according to equation (6) of that paper
var pragmaticWordListener = function(word, context, model, params, semantics) {
  return Infer({model: function(){
    var state = uniformDraw(model.states)
    factor(wordSpeaker(state, context, model, params, semantics).score(word))
    return state
  }})
}

// S1^{UTT-IP} from Cohn Gordon et al. (2019): defined according to equation (7) of that paper
var incrementalUtteranceSpeaker = cache(function(utt, state, model, params, semantics) {
  var string = utt.split(" ")
    var indices = _.range(string.length)
    var probs = map(function(i) {
        var context = string.slice(0,i) 
        //print(context)       
        return Math.exp(wordSpeaker(context,state,model,params,semantics).score(string[i]))  
    },indices)
    return reduce(function(x, acc) { return x * acc; }, 1, probs)
}, 100000)
var estimates = [{"alpha":12.8137409123332,"colorNoiseVal":0.997896498316058,"sizeNoiseVal":0.997896498316058,"sizeCost":0.272668958679408,"nounCost":0,"colorCost":0.00294787787693059}][0]
// console.log(estimates)
// console.log(JSON.parse(estimates))
// console.log(Object.keys(estimates))

var predictives = map(function(d) {

  var m = extend(model(estimates), {states : d.states, utterances : d.utterances}); 
  return {condition: d.condition, 
  size_color: Math.exp(globalUtteranceSpeaker("color_size",m,estimates,semantics(estimates)).score("START color size STOP")),
  color: Math.exp(globalUtteranceSpeaker("color_size",m,estimates,semantics(estimates)).score("START color STOP")),
  size: Math.exp(globalUtteranceSpeaker("color_size",m,estimates,semantics(estimates)).score("START size STOP"))}; 
  
}, df)

predictives

