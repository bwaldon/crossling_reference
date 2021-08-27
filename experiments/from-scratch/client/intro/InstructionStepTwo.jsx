import React from "react";
import ReactHtmlParser from 'react-html-parser';
import { gameText } from "../gameText.js";
import { Centered } from "meteor/empirica:core";

export default class InstructionStepTwo extends React.Component {
  render() {
    const { hasPrev, hasNext, onNext, onPrev, game } = this.props;

    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

    return (
      <Centered>
        <div className="instructions">
          <h1> {gameTextInLanguage.instructionTitle} </h1>

          <p>
          {ReactHtmlParser(gameTextInLanguage.instruction2Line1)}
          </p>

          <p>
          {gameTextInLanguage.instruction2Line2}
          </p>

          <p>
          {gameTextInLanguage.instruction2Line3}
          </p>

          <center>
          <img src = "directorsample.png" width = "600px" />
          </center>

          <p>
          {gameTextInLanguage.instruction2Line4}
          </p>
          <p>
          {gameTextInLanguage.instruction2Line5}
          </p>

          <center>
            <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
            {gameTextInLanguage.previousButtonText}
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
            {gameTextInLanguage.nextButtonText}
            </button>
            </p>
          </center>
        </div>
      </Centered>
    );
  }
}
