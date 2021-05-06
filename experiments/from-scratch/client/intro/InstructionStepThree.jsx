import React from "react";

import { Centered } from "meteor/empirica:core";

export default class InstructionStepTwo extends React.Component {
  render() {
    const { hasPrev, hasNext, onNext, onPrev } = this.props;
    return (
      <Centered>
        <div className="instructions">
          <h1> Game instructions (part 2 of 2) </h1>

          <center>
          <img src = "directorsample.png" width = "600px" />
          </center>

          <p> 
          Once the speaker sends a message and the listener clicks on the object they believe is the target, both partners are briefly shown which object the guesser clicked on. If the guesser selects an incorrect image, that incorrect selection will be highlighted in <style = "font:red"> red </style>. 
          </p>

          <p>
         After the guesser makes a selection, you will both be automatically forwarded to the next round of objects. There are a total of 72 rounds. After the 72nd round, you will fill out an optional brief survey and receive a participation code to enter on Prolific.
         </p>

          <p>
            <button type="button" onClick={onPrev} disabled={!hasPrev}>
              Previous
            </button>
            <button type="button" onClick={onNext} disabled={!hasNext}>
              Next
            </button>
          </p>
        </div>
      </Centered>
    );
  }
}