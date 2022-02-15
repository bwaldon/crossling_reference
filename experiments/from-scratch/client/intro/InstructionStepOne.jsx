import React from "react";
import Image from "../game/Image.jsx";
import { gameText } from "../gameText.js";
import { Centered } from "meteor/empirica:core";

export default class InstructionStepOne extends React.Component {
  render() {
    const { hasPrev, hasNext, onPrev, onNext, game } = this.props;

    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    const objects = ["ambulance", "big_grey_rock", "lily", "pretzels"];

    const images = objects.map((object) => {
      let path = "/images/" + object + ".jpg";
      return (
        <td>
          <Image image={object} path={path} />
        </td>
      );
    });

    return (
      <Centered>
        <div className="instructions" dir="auto">
          <h1> {gameTextInLanguage.INSTRUCTION1_Title} </h1>

          <p>
            <b> {gameTextInLanguage.INSTRUCTION1_Line1} </b>
          </p>

          <p>{gameTextInLanguage.INSTRUCTION1_Line2}</p>

          <center>
            <div className="task-stimulus">
              <table>
                <tr> {images} </tr>
              </table>
            </div>
          </center>

          <p>{gameTextInLanguage.INSTRUCTION1_Line3}</p>

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
