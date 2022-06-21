import Empirica from "meteor/empirica:core";
import "./bots.js";
import "./callbacks.js";
const glob = require("glob");

// gameInit is where the structure of a game is defined.
// Just before every game starts, once all the players needed are ready, this
// function is called with the treatment and the list of players.
// You must then add rounds and stages to the game, depending on the treatment
// and the players. You can also get/set initial values on your game, players,
// rounds and stages (with get/set methods), that will be able to use later in
// the game.


// Test the generateScenes module by calling it 100 times.
// console.log(process.cwd())
// const fs = require('fs');
// let testObject = [];
// _.times(100, i => { testObject.push(generateScenesObject.generateScenes()) })
// fs.writeFileSync('../../../../../server/testOut.json', JSON.stringify(testObject) )

Empirica.gameInit((game) => {

  // the values in the if/if else statments must match the sceneGenerator factor
  // for each game created
  // this factor determines which generateScenes file will be used, and thus
  // which stimuli will be shown.
  const generateScenesObject = function() {
    if (game.treatment.sceneGenerator == "BCS") {
      return(require("./BCS/generateScenesBCS"));
    // } else if (game.treatment.sceneGenerator == "BCS2") {
    //   return(require("./BCS/generateScenesBCS2"));
  } else if (game.treatment.sceneGenerator == "BCS2") {
      return(require("./BCS/generateScenesBCS2"));
  } else {
      return(require("./degenEtal2020/generateScenes"));
    }
  }();

  game.players.forEach((player, i) => {
    player.set("avatar", `/avatars/jdenticon/${player._id}`);
    player.set("score", 0);
  });

  const gameLength = game.treatment.length;

  let scenes = _.shuffle(generateScenesObject.generateScenes());
  _.times(gameLength, (i) => {
    let scene = scenes.pop();
    let images = [
      { name: scene.TargetItem, id: 1 },
      { name: scene.alt1Name, id: 2 },
      { name: scene.alt2Name, id: 3 },
      { name: scene.alt3Name, id: 4 },
      { name: scene.alt4Name, id: 5 },
      { name: scene.alt5Name, id: 6 },
    ];
    images = images.filter((image) => image.name !== "IGNORE");

    const target = { name: scene.TargetItem, id: 1 };

    const round = game.addRound({
      data: {
        language: game.treatment.gameLanguage,
        target: target,
        images: images,
        speakerImages: _.shuffle(images),
        listenerImages: _.shuffle(images),
        stage: "selection",
        condition: scene.condition,
        alt1BasicLevel: scene.alt1BasicLevel,
        alt1SuperLevel: scene.alt1SuperLevel,
        alt2BasicLevel: scene.alt2BasicLevel,
        alt2SuperLevel: scene.alt2SuperLevel,
      },
    });
    round.addStage({
      name: "response",
      displayName: "Task",
      durationInSeconds: 240,
    });
    // round.addStage({
    //   name: "feedback",
    //   displayName: "Feedback",
    //   durationInSeconds: 3,
    // });
  });

  game.set("length", gameLength);
});
