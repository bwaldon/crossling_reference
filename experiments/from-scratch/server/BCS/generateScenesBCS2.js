/*

Explain this document, its output, and how it interacts with the rest of the app.

Explain:
- rotations
- where to find all the relevant info in the repo about the trials and conditions etc.


comment all the relevant files

meteor npm install --save @babel/runtime react react-dom @blueprintjs/core moment react-html-parser @blueprintjs/icons prop-types


meteor npm install --save @babel/runtime

meteor npm install --save glob


meteor npm install --save react react-dom @blueprintjs/core moment react-html-parser @blueprintjs/icons prop-types


Questions for Brandon:
- condition in each trial --> what is it for and what should I put there?
- how do we want to decide the rotations

// Naming guide:
// BCSStimulus_[colorSchemeID]_[genderID]_[itemID]
// colorSchemeID: {1 : color Scheme 1, 2: Color Scheme 2}
// genderID: {1 : Masculine, 2 : Feminine}
// itemID: {1:12}


What you need to uniquely identify an object


*/

import Empirica from "meteor/empirica:core";

import { colorSizeIDsToName } from '../degenEtal2020/itemIDsToName.js';
import { subToBasicAndSup } from '../degenEtal2020/supSupTrialsItems.js';
import { supToBasicsToSubs } from '../degenEtal2020/supSupTrialsItems.js';
import { subSupTrialsTargets } from '../degenEtal2020/supSupTrialsItems.js';

import { allDef } from './BCSitemIDsToName.js';
import { allRotations } from './BCSrotations2.js';
import { cs1Dict } from './BCScolorSchemes.js';
import { cs2Dict } from './BCScolorSchemes.js';

exports.generateScenes = function generateScenes() {
      // array to hold all the scenes we create
      let scenes = [];

      // pick rotation randomly
      // check where this was in the last script, if it was inside the for loop
      // then you didn't have rotations at all and you might have had repeats of stimuli!!!
      rot = allRotations[Math.floor(Math.random()*allRotations.length)];

      // iterate through scenarios in both color schemes
      for (let determineColorScheme = 1; determineColorScheme < 3; determineColorScheme++) {

        // iterate through the target object genders
        // 1 = masculine, 2 = feminine
        for (let g = 1; g < 3; g++) {
          oppositeGender = 0;
          if(g == 1) {
            oppositeGender = 2;
          } else {
            oppositeGender = 1;
          }


          /*
          scenes.push takes the following form:
          scenes.push(
            sceneColorNecessary(
              rot[0], = the targetID as defined in the rotations js file
              determineColorScheme, =  the target color scheme
              g, // the target gender
              "scene1" //scene type
          ));
          */

          // create all three trails of scene 1
          // (color necessary gender match)
          scenes.push(sceneColorNecessary(rot[0], determineColorScheme, g, "scene1"));
          scenes.push(sceneColorNecessary(rot[1], determineColorScheme, g, "scene1"));
          scenes.push(sceneColorNecessary(rot[2], determineColorScheme, g, "scene1"));

          // create all three trials of scene2
          //(color necessary gender mismatch)
          scenes.push(sceneColorNecessary(rot[3], determineColorScheme, g, "scene2"));
          scenes.push(sceneColorNecessary(rot[4], determineColorScheme, g, "scene2"));
          scenes.push(sceneColorNecessary(rot[5], determineColorScheme, g, "scene2"));

          // create all three trials of scene3
          // (color redundant gender match)
          scenes.push(sceneColorRedundant(rot[6], determineColorScheme, g, "scene3"));
          scenes.push(sceneColorRedundant(rot[7], determineColorScheme, g, "scene3"));
          scenes.push(sceneColorRedundant(rot[8], determineColorScheme, g, "scene3"));

          // create all three trials of scene4
          // (color redundant gender mismatch)
          scenes.push(sceneColorRedundant(rot[9], determineColorScheme, g, "scene4"));
          scenes.push(sceneColorRedundant(rot[10], determineColorScheme, g, "scene4"));
          scenes.push(sceneColorRedundant(rot[11], determineColorScheme, g, "scene4"));
        }
      }


      // CREATE DISTRACTOR SCENES

      // shuffle subSupTrialsTargets
      subSupTrialsTargets = _.shuffle(subSupTrialsTargets);

      // only pick first 24 items
      for (let i = 0; i < 24; i++)
      {
          let targetSub = subSupTrialsTargets[i];
          let basicAndSup = subToBasicAndSup[targetSub];
          let targetBasic = basicAndSup[0];
          let targetSup = basicAndSup[1];

          // let contextMode = _.sample(['subNec', 'basicSuff', 'supSuff']);             // OLD
          let contextMode = _.sample(['subNec', 'basicSuff', 'basicSuff', 'supSuff']);   // NEW

          let distractor1;
          let distractor2;

          if (contextMode == 'subNec')
          {
              // one distractor of the same basic category and one distractor of the same superordinate category (e.g., target: dalmatian, distractors: greyhound [also a dog] and squirrel [also an animal])
              distractor1 = sampleElementExceptOne(targetSub,
                                                  supToBasicsToSubs[targetSup][targetBasic],
                                                  false);

              let otherBasic = _.sample(Array.from(Object.keys(supToBasicsToSubs[targetSup])));
              distractor2 = sampleElementExceptOne(targetSub,
                                                  supToBasicsToSubs[targetSup][otherBasic],
                                                  false);

              /*
              // alternative implementation, ensures distractor #2 has different basic category
              let otherBasic = sampleElementExceptOne(targetBasic,
                                                      Array.from(Object.keys(supToBasicsToSubs[targetSup])),
                                                      false);
              distractor2 = _.sample(supToBasicsToSubs[targetSup][otherBasic]);
              */
          }
          else if (contextMode == 'basicSuff')
          {
              let basicSuffType = _.sample(['Type1', 'Type2']);
              if (basicSuffType == 'Type1')
              {
                  // two distractors of the same superordinate category but different basic category as the target (e.g., target: husky, distractors: hamster and elephant)
                  let twoOtherBasics = sampleElementExceptOne(targetBasic,
                                                              Array.from(Object.keys(supToBasicsToSubs[targetSup])),
                                                              true);
                  distractor1 = _.sample(supToBasicsToSubs[targetSup][twoOtherBasics[0]]);
                  distractor2 = _.sample(supToBasicsToSubs[targetSup][twoOtherBasics[1]]);
              }
              else
              {
                  // one distractor of the same superordinate category and one unrelated item
                  let otherBasic = sampleElementExceptOne(targetBasic,
                                                          Array.from(Object.keys(supToBasicsToSubs[targetSup])),
                                                          false);
                  distractor1 = _.sample(supToBasicsToSubs[targetSup][otherBasic]);

                  let otherSup = sampleElementExceptOne(targetSup,
                                                      Array.from(Object.keys(supToBasicsToSubs)),
                                                      false);
                  let someBasic = _.sample(Array.from(Object.keys(supToBasicsToSubs[otherSup])));
                  distractor2 = _.sample(supToBasicsToSubs[otherSup][someBasic]);
              }
              contextMode += basicSuffType;
          }
          else
          {
              // two unrelated items
              let twoOtherSups = sampleElementExceptOne(targetSup,
                                                      Array.from(Object.keys(supToBasicsToSubs)),
                                                      true);
              let someBasic = _.sample(Array.from(Object.keys(supToBasicsToSubs[twoOtherSups[0]])));
              distractor1 = _.sample(supToBasicsToSubs[twoOtherSups[0]][someBasic]);
              let anotherBasic = _.sample(Array.from(Object.keys(supToBasicsToSubs[twoOtherSups[1]])));
              distractor2 = _.sample(supToBasicsToSubs[twoOtherSups[1]][anotherBasic]);
          }
          // console.log(`${targetSub} ${targetBasic} ${targetSup}`);
          // console.log(`${distractor1} ${subToBasicAndSup[distractor1][0]} ${subToBasicAndSup[distractor1][1]}`);
          // console.log(`${distractor2} ${subToBasicAndSup[distractor2][0]} ${subToBasicAndSup[distractor2][1]}`)
          // console.log()

          let alt1BasicSup = subToBasicAndSup[distractor1];
          let alt1Basic = alt1BasicSup[0];
          let alt1Super = alt1BasicSup[1];
          let alt2BasicSup = subToBasicAndSup[distractor2];
          let alt2Basic = alt2BasicSup[0];
          let alt2Super = alt2BasicSup[1];

          scenes.push({
              'TargetItem': targetSub,
              'TargetItemBasicLevel': targetBasic,
              'TargetItemSuperLevel': targetSup,
              'alt1Name': distractor1,
              'alt2Name': distractor2,
              'alt3Name': 'IGNORE',
              'alt4Name': 'IGNORE',
              'alt5Name': 'IGNORE',
              'alt1BasicLevel': alt1Basic,
              'alt1SuperLevel': alt1Super,
              'alt2BasicLevel': alt2Basic,
              'alt2SuperLevel': alt2Super,
              'NumDistractors': 2,
              'condition' : contextMode
          });
      }
      console.log("scenes = ");
      console.log(scenes);
      return(scenes);
    }

/*
sceneMain
Takes in references to objects and outputs a dictionary entry of all the
objects that will be on display for a single scene

Input:
  condition: (string){scene1, scene2, scene3, scene4} logs what time of trial
    this scene was
  targetArray: (array)[targetColor, targetColorScheme, targetGender, targetNounID]
    targetColor: (string){"blue", "yellow", ...}
    targetColorScheme: (int) 1 = CS1, 2 = cs2
    targetGender: (int) 1= masculine, 2 = feminine
    targetNounID: (int) {1, 2, .., 12} reference to noun ID in allDef variable
  distractors: (array of arrays) Each array within this array corresponds to a
    single distractor object and is of type: [color, colorScheme, gender, objectID]].
    They are coded just like the targetArray variables.
  numDistractors: (int) number of distractors. In this case there should always be
    5.

Output:
  Dictionary of type:
  TargetItem: (string) [target color]_[target name] (e.g. "blue_scarf")
  NumDistractors: 5, (number of distractor objects)
  alt1Name: (string) [distractor color]_[distractor name] (e.g. "blue_scarf")
  alt2Name: same as above.
  alt3Name: same as above.
  alt4Name: same as above.
  alt5Name: same as above.
  alt1BasicLevel: 'NA', This corresponds to the filler trial information and is
  alt1SuperLevel: 'NA', ignored for the target trials made by this function
  alt2BasicLevel: 'NA',
  alt2SuperLevel: 'NA',
  condition: condition

Notes:
  This function assumes that there will be 5 distractors in every scene.
  The order of values in each array is assumed to be what is written above.
*/
function sceneMain(condition, targetArray, distractors) {

  console.log("targetArray = ");
  console.log(targetArray[0]);
  console.log(targetArray[1]);
  console.log(targetArray[2]);
  console.log(targetArray[3]);

  // convert target and distractors into actual string
  target = allDef["BCSStimulus_" + targetArray[1] + "_" + targetArray[2] + "_" + targetArray[3]];
  console.log("target = ");
  console.log(target);
  distractorString0 = allDef["BCSStimulus_" + distractors[0][1] + "_" + distractors[0][2] + "_" + distractors[0][3]];
  distractorString1 = allDef["BCSStimulus_" + distractors[1][1] + "_" + distractors[1][2] + "_" + distractors[1][3]];
  distractorString2 = allDef["BCSStimulus_" + distractors[2][1] + "_" + distractors[2][2] + "_" + distractors[2][3]];
  distractorString3 = allDef["BCSStimulus_" + distractors[3][1] + "_" + distractors[3][2] + "_" + distractors[3][3]];
  distractorString4 = allDef["BCSStimulus_" + distractors[4][1] + "_" + distractors[4][2] + "_" + distractors[4][3]];

  return({
    'TargetItem': targetArray[0] + "_" + target,
    'NumDistractors': 5,
    'alt1Name': distractors[0][0] + "_" + distractorString0,
    'alt2Name': distractors[1][0] + "_" + distractorString1,
    'alt3Name': distractors[2][0] + "_" + distractorString2,
    'alt4Name': distractors[3][0] + "_" + distractorString3,
    'alt5Name': distractors[4][0] + "_" + distractorString4,
    'alt1BasicLevel': 'NA',
    'alt1SuperLevel': 'NA',
    'alt2BasicLevel': 'NA',
    'alt2SuperLevel': 'NA',
    'condition': condition
  })
}

/*
  SceneColorNecessary
  Wrapper for color necessary scenes. It creates a target and competitor object,
  and calls on createDistractors() to create the distractor objects. It then feeds
  all of these objects into sceneMain(). This function creates teh competitor object
  suhch that it will be the same type but different color than the target.

  Input:
    targetNounID: (int) {1, 2, .., 12} reference to noun ID in AllDef
    targetCS: (int){1, 2} reference to the target noun's color scheme
    targetGender: (int){1, 2} reference to target's gender
    condition: (string) reference to which scene we are creating the stimuli for

  Output: returns output of sceneMain()
*/
function sceneColorNecessary(targetNounID, targetCS, targetGender, condition) {

  targetColor = pickColor(targetCS);
  // house all the target information together
  targetArray = [targetColor, targetCS, targetGender, targetNounID];

  competitorColor = pickColorExcept(targetCS, targetColor);

  /*

   for gender match condition (scene 1), make the distractors the same gender
   as the target. For gender mismatch condition (scene 2), make the distractors
   the opposite gender of the target.
  */
  if (condition == "scene1") {
    distractorGender = targetGender;
  } else {
    if (targetGender == 1) {
      distractorGender = 2;
    }else {
      distractorGender = 1;
    }
  }

  // Create the distractor objects
  distractorStrings = createDistractors([[targetCS, targetNounID]], [targetColor, competitorColor], distractorGender, [], 4);

  // add comeptitor to distractor array
  distractorStrings.push([competitorColor, targetCS, targetGender, targetNounID]);

  return(sceneMain(condition, targetArray, distractorStrings));
}

/*
  SceneColorRedundant
  Wrapper for color redundant scenes. It creates a target, distractor objects using
  createDistractors(), and an additional distractor object of the same type as
  another distractor object. It then feeds all of these objects into sceneMain().

  Input:
    targetNounID: (int) {1, 2, .., 12} reference to noun ID in AllDef
    targetCS: (int){1, 2} reference to the target noun's color scheme
    targetGender: (int){1, 2} reference to target's gender
    condition: (string) reference to which scene we are creating the stimuli for

  Output: returns output of sceneMain()
*/
function sceneColorRedundant(targetNounID, targetCS, targetGender, condition) {
  targetColor = pickColor(targetCS);
  targetArray = [targetColor, targetCS, targetGender, targetNounID]

  /*
   for gender match condition (scene 3), make the distractors the same gender
   as the target. For gender mismatch condition (scene 4), make the distractors
   the opposite gender of the target.
  */
  if (condition == "scene3") {
    distractorGender = targetGender;
  } else {
    if (targetGender == 1) {
      distractorGender = 2;
    }else {
      distractorGender = 1;
    }
  }

  /*
  create Distractors
  ensure that they do not all have the same CS, because if they do
  all the colors of that color scheme will be used at least once, and we will
  not be able to make a same type distractor object of a different color.
  */
  loopDistractors = true
  while(loopDistractors) {

    // create distractors
    distractorStrings = createDistractors([[targetCS, targetNounID]], [targetColor], distractorGender, [], 4);

    // make sure distractors are not all of the same color scheme
    tfValue = true;
    for (i = 1; i < distractorStrings.length; i++) {
      tfValue = tfValue & (distractorStrings[0][1] == distractorStrings[i][1]);
    }
    if (!tfValue) {
      loopDistractors = false;
    }
  }

  // get all colors already used
  colorsUsed = [];
  for (i = 0; i < distractorStrings.length; i++){
    colorsUsed.push(distractorStrings[i][0]);
  }

  // create a distractor of a same type as another distractor, but in a new color
  loopRepeatDistractor = true;
  while (loopRepeatDistractor) {
    // pick a distractor at random
    repeatDist = distractorStrings[Math.floor(Math.random()*distractorStrings.length)];
    // pick a color at random
    distColor = pickColorExcept(repeatDist[1], repeatDist[0]);
    // make sure that another object does not already have this color
    if (!colorsUsed.includes(distColor)) {
      loopRepeatDistractor = false
    }
  }

  // add the new distractor object
  distractorStrings.push([distColor, repeatDist[1], repeatDist[2], repeatDist[3]]);

  return(sceneMain(condition, targetArray, distractorStrings));
}

/*
createDistractors
Function that creates distractor objects.

Input:
  excludeObjects: (array of arrays) array of objects that already exist in a
    scene and therefore should not be repeated. Each array corresponds to an existing
    object and is of type: [reference to Color Scheme, reference to object ID]
  excludeColors: (array of strings) array of colors that already exist in the
    scene and therefore should not be repeated.
  gender: (int) gender which the objects should be created in
  distractors: (array of arrays) Array that will hold the distractors that are created.
    Each array corresponds to a single distractor object and is of type:
    [object color (string), object color scheme (int), object gender (int), object reference (int)]
  count: number of distractor items that should be created

Output:
  distractors array with the number of distractor objects as specified by "count"
*/
function createDistractors(excludeObjects, excludeColors, gender, distractors, count) {
  // base case
  if (count == 0) {
    return(distractors);
  }

  // initialize parameters of the new distractor object
  loop = true;
  thisCS = 0;
  thisObject = 0;
  thisColor = 0;

  // pick values for those parameters, looping through until they do not
  // conflict with objects and colors already chosen for the scene
  while (loop) {

    // pick a CS
    thisCS = generateInt(1,3);

    // pick the object
    thisObject = generateInt(1, 13);

    // pick its color
    thisColor = pickColor(thisCS);

    // check if it is a repeat of another object type or color
    // exit loop if both properties are new
    if (!(searchForArray(excludeObjects, [thisCS, thisObject]) || excludeColors.includes(thisColor))) {
      loop = false
    }
  }

  // add the new object to distractors
  distractors.push([thisColor, thisCS, gender, thisObject]);

  // add the object color and type to exclusion lists
  excludeObjects.push([thisCS, thisObject]);
  excludeColors.push(thisColor);
  count = count - 1;

  // repeat this function recrusively until we have all the distractor items
  return(createDistractors(excludeObjects, excludeColors, gender, distractors, count));
}

/*
pickColor
picks a random color within a given color scheme

Input:
  color scheme: (int) reference to color scheme

Output: a string specifying a color as defined in cs1Dict and cs2Dict
*/
function pickColor(colorScheme) {
  if (colorScheme == 1) {
    return(cs1Dict[Math.floor(Math.random()*cs1Dict.length)]);
  } else {
    return(cs2Dict[Math.floor(Math.random()*cs2Dict.length)]);
  }
}

/*
pickColorExcept
Return a color within a specified color scheme, that is NOT a specified color

Input:
  colorScheme: (int) reference to color scheme
  color: (string) color that should not be returned

Output: a string specifying a color as defined in cs1Dict and cs2Dict, that
       is not the same as the color held in variable "color"
*/
function pickColorExcept(colorScheme, color) {
  returnColor = pickColor(colorScheme);
  if (returnColor == color) {
    return pickColorExcept(colorScheme, color);
  } else {
    return returnColor;
  }
}

function sampleElementExceptOne(needle, haystack, sampleTwo) {
    let array = haystack.slice(0);
    let index = array.indexOf(needle);

    if (index > -1)
        array.splice(index, 1);

    let firstSampledItem = _.sample(array);

    if (!(sampleTwo))
        return firstSampledItem;

    index = array.indexOf(firstSampledItem);
    array.splice(index, 1)

    let secondSampledItem = _.sample(array);

    return [firstSampledItem, secondSampledItem];
}

/*
generateInt
genderates random integer

Input:
  min: minimum value of range inclusive
  max: maximum value of range exclusive

Output:
  integer that falls between [min, max)
*/
function generateInt(min, max) {

  // find diff
  let difference = max - min;

  // generate random number
  let rand = Math.random();

  // multiply with difference
  rand = Math.floor( rand * difference);

  // add with min value
  rand = rand + min;
      return rand;
}

/*
searchForArray
Searches whether an array is found in an array of arrays

Input:
  haystack: array of arrays that will be searched
  needle: array that you are searching for

Output: boolean as to whether array was found in array of arrays
*/
function searchForArray(haystack, needle){
  var i, j, current;
  for(i = 0; i < haystack.length; ++i){
    if(needle.length === haystack[i].length){
      current = haystack[i];
      for(j = 0; j < needle.length && needle[j] === current[j]; ++j);
      if(j === needle.length)
        return true;
    }
  }
  return false;
}
