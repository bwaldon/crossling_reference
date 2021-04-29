import Empirica from "meteor/empirica:core";
import "./bots.js";
import "./callbacks.js";
const glob = require('glob');
// import generateScenes from './generateScenes.js'; // why does this not work?
import { scenes } from "./scenes.js"

// gameInit is where the structure of a game is defined.
// Just before every game starts, once all the players needed are ready, this
// function is called with the treatment and the list of players.
// You must then add rounds and stages to the game, depending on the treatment
// and the players. You can also get/set initial values on your game, players,
// rounds and stages (with get/set methods), that will be able to use later in
// the game.

import { colorSizeIDsToName } from './itemIDsToName.js';
import { subToBasicAndSup } from './supSupTrialsItems.js';
import { supToBasicsToSubs } from './supSupTrialsItems.js';
import { subSupTrialsTargets } from './supSupTrialsItems.js';

function generateScenes() {
    const colorSizeDistractorConditions = [
        [2, 1],
        [2, 2],
        [3, 1],
        [3, 2],
        [3, 3],
        [4, 1],
        [4, 2],
        [4, 3],
        [4, 4]
    ];

    let colorSizeItemTypes = Array.from(Array(36).keys()); // TODO shuffle this list

    let scenes = [];

    for (i in colorSizeDistractorConditions)
    {
        let nTotalDistractors = colorSizeDistractorConditions[i][0];
        let nRedundantDistractors = colorSizeDistractorConditions[i][1];

        for (j in [0, 1])
        {
            let targetType = colorSizeItemTypes.pop();
            let color = (Math.random() > 0.5)? 1 : 0;
            let size = (Math.random() > 0.5)? 1 : 0;
            let targetStimulus = getColorSizeIDString(targetType, color, size);
            let redundantStimulus = getColorSizeIDString(targetType, 1 - color, size);
            let otherStimulus = getColorSizeIDString(targetType, 1 - color, 1 - size);

            scenes.push(getSceneFromStimuli(
                nTotalDistractors,
                nRedundantDistractors,
                targetStimulus,
                redundantStimulus,
                otherStimulus
            ));

            targetType = colorSizeItemTypes.pop();
            color = (Math.random() > 0.5)? 1 : 0;
            size = (Math.random() > 0.5)? 1 : 0;
            targetStimulus = getColorSizeIDString(targetType, color, size);
            redundantStimulus = getColorSizeIDString(targetType, color, 1 - size);
            otherStimulus = getColorSizeIDString(targetType, 1 - color, 1 - size);

            scenes.push(getSceneFromStimuli(
                nTotalDistractors,
                nRedundantDistractors,
                targetStimulus,
                redundantStimulus,
                otherStimulus
            ));
        }
    }

    for (i in subSupTrialsTargets)
    {
        let targetSub = subSupTrialsTargets[i];
        let basicAndSup = subToBasicAndSup[targetSub];
        let targetBasic = basicAndSup[0];
        let targetSup = basicAndSup[1];

        let contextMode = _.sample(['subNec', 'basicSuff', 'supSuff']);

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
            if ((_.sample(['type1', 'type2']) == 'type1') && false)
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

        scenes.push({
            'TargetItem': targetSub,
            'alt1Name': distractor1,
            'alt2Name': distractor2,
            'alt3Name': 'IGNORE',
            'alt4Name': 'IGNORE',
            'NumDistractors': 2
        });
    }
    return scenes;
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

function getSceneFromStimuli(nTotalDistractors, nRedundantDistractors, targetStimulus, redundantStimulus, otherStimulus)
{
    let scene = {
        'TargetItem': colorSizeIDsToName[targetStimulus],
        'NumDistractors': nTotalDistractors
    }
    for (i = 1; i <= nRedundantDistractors; i++)
    {
        scene['alt' + i.toString() + 'Name'] = colorSizeIDsToName[redundantStimulus];
    }
    for (i = nRedundantDistractors + 1; i <= nTotalDistractors; i++)
    {
        scene['alt' + i.toString() + 'Name'] = colorSizeIDsToName[otherStimulus];
    }
    for (i = nTotalDistractors + 1; i <= 4; i++)
    {
        scene['alt' + i.toString() + 'Name'] = 'IGNORE';
    }
    return scene
}

function getColorSizeIDString(itemID, sizeID, colorID)
{
    return ('colorSizeStimulus_' +
            itemID.toString() + '_' +
            sizeID.toString() + '_' +
            colorID.toString())
}

Empirica.gameInit(game => {
  game.players.forEach((player, i) => {
    player.set("avatar", `/avatars/jdenticon/${player._id}`);
    player.set("score", 0);
  });

  const gameLength = 72;

  let scenes = _.shuffle(generateScenes());
  _.times(gameLength, i => {
    let scene = scenes.pop();
    console.log(scene);
    let images = [{name: scene.TargetItem, id: 1}, {name: scene.alt1Name, id: 2}, {name: scene.alt2Name, id: 3}, {name: scene.alt3Name, id: 4}, {name: scene.alt4Name, id: 5}]
    images = images.filter(image => image.name !== "IGNORE")

    const target = {name: scene.TargetItem, id: 1}

    const round = game.addRound({
      data: {
        target: target,
        images: images,
        speakerImages: _.shuffle(images),
        listenerImages: _.shuffle(images),
      }
    });
    round.addStage({
      name: "response",
      displayName: "Task",
      durationInSeconds: 180,
    });
    round.addStage({
      name: "feedback",
      displayName: "Feedback",
      durationInSeconds: 3,
    });
  });

  game.set('length', gameLength)

});
