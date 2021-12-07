var semantics = function(params) { return function(state) { return { big_masc: ['big_plate_masc'].includes(state) ? params.sizeNoiseVal : falseSemantics(params.sizeNoiseVal, params.genderNoiseVal, ['big_plate_masc'], state),plate_masc: ['big_plate_masc','small_plate_masc'].includes(state) ? params.nounNoiseVal : falseSemantics(params.nounNoiseVal, params.genderNoiseVal, ['big_plate_masc','small_plate_masc'], state),small_masc: ['small_plate_masc'].includes(state) ? params.sizeNoiseVal : falseSemantics(params.sizeNoiseVal, params.genderNoiseVal, ['small_plate_masc'], state),big_fem: ['big_cup_fem'].includes(state) ? params.sizeNoiseVal : falseSemantics(params.sizeNoiseVal, params.genderNoiseVal, ['big_cup_fem'], state),cup_fem: ['big_cup_fem','small_cup_fem'].includes(state) ? params.nounNoiseVal : falseSemantics(params.nounNoiseVal, params.genderNoiseVal, ['big_cup_fem','small_cup_fem'], state),small_fem: ['small_cup_fem'].includes(state) ? params.sizeNoiseVal : falseSemantics(params.sizeNoiseVal, params.genderNoiseVal, ['small_cup_fem'], state),STOP : 1, START : 1 } } }
var recursivelySplitGenderAndWord = function(dictDefinition) {
  // split up first item into individual words
  var individualWords = dictDefinition[0].split("_");
  // get rid of gender
  individualWords.pop();
  // rejoin the items with an underscore and add to an array
  var entryWithoutGender = [individualWords.join("_")];
  // base case of recursion
  if (dictDefinition.length == 1) {
    // return first item
    return entryWithoutGender;
  } else {
    // get rid of the first element of the recurssion array
    dictDefinition.shift();
    var arrayElement2 = recursivelySplitGenderAndWord(dictDefinition);
    // return first item and then call the function recursively on the rest, adding
    // it to the array
    return entryWithoutGender.concat(arrayElement2);
  }
}

var returnGenderAndDictionary = function(dictDefinition) {
  var firstWord = dictDefinition[0].split("_");
  var recursiveArrayofDict = recursivelySplitGenderAndWord(dictDefinition);
  return [firstWord[firstWord.length - 1], recursiveArrayofDict];
}

var falseSemantics = function(adjNoise, genderNoise, dictDefinition, state) {
  //split all the gender endings from the dictDefinition
  var recursiveSplit = returnGenderAndDictionary(dictDefinition);
  var dictionaryGender = recursiveSplit[0];
  var dictionaryEntries = recursiveSplit[1];
  // split up gender and state
  var stateArray = state.split("_");
  var wordGender = stateArray.pop();
  var word = stateArray.join("_");

  // if the word (adj) is true
  if (dictionaryEntries.indexOf(word) > -1) {
    // then gender must be false
    return adjNoise*(1-genderNoise);
  } else {
    //else the word is false
    // in which case if gender is true
    if (wordGender == dictionaryGender) {
      return (1-adjNoise)*genderNoise;
    } else {
      // else gender is false
      return (1-adjNoise)*(1-genderNoise);
    }
  }
}
var model = function(params) {  return { words : ['big_masc','plate_masc','small_masc','big_fem','cup_fem','small_fem','STOP', 'START'], wordCost: {'big_masc' : params.sizeCost,'small_masc' : params.sizeCost,'big_fem' : params.sizeCost,'small_fem' : params.sizeCost,'plate_masc' : params.nounCost,'cup_fem' : params.nounCost,'STOP'  : 0, 'START'  : 0 },}}
var params = {
    alpha : 19.000000,
    sizeNoiseVal : 0.800000,
    colorNoiseVal : 0.950000,
    genderNoiseVal : 1.000000,
    nounNoiseVal : 0.900000,
    sizeCost : 0.100000,
    colorCost : 0.100000,
    nounCost : 0.100000
  }
  
var semantics = semantics(params)
    
var model = extend(model(params), 
 {states : ['big_plate_masc', 'small_plate_masc', 'big_cup_fem', 'small_cup_fem'], utterances : ['START big_masc STOP', 'START plate_masc STOP', 'START big_masc plate_masc STOP', 'START small_masc STOP', 'START small_masc plate_masc STOP', 'START big_fem STOP', 'START cup_fem STOP', 'START big_fem cup_fem STOP', 'START small_fem STOP', 'START small_fem cup_fem STOP']}) 
                 
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
      factor(meaning)
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
incrementalUtteranceSpeaker('START small_fem cup_fem STOP', 'small_cup_fem', model, params, semantics)