import React from "react";
import { gameText } from "../gameText.js";

import { Centered } from "meteor/empirica:core:dnd";

export default class Thanks extends React.Component {
  static stepName = "Thanks";
  render() {
    const { game } = this.props;
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    return (
      <div dir="auto">
        <h4>{gameTextInLanguage.THANKS_finished}</h4>
        <p>{gameTextInLanguage.THANKS_thanksForParticipating}</p>
        {game.treatment.showProlificCode ? (
          <p>
            {gameTextInLanguage.THANKS_prolificCodePart1}{" "}
            <b>{game.treatment.prolificCode}</b>
            {gameTextInLanguage.THANKS_prolificCodePart2}
          </p>
        ) : null}
      </div>
    );
  }
}
