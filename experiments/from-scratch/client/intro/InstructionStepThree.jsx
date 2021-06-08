import React from "react";
import ReactHtmlParser from 'react-html-parser';
import { Centered } from "meteor/empirica:core";
import { instructionsStepThreeTexts } from './instructionTexts.js'

export default class InstructionStepTwo extends React.Component {
  render() {
    const { hasPrev, hasNext, onNext, onPrev, game } = this.props;
    var instructionLanguage = game.treatment.gameLanguage;
    return (
      <Centered>
        <div className="instructions">
          <h1> {instructionsStepThreeTexts[instructionLanguage].instructionTitle} </h1>

           <p> 
           {ReactHtmlParser(instructionsStepThreeTexts[instructionLanguage].instructionLine1)}
          </p>

          <p>
          {instructionsStepThreeTexts[instructionLanguage].instructionLine2}
          </p>

          <center>
          <img src = "guessersample.png" width = "650px" />
          </center>

          <p>
          {instructionsStepThreeTexts[instructionLanguage].instructionLine3}
         </p>

          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
            {instructionsStepThreeTexts[instructionLanguage].previousButtonText}
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
            {instructionsStepThreeTexts[instructionLanguage].nextButtonText}
            </button>
          </p>
        </div>
      </Centered>
    );
  }
}