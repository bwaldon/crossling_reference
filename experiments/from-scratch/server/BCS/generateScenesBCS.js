/*

Explain this document, its output, and how it interacts with the rest of the app.

Explain:
- rotations
- where to find all the relevant info in the repo about the trials and conditions etc.


comment all the relevant files



Questions for Brandon:
- condition in each trial --> what is it for and what should I put there?
- how do we want to decide the rotations

*/

import Empirica from "meteor/empirica:core";

import { colorSizeIDsToName } from '../degenEtal2020/itemIDsToName.js';
import { subToBasicAndSup } from '../degenEtal2020/supSupTrialsItems.js';
import { supToBasicsToSubs } from '../degenEtal2020/supSupTrialsItems.js';
import { subSupTrialsTargets } from '../degenEtal2020/supSupTrialsItems.js';

import { allDef } from './BCSitemIDsToName.js';
import { allRotations } from './BCSrotations.js';
import { cs1Dict } from './BCScolorSchemes.js';
import { cs2Dict } from './BCScolorSchemes.js';

exports.generateScenes = function generateScenes() {
      // array to hold all the scenes we create
      let scenes = [];

      // CREATE TARGET SCENES

      // iterate through scenarios in both color schemes
      for (let determineColorScheme = 1; determineColorScheme < 3; determineColorScheme++) {
        // iterate through the target object genders
        // 1 = masculine, 2 = feminine
        for (let g = 1; g < 3; g++) {
          oppositeGender = "";
          if(g == 1) {
            oppositeGender = "2";
          } else {
            oppositeGender = "1";
          }

          // pick rotation randomly
          rot = allRotations[Math.floor(Math.random()*allRotations.length)];

          // create all three trials of scene 1
          // scene 1 is a color necessary scene
          scenes.push(sceneColorNecessary(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[0][0],
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[0][1], "scene1"));
          scenes.push(sceneColorNecessary(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[1][0],
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[1][1], "scene1"));
          scenes.push(sceneColorNecessary(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[2][0],
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[2][1], "scene1"));

          // create all 3 three trials of scene 2
          // scene 2 is a color redundant scene
          scenes.push(sceneColorRedundant(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[3][0],
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[3][1], "scene2"));
          scenes.push(sceneColorRedundant(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[4][0],
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[4][1], "scene2"));
          scenes.push(sceneColorRedundant(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[5][0],
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[5][1], "scene2"));

          // create all 3 three trials of scene 3
          // scene 3 is a color redundant scene
          scenes.push(sceneColorRedundant(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[6][0],
            "BCSStimulus_" + determineColorScheme + "_" + oppositeGender + "_" + rot[6][1], "scene3"));
          scenes.push(sceneColorRedundant(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[7][0],
            "BCSStimulus_" + determineColorScheme + "_" + oppositeGender + "_" + rot[7][1], "scene3"));
          scenes.push(sceneColorRedundant(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[8][0],
            "BCSStimulus_" + determineColorScheme + "_" + oppositeGender + "_" + rot[8][1], "scene3"));

          // create all 3 three trials of scene 4
          // scene 4 is a color necessary scene
          scenes.push(sceneColorNecessary(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[9][0],
            "BCSStimulus_" + determineColorScheme + "_" + oppositeGender + "_" + rot[9][1], "scene4"));
          scenes.push(sceneColorNecessary(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[10][0],
            "BCSStimulus_" + determineColorScheme + "_" + oppositeGender + "_" + rot[10][1], "scene4"));
          scenes.push(sceneColorNecessary(determineColorScheme,
            "BCSStimulus_" + determineColorScheme + "_" + g + "_" + rot[11][0],
            "BCSStimulus_" + determineColorScheme + "_" + oppositeGender + "_" + rot[11][1], "scene4"));
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
              'alt1BasicLevel': alt1Basic,
              'alt1SuperLevel': alt1Super,
              'alt2BasicLevel': alt2Basic,
              'alt2SuperLevel': alt2Super,
              'NumDistractors': 2,
              'condition' : contextMode
          });
      }

      return(scenes);
    }

    // return a dicitionary defining the target and other objects
    // Take in the color scheme, target object, and distractor object
    // return dictionary including following keys
    //
    // Diciontary format:
    //    TargetItem: string of format [randomly assigned color]_[target name]
    //                This must match the name of the jpg image for each target item
    //                 but should not include the '.jpg'
    //    NumDistractors: 2 (number of distractors)
    //    alt1Name: string of format [randomly assigned color]_[distractor name]
    //    alt2Name: string of format [randomly assigned color]_[distractor name]
    //    alt3Name: 'IGNORE' (because we only have 2 distractors)
    //    alt4Name: 'IGNORE'
    //    alt1BasicLevel: 'NA',
    //          This specifies the level (basic of superordinate) of the alternative
    //            items. This was used for Degen et al. 2020 experiment 3 items.
    //            These items will be used as the fillers for the BCS RSA experiment,
    //            so we keep these levels.
    //    alt1SuperLevel: 'NA',
    //    alt2BasicLevel: 'NA',
    //    alt2SuperLevel: 'NA',
    //    condition: ??? 0--> BRANDON< WHAT DOES TZHIS DO. and can I use it as a rotation???
    //

    function sceneMain(colorScheme, target, distractor, distractor2, condition) {
      targetColor = pickColor(colorScheme);
      distractorColor = pickColorExcept(colorScheme, targetColor);

      // convert target and distractor into actual string
      targetString = allDef[target];
      distractorString = allDef[distractor];
      distractor2String = allDef[distractor2];

      return({
        'TargetItem': targetColor + "_" + targetString,
        'NumDistractors': 2,
        'alt1Name': targetColor + "_" + distractorString,
        'alt2Name': distractorColor + "_" + distractor2String,
        'alt3Name': 'IGNORE',
        'alt4Name': 'IGNORE',
        'alt1BasicLevel': 'NA',
        'alt1SuperLevel': 'NA',
        'alt2BasicLevel': 'NA',
        'alt2SuperLevel': 'NA',
        'condition': condition
      })
    }


  // wrapper for color necessary condition. Calls on sceneMain and returns exact output
  // as SceneMaine, but this function determines that the second distractor item
  // will be the same type as the target
  function sceneColorNecessary(colorScheme, target, distractor, condition) {
    return(sceneMain(colorScheme, target, distractor, target, condition));
  }

  // wrapper for color redundant condition. Calls on sceneMain and returns exact output
  // as SceneMaine, but this function determines that the second distractor item
  // will be of a different type than the target (i.e. the two distractor items
  // will be the same type)
  function sceneColorRedundant(colorScheme, target, distractor, condition) {
    return(sceneMain(colorScheme, target, distractor, distractor, condition));
  }

  // Return a color within a specified color scheme
  // INPUT: int {1, 2}
  //        1 = color scheme 1
  //        2 = color scheme 2
  // OUTPUT: a string specifying a color as defined in cs1Dict and cs2Dict
  function pickColor(colorScheme) {
    if (colorScheme == 1) {
      return(cs1Dict[Math.floor(Math.random()*cs1Dict.length)]);
    } else {
      return(cs2Dict[Math.floor(Math.random()*cs2Dict.length)]);
    }
  }

  // Return a color within a specified color scheme, that is NOT a specified color
  // INPUT: int {1, 2}
  //           1 = color scheme 1
  //            2 = color scheme 2
  //        string: color as defined in cs1Dict and cs2Dict
  // OUTPUT: a string specifying a color as defined in cs1Dict and cs2Dict, that
  //        is not the same as the color held in variable "color"
  function pickColorExcept(colorScheme, color) {
    returnColor = pickColor(colorScheme);
    if (returnColor == color) {
      return pickColorExcept(colorScheme, color);
    } else {
      return returnColor;
    }
  }

  function sampleElementExceptOne(needle, haystack, sampleTwo)
  {
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
