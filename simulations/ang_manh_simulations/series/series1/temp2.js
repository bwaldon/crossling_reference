var referents = ['small blue pin', 'big blue ball', 'small red pin', 'big red pin', 'big red ball', 'big red ball']
    var size_semvalue = 0.8
    var color_semvalue = 0.95
    var noun_semvalue = 0.99
    var noun = ['ball','pin']
    var adj = ['small','big','red','blue']
    var sizeAdj = ['small', 'big']
var ENGLISH = 0
var SPANISH = 1
var FRENCH = 2
var VIETNAMESE = 3

var EngUtterances = function(refSize, refCol, refNoun){
  var utterances = []
  utterances.push("START " + refNoun + " STOP")
  utterances.push("START " +refSize + " " + refNoun+ " STOP")
  utterances.push("START " +refCol + " " + refNoun+ " STOP")
  utterances.push("START " +refSize + " " + refCol + " " + refNoun+ " STOP")
  return utterances
}
var SpanUtterances = function(refSize, refCol, refNoun){
  var utterances = []
  utterances.push("START " + refNoun + " STOP")
  utterances.push("START " +refNoun + " " + refSize+ " STOP")
  utterances.push("START " +refNoun + " " + refCol+ " STOP")
  utterances.push("START " +refNoun + " " + refCol + " " + refSize+ " STOP")
  //utterances.push("START " +refCol +  " STOP")
  //utterances.push("START " +refSize+ " STOP")
  //utterances.push("START "+ refCol + " " + refSize+ " STOP")
  return utterances
}
var FrenUtterances = function(refSize, refCol, refNoun){
  var utterances = []
  utterances.push("START " + refNoun + " STOP")
  utterances.push("START " +refSize + " " + refNoun+ " STOP")
  utterances.push("START " +refNoun + " " + refCol+ " STOP")
  utterances.push("START " +refSize + " " + refNoun + " " + refCol+ " STOP")
  //utterances.push("START " +refCol +  " STOP")
//  utterances.push("START " +refSize+ " STOP")
  return utterances
}
var VietUtterances = function(refSize, refCol, refNoun) {
  var utterances = []
  utterances.push("START " + refNoun + " STOP")
  utterances.push("START " +refNoun + " " + refSize+ " STOP")
  utterances.push("START " +refNoun + " " + refCol+ " STOP")
  utterances.push("START " +refNoun + " " + refCol + " and " + refSize+ " STOP")
  utterances.push("START " +refNoun + " " +refSize+ " and "+refCol+" STOP")
  return utterances
}
var createEnv = function (referents, size_semvalue, color_semvalue, noun_semvalue){
 var indices = _.range(referents.length);
 var states = []
 var utterances = []
 var utterancesDeep = [[],[],[],[]]
 var words = []
 var wordsDeep = []
 map(function (i) {//loops through referents
   var ref = referents[i];
   var refWords = ref.split(" ");
   wordsDeep.push(refWords);
   states.push("R"+(i+1));//one state per referent
   var refSize = refWords[0]//input must be in English order + contain color and size
   var refCol = refWords[1]
   var refNoun = refWords[2]
   //appends utterances that relate to each referent
   utterancesDeep[ENGLISH].push(EngUtterances(refSize, refCol,refNoun))
   utterancesDeep[SPANISH].push(SpanUtterances(refSize,refCol,refNoun))
   utterancesDeep[FRENCH].push(FrenUtterances(refSize,refCol,refNoun))
   utterancesDeep[VIETNAMESE].push(VietUtterances(refSize,refCol,refNoun))
 }, indices);
 //flattens and trims arrays for each language
 utterances.push(_.uniq(_.flatten(utterancesDeep[ENGLISH])))
 utterances.push("_")
 utterances.push(_.uniq(_.flatten(utterancesDeep[SPANISH])))
 utterances.push("_")
 utterances.push(_.uniq(_.flatten(utterancesDeep[FRENCH])))
 utterances.push("_")
 utterances.push(_.uniq(_.flatten(utterancesDeep[VIETNAMESE])))
 var words = _.uniq(_.flatten(wordsDeep))
 var wordIndices = _.range(words.length)
 var semantics = []
 //[[small: 0, big: 1,]]
 map(function(k){// for every referent
   var targetRef = referents[k]
   semantics.push([])
     map(function(m){//loop through every possible word
       var targetMod = words[m];
       if (adj.includes(targetMod)){// assumes every adj is either a color or size adjective
         if (sizeAdj.includes(targetMod)){
           semantics[k].push(targetRef.includes(targetMod)? size_semvalue : 1-size_semvalue)
         } else {
           semantics[k].push(targetRef.includes(targetMod)? color_semvalue : 1-color_semvalue)
         }
       } else if (noun.includes(targetMod)){
       semantics[k].push(targetRef.includes(targetMod)? noun_semvalue : 1-noun_semvalue)//noun semantic value
     }
     }, wordIndices)
     semantics[k].push(1)// for and
     semantics[k].push(1)//for stop and start
     semantics[k].push(1)
     if (k < indices.length -1 ) semantics[k].push("_")
     }, indices)
  words.push("and")
  words.push("STOP")
  words.push("START")
 return [states,":", semantics, ":", words, ":",utterances];
}
createEnv(referents, size_semvalue, color_semvalue, noun_semvalue)
