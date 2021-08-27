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
          <h1> {gameTextInLanguage.INSTRUCTION3_Title} </h1>

           <p> 
           {ReactHtmlParser(gameTextInLanguage.INSTRUCTION3_Line1)}
          </p>

          <p>
          {gameTextInLanguage.INSTRUCTION3_Line2}
          </p>

          <center>
          <img src = "guessersample.png" width = "650px" />
          </center>

          <p>
          {gameTextInLanguage.INSTRUCTION3_Line3}
         </p>

         <center>
          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
            {gameTextInLanguage.INSTRUCTION_previousButtonText}
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
            {gameTextInLanguage.INSTRUCTION_nextButtonText}
            </button>
          </p>
          </center>
        </div>
      </Centered>
    );
  }
}