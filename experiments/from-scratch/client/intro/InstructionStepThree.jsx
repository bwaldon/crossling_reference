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
          <h1> {gameTextInLanguage.instruction3Title} </h1>

           <p> 
           {ReactHtmlParser(gameTextInLanguage.instruction3Line1)}
          </p>

          <p>
          {gameTextInLanguage.instruction3Line2}
          </p>

          <center>
          <img src = "guessersample.png" width = "650px" />
          </center>

          <p>
          {gameTextInLanguage.instruction3Line3}
         </p>

          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
            {gameTextInLanguage.previousButtonText}
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
            {gameTextInLanguage.nextButtonText}
            </button>
          </p>
        </div>
      </Centered>
    );
  }
}