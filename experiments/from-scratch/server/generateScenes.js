import Empirica from "meteor/empirica:core";

import { colorSizeIDsToName } from './itemIDsToName.js';
import { subToBasicAndSup } from './supSupTrialsItems.js';
import { supToBasicsToSubs } from './supSupTrialsItems.js';
import { subSupTrialsTargets } from './supSupTrialsItems.js';

exports.generateScenes = function generateScenes() {
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
            let sufficientDimension = "size";
            let redundantStimulus = getColorSizeIDString(targetType, 1 - color, size);
            let otherStimulus = getColorSizeIDString(targetType, 1 - color, 1 - size);

            scenes.push(getSceneFromStimuli(
                nTotalDistractors,
                nRedundantDistractors,
                targetStimulus,
                redundantStimulus,
                otherStimulus,
                sufficientDimension
            ));

            targetType = colorSizeItemTypes.pop();
            color = (Math.random() > 0.5)? 1 : 0;
            size = (Math.random() > 0.5)? 1 : 0;
            targetStimulus = getColorSizeIDString(targetType, color, size);
            sufficientDimension = "color";
            redundantStimulus = getColorSizeIDString(targetType, color, 1 - size);
            otherStimulus = getColorSizeIDString(targetType, 1 - color, 1 - size);

            scenes.push(getSceneFromStimuli(
                nTotalDistractors,
                nRedundantDistractors,
                targetStimulus,
                redundantStimulus,
                otherStimulus,
                sufficientDimension
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
            if ((_.sample(['type1', 'type2']) == 'type1'))
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
            'NumDistractors': 2,
            'condition' : contextMode
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

function getSceneFromStimuli(nTotalDistractors, nRedundantDistractors, targetStimulus, redundantStimulus, otherStimulus, 
    sufficientDimension)
{
    let scene = {
        'TargetItem': colorSizeIDsToName[targetStimulus],
        'NumDistractors': nTotalDistractors,
        'condition' : sufficientDimension + nTotalDistractors + nRedundantDistractors
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
            colorID.toString());
}