import colorSizeIDsToName from './itemIDsToName.js'

export function generateScenes() {
    const nSubSuperTrials = 36;

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
    console.log(scenes);
}

function getSceneFromStimuli(nTotalDistractors, nRedundantDistractors, targetStimulus, redundantStimulus, otherStimulus)
{
    let scene = {
        'TargetItem': colorSizeIDsToName[targetStimulus],
        'NumDistractors': nTotalDistractors
    }
    console.log(nRedundantDistractors);
    for (i = 1; i <= nRedundantDistractors; i++)
    {
        scene['alt' + i.toString() + 'Name'] = colorSizeIDsToName[redundantStimulus];
    }
    for (i = nRedundantDistractors + 1; i <= nTotalDistractors; i++)
    {
        scene['alt' + i.toString() + 'Name'] = colorSizeIDsToName[otherStimulus];
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