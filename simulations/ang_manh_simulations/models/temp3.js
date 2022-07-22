var states = ["R1", "R2", "R3"]
                      var semantics = [["0.8", "0.95", "0.99", "0.19999999999999996", "0.050000000000000044", "1", "1", "1"],["0.19999999999999996", "0.95", "0.99", "0.8", "0.050000000000000044", "1", "1", "1"],["0.19999999999999996", "0.050000000000000044", "0.99", "0.8", "0.95", "1", "1", "1"]]
                      var words = ["small", "blue", "pin", "big", "red", "and", "STOP", "START"]
                      var utterances = [["START pin STOP", "START small pin STOP", "START blue pin STOP", "START small blue pin STOP", "START big pin STOP", "START big blue pin STOP", "START red pin STOP", "START big red pin STOP"],["START pin STOP", "START pin small STOP", "START pin blue STOP", "START pin blue small STOP", "START blue STOP", "START small STOP", "START blue small STOP", "START pin big STOP", "START pin blue big STOP", "START big STOP", "START blue big STOP", "START pin red STOP", "START pin red big STOP", "START red STOP", 
"START red big STOP"],["START pin STOP", "START small pin STOP", "START pin blue STOP", "START small pin blue STOP", "START big pin STOP", "START big pin blue STOP", "START pin red STOP", "START big pin red STOP"],["START pin STOP", "START pin small STOP", "START pin blue STOP", "START pin blue and small STOP", "START pin small and blue STOP", "START pin big STOP", "START pin blue and big STOP", "START pin big and blue STOP", "START pin red STOP", "START pin red and big STOP", "START pin big and red STOP"
]]
//Continuous incremental+global model----->
var ENGLISH = 0
var SPANISH = 1
var FRENCH = 2
var VIETNAMESE = 3
var alpha_inc = 7
var alpha_global = 20

var wordCost = function(x){
  //if (adj.includes(x)) return cost
  if (x === "and") return cost
  return 0
}

var safeDivide = function (x, y) {
 if (y == 0) {
   return 0;
 } else {
   return x / y;
 }
};

//takes in a string and returns all substrings?
var getTransitions = function (str) {
 var result = [];
 var splitStr = str.split(" ");
 var indices = _.range(splitStr.length);
 map(function (i) {
   var transition = splitStr.slice(0, i + 1).join(" ");
   result.push(transition);
 }, indices);
 return result;
};

//following function gives licit transitions in English, French and Spanish respectively
var licitTransitions = function(lang) { return _.uniq(
 _.flatten(
   map(function (x) {
     return getTransitions(x);
   }, utterances[lang])
 )
);
}
//Randomly selects a word from the set
var wordPrior = function () {
 return uniformDraw(words);
};

//Returns the cost of an entire utterance
var stringCost = function (string) {
 var wordcosts = map(function (x) {
   return wordCost(x);
 }, string);
 return sum(wordcosts);
};

//returns semantic value of the utterance given the target state
var stringMeanings = function (context, state) {
 var cSplit = context.split(" ");
 var stateNum = state.slice(1) -1
 var meaning = semantics[stateNum];
 // arr: [red?, blue?...]
 // 1s will multiply with 1s etc
 return reduce(
   function (x, acc) {
     return meaning[_.indexOf(words,x)] * acc;
   },
   1,
   cSplit
 );
};

// stringSemantics: defined according to Cohn-Gordon et al. (2019), in prose on the bottom of page 83
// outputs values on the interval [0,1]: a string s's semantic value at a world w
// is the sum of semantic values of complete continuations of s true at w,
// divided by the total number of complete continuations of s:
var stringSemantics = function (context, state, lang) {//takes in context + target state
 var allContinuations = filter(function (x) {
   return x.startsWith(context);
 }, utterances[lang]);//gives set of utterances that start with context
 var trueContinuations = reduce(
   function (x, acc) {//adds up all the true continuations
     return stringMeanings(x, state) + acc;
   },//filters to 1 or 0
   0,
   allContinuations// loops through possible continuations
 );
 return safeDivide(trueContinuations, allContinuations.length);
};

//________________________________________________________________________________
//                                   Regular part:-- defaults to English
// the normal, utterance-level RSA literal listener
var globalLiteralListener = function (utterance) {
 return Infer(function () {
   var state = uniformDraw(states);
   var meaning = stringMeanings(utterance, state);
   factor(meaning);
   return state;
 });
};

// the normal, utterance-level RSA pragmatic speaker
var globalUtteranceSpeaker = cache(function (state, lang) {
 if (lang == FRENCH){
   return Infer({
   model: function () {
     var utterance = categorical(frenDistProb_3, frenDistUtt);//
     var listener = globalLiteralListener(utterance);
     factor(
       alpha_global * (listener.score(state) - stringCost(utterance.split(" ")))
     );
     return utterance;
   },
 });
 }
 return Infer({
   model: function () {
     var utterance = uniformDraw(utterances[lang]);//
     var listener = globalLiteralListener(utterance);
     factor(
       alpha_global * (listener.score(state) - stringCost(utterance.split(" ")))
     );
     return utterance;
   },
 });
});

//________________________________________________________________________________
//                                   Incremental part:

// L0^{WORD} from Cohn Gordon et al. (2019): defined according to equation (4) of that paper

//returns probability distribution over states given a context
var incrementalLiteralListener = function (string, lang) {
 return Infer({
   model: function () {
     var state = uniformDraw(states);//picks random state
     //bc this takes in full utterances? it will just give 0 or 1 bc no continuations?
     var meaning = Math.log(stringSemantics(string, state, lang));
     factor(meaning);
     return state;
   },
 });
};

// S1^{WORD} from Cohn Gordon et al. (2019): defined according to equation (5) of that paper

//returns the probability of a word given a context and the target state
var wordSpeaker = function (context, state, lang) {
 return Infer({
   model: function () {
     var word = wordPrior();// selects a random word
     var newContext = context.concat([word]);//adds to context
     // grammar constraint: linear order must be allowed in language
     condition(licitTransitions(lang).includes(newContext.join(" ")));
     // note: condition basically goes away
     var result =
       stringMeanings(context.join(" "), state) == 0 //context is completely false for referent
         ? 1 //to avoid negatives?
         : alpha_inc *
           (incrementalLiteralListener(newContext.join(" "), lang).score(
             state
           ) -
             stringCost(newContext));
     factor(result);
     return word;
   },
 });
};

// L1^{WORD} from Cohn Gordon et al. (2019): defined according to equation (6) of that paper

//returns probability distribution over states given context and a new word
var pragmaticWordListener = function (word, context, lang) {
 return Infer({
   model: function () {
     var state = uniformDraw(states);
     factor(wordSpeaker(context, state, lang).score(word));
     return state;
   },
 });
};

// S1^{UTT-IP} from Cohn Gordon et al. (2019): defined according to equation (7) of that paper

//returns probability of an utterance given the target state
var incrementalUtteranceSpeaker = cache(function (utt, state, lang) {
 var string = utt.split(" ");
 var indices = _.range(string.length);
 var probs = map(function (i) {
   var context = string.slice(0, i);
   return Math.exp(wordSpeaker(context, state, lang).score(string[i]));
 }, indices);//probs= array of probabilities for EVERY? substring
 return reduce(
   function (x, acc) {
     return x * acc;
   },
   1,
   probs //multiplies up the probabilities
 ).toFixed(3);
}, 100000);

incrementalUtteranceSpeaker("START small blue pin STOP", "R1", 0)