import React from "react";
import ReactHtmlParser from 'react-html-parser';
import { Centered } from "meteor/empirica:core";
import { instructionsStepTwoTexts } from "./instructionTexts.js"

export default class InstructionStepTwo extends React.Component {
  render() {
    const { hasPrev, hasNext, onNext, onPrev, game } = this.props;

    var instructionLanguage = game.treatment.gameLanguage;

    return (
      <Centered>
        <div className="instructions">
          <h1> {instructionsStepTwoTexts[instructionLanguage].instructionTitle} </h1>

          <p>
          {ReactHtmlParser(instructionsStepTwoTexts[instructionLanguage].instructionLine1)}
          </p>

          <p>
          {instructionsStepTwoTexts[instructionLanguage].instructionLine2}
          </p>

          <p>
          {instructionsStepTwoTexts[instructionLanguage].instructionLine3}
          </p>

          <center>
          <img src = "directorsample.png" width = "600px" />
          </center>

          <p>
          {instructionsStepTwoTexts[instructionLanguage].instructionLine4}
          </p>
          <p>
          {instructionsStepTwoTexts[instructionLanguage].instructionLine5}
          </p>

          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
            {instructionsStepTwoTexts[instructionLanguage].previousButtonText}
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
            {instructionsStepTwoTexts[instructionLanguage].nextButtonText}
            </button>
          </p>
        </div>
      </Centered>
    );
  }
}
