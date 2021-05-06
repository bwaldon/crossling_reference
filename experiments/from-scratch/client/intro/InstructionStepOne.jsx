import React from "react";
import Image from "../game/Image.jsx";

import { Centered } from "meteor/empirica:core";

export default class InstructionStepOne extends React.Component {

  render() {
    const { hasPrev, hasNext, onPrev, onNext, game } = this.props;

    const objects = ["ambulance", "big_green_rock", "lily", "pretzels"];

    const images = objects.map((object,) => { 
      let path = "/images/" + object + ".jpg";
      return(<td><Image image={object} path= {path} /></td>)})

    return (
      <Centered>
        <div className="instructions">
          <h1> Game instructions (part 1 of 3) </h1>

          <p>
            <b> Please read these instructions carefully! You will have to pass a quiz on how the game works before you can play!</b>
          </p>

          <p>
            In this experiment, you will play a guessing game with another person! On each round, both of you will see a set of pictures, like this: 
          </p>

         
          <center>
          <div className="task-stimulus">   
            <table>
              <tr> {images} </tr>
            </table>
          </div>
          </center>

           <p>
          You and your partner will each see the same pictures, <u>but in different orders</u>.
          </p>

          <center>
          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
              Previous
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
              Next
            </button>
          </p>

          </center>
        </div>
      </Centered>
    );
  }
}
