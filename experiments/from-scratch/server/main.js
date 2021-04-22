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
import { subSuperIDsToName } from './itemIDsToName.js';

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

    var basicStimuliTypes = new Set();
    var subStimuliTypes = new Set();
    var supStimuliTypes = new Set();
    var supTypeToBasicTypes = {};
    
    let subSuperStimuli = Object.keys(subSuperIDsToName);
    for (i in subSuperStimuli)
    {
        basicSubSuper = getBasicSubSuperFromID(subSuperStimuli[i]);
        basic = basicSubSuper[0];
        sub = basicSubSuper[1];
        sup = basicSubSuper[2];
    
        basicStimuliTypes.add(basic);
        subStimuliTypes.add(sub);
        supStimuliTypes.add(sup);
        
        if (!(sup in supTypeToBasicTypes))
        {
            supTypeToBasicTypes[sup] = new Set();
        }
        supTypeToBasicTypes[sup].add(basic);
    }
    
    for (i in subSuperStimuli)
    {
        basicSubSuper = getBasicSubSuperFromID(subSuperStimuli[i]);
        basic = basicSubSuper[0];
        sub = basicSubSuper[1];
        sup = basicSubSuper[2];
    
        let distractor1;
        let distractor2;
    
        if (supTypeToBasicTypes[sup].size == 1)
        {
            // can only do Superordinate Sufficient context
            distractor1 = 'blackStimulus';
            distractor2 = 'blackStimulus';
        }
        else
        {
            let context = _.sample(['subNec', 'basicSuff', 'supSuff']);
            if (context == 'subNec')
            {
                supTypeToBasicTypes[sup].delete(basic);
                let distractorBasic = _.sample(Array.from(supTypeToBasicTypes[sup]));
                supTypeToBasicTypes[sup].add(basic);
    
                distractor1 = subSuperIDsToName[getBasicSubSuperID(distractorBasic,
                                                                   _.sample(Array.from(subStimuliTypes)),
                                                                   sup)];
                
                subStimuliTypes.delete(sub);
                let distractorSub = _.sample(Array.from(subStimuliTypes));
                subStimuliTypes.add(sub);
    
                distractor2 = subSuperIDsToName[getBasicSubSuperID(basic,
                                                                   distractorSub,
                                                                   sup)];
            }
            if (context == 'basicSuff')
            {
                let subcontext = _.sample(['basicSuffType1', 'basicSuffType2']);
                if (subcontext == 'basicSuffType1')
                {
                    supTypeToBasicTypes[sup].delete(basic);
                    let distractorBasic1 = _.sample(Array.from(supTypeToBasicTypes[sup]));
                    supTypeToBasicTypes[sup].delete(distractorBasic1);
                    let distractorBasic2 = _.sample(Array.from(supTypeToBasicTypes[sup]));
                    supTypeToBasicTypes[sup].add(basic);
                    supTypeToBasicTypes[sup].add(distractorBasic1);
    
                    distractor1 = subSuperIDsToName[getBasicSubSuperID(distractorBasic1,
                                                                       _.sample(Array.from(subStimuliTypes)),
                                                                       sup)];
                    distractor2 = subSuperIDsToName[getBasicSubSuperID(distractorBasic2,
                                                                       _.sample(Array.from(subStimuliTypes)),
                                                                       sup)];
                }
                else
                {
                    supTypeToBasicTypes[sup].delete(basic);
                    let distractorBasic = _.sample(Array.from(supTypeToBasicTypes[sup]));
                    supTypeToBasicTypes[sup].add(basic);
    
                    distractor1 = subSuperIDsToName[getBasicSubSuperID(distractorBasic,
                                                                       _.sample(Array.from(subStimuliTypes)),
                                                                       sup)];
                    
                    distractor2 = 'blackStimulus';
                }
            }
            if (context == 'supSuff')
            {
                distractor1 = 'blackStimulus';
                distractor2 = 'blackStimulus';
            }
        }
        scenes.push({
            'TargetItem': subSuperIDsToName[getBasicSubSuperID(basic, sub, sup)],
            'alt1Name': distractor1,
            'alt2Name': distractor2,
            'alt3Name': 'IGNORE',
            'alt4Name': 'IGNORE',
            'NumDistractors': 2
        });
    }
    return scenes;
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

function getBasicSubSuperFromID(string)
{
    let basicSubSuper = string.slice(17).split('_');
    let basic = parseInt(basicSubSuper[0]);
    let sub = parseInt(basicSubSuper[1]);
    let sup = parseInt(basicSubSuper[2]);

    return [basic, sub, sup];
}

function getBasicSubSuperID(basic, sub, sup)
{
    return ('subSuperStimulus_' +
            basic.toString() + '_' +
            sub.toString() + '_' +
            sup.toString())
}

function getBasicSubSuperFromID(string)
{
    let basicSubSuper = string.slice(17).split('_');
    let basic = parseInt(basicSubSuper[0]);
    let sub = parseInt(basicSubSuper[1]);
    let sup = parseInt(basicSubSuper[2]);

    return [basic, sub, sup];
}

function getBasicSubSuperID(basic, sub, sup)
{
    return ('subSuperStimulus_' +
            basic.toString() + '_' +
            sub.toString() + '_' +
            sup.toString())
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
