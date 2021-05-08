import React from "react";

import { Centered } from "meteor/empirica:core";

export default class InstructionStepTwo extends React.Component {
  render() {
    const { hasPrev, hasNext, onNext, onPrev } = this.props;
    return (
      <Centered>
        <div className="instructions">
          <h1> Game instructions (part 3 of 3) </h1>

           <p> 
          Once the director sends a message and the guesser selects the object they believe to be the target, both partners are briefly shown which object the guesser clicked on. At this stage, the correct image is highlighted in <font color = "green">green</font>. If the guesser selects an incorrect image, that incorrect selection will be highlighted in <font color = "red"> red</font>. 
          </p>

          <p>
          Here's the guesser's perspective from the round you just saw. On this round, the guesser correctly identified the target:
          </p>

          <center>
          <img src = "guessersample.png" width = "650px" />
          </center>

          <p>
         After reviewing the guesser's selection, you will both be automatically forwarded to the next round of objects. There are a total of 72 rounds. After the 72nd round, you will fill out an optional brief survey and receive a participation code to enter on Prolific.
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