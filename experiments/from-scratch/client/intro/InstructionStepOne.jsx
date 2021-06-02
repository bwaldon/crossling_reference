import React from "react";
import Image from "../game/Image.jsx";

import { Centered } from "meteor/empirica:core";
import { instructionsStepOneTexts } from './instructionTexts.js';

export default class InstructionStepOne extends React.Component {

  render() {
    const { hasPrev, hasNext, onPrev, onNext, game } = this.props;
    
    var instructionLanguage = game.treatment.gameLanguage;

    const objects = ["ambulance", "big_green_rock", "lily", "pretzels"];

    const images = objects.map((object,) => { 
      let path = "/images/" + object + ".jpg";
      return(<td><Image image={object} path= {path} /></td>)})

    return (
      <Centered>
        <div className="instructions">
          <h1> {instructionsStepOneTexts[instructionLanguage].instructionTitle} </h1>

          <p>
            <b> {instructionsStepOneTexts[instructionLanguage].instructionLine1} </b>
          </p>

          <p>
          {instructionsStepOneTexts[instructionLanguage].instructionLine2}
          </p>

         
          <center>
          <div className="task-stimulus">   
            <table>
              <tr> {images} </tr>
            </table>
          </div>
          </center>

           <p>
           {instructionsStepOneTexts[instructionLanguage].instructionLine3}
          </p>

          <center>
          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
            {instructionsStepOneTexts[instructionLanguage].previousButtonText}
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
            {instructionsStepOneTexts[instructionLanguage].nextButtonText}
            </button>
          </p>

          </center>
        </div>
      </Centered>
    );
  }
}
