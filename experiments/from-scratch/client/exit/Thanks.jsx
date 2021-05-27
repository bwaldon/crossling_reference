import React from "react";

import { Centered } from "meteor/empirica:core";

import { exitTexts, exitTextsLanguage } from './exitTexts.js';

export default class Thanks extends React.Component {
  static stepName = "Thanks";
  render() {
    const { game } = this.props;
    return (
        <div>
          <h4>{exitTexts[exitTextsLanguage].THANKS_finished}</h4>
          <p>{exitTexts[exitTextsLanguage].THANKS_thanksForParticipating}</p>
          <p>{exitTexts[exitTextsLanguage].THANKS_prolificCodePart1} <b>{game.treatment.prolificCode}</b>{exitTexts[exitTextsLanguage].THANKS_prolificCodePart2}</p>
        </div>
    );
  }
}
