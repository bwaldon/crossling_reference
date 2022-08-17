
import Empirica from "meteor/empirica:core";

import { scenes } from '../VIETNAMESE/VietnameseSceneTemplate.js';
import { zeroAll, oneAll } from '../VIETNAMESE/VIETNAMESEItems.js';//
import {nounToScheme} from '../VIETNAMESE/nounToScheme.js';

const colorPool = [["green", "orange", "purple", "black"],["red", "yellow",  "blue", "white"]]
//scheme 1: green, orange, purple, black
//scheme 2: blue, red, white, yellow

//picks a random noun from an array
function pickNoun(pool) {
    noun = pool[Math.floor(Math.random() * pool.length)];
    //TODO remove noun from list
  return noun
}
function pickNounScheme(pool, scheme){
  poolSchemeMatch = pool.filter(x => nounToScheme[x] == scheme)
  console.log(poolSchemeMatch)
  return(pickNoun(poolSchemeMatch))
}
//selects a random color and another different color
function pickColor(scheme) {
  return colorPool[scheme][Math.floor(Math.random() * colorPool[scheme].length)];
}
function pickColorExcept(color, scheme) {
  newPool = colorPool[scheme].filter(x => x != color)
  return newPool[Math.floor(Math.random() * newPool.length)];
}
function getScheme(noun){
  return nounToScheme[noun]
}

//assign colors, sizes and types to the objects in the template
function fillScenes(sceneTemplate) {
  newScenes = []
  onePool = oneAll
  zeroPool = zeroAll
  for (index in sceneTemplate) {
    sceneName = sceneTemplate[index]["Name"]
    // pick values
    type_1 = sceneName.includes("_zero")? pickNoun(zeroPool) : pickNoun(onePool)
    zeroPool = zeroPool.filter(x => x != type_1)//no replacement
    onePool = onePool.filter(x => x != type_1)
    scheme1 = getScheme(type_1)
    type_2 = sceneName.includes("_zero")? pickNounScheme(zeroPool,scheme1) : pickNounScheme(onePool,scheme1)
    zeroPool = zeroPool.filter(x => x != type_2)//no replacement
    onePool = onePool.filter(x =>  x != type_2)
    // pick color: nouns come in 4 of 8 colors according to the specific color scheme to which they belong
    color_1 = pickColor(scheme1)
    color_2 = pickColorExcept(color_1, scheme1)
    //Exactly half of the trials have small targets and half have big targets
    size_1 = index%2 == 0? "small" : "big"
    size_2 = index%2 == 1? "small" : "big"
    // assign the values
    sceneString = JSON.stringify(sceneTemplate[index])
    sceneString = sceneString.replace(/color_1/g, color_1)
    sceneString = sceneString.replace(/color_2/g, color_2)
    sceneString = sceneString.replace(/size_1/g, size_1)
    sceneString = sceneString.replace(/size_2/g, size_2)
    sceneString = sceneString.replace(/type_1/g, type_1)
    sceneString = sceneString.replace(/type_2/g, type_2)
    //revert to Json and push new scene
    sceneToAdd = JSON.parse(sceneString)
    newScenes.push(sceneToAdd)
  }
  //newScenes = _.shuffle(newScenes) --> does not work without importing the _ library in other files
  return(newScenes)
}
// creating scenes as a list of object paths to image files
function makePaths(objectList){
  newScenes = []
  for (index in objectList){
    scene = objectList[index]
    Objnew = {"condition" : scene["Name"], "imageType" : "NA"}
    numAlt = 1
    for (let i = 1 ; i < 7 ; i ++){
      nameOrig = "Obj" + i
      path = scene[nameOrig+"_color"]+"_"+scene[nameOrig+"_type"]
      if (nameOrig == scene["Target"]) {
        nameNew = "TargetItem"
      } else {
        nameNew = "alt"+numAlt
        numAlt += 1
      }
      if (nameNew != "TargetItem") {
        Objnew[nameNew+"Name"] = path != "_"? path : "IGNORE"
      } else{
        Objnew[nameNew] = path != "_"? path : "IGNORE"
      }
      Objnew[nameNew+"Size"] = scene[nameOrig+"_size"]
    }
    newScenes.push(Objnew)
  }
  return(newScenes)
}

exports.generateScenes = function generateScenes() {
  newScenes = fillScenes(scenes)
  scenePaths = makePaths(newScenes)
  return(scenePaths)
}
