import React from "react";

import { Centered } from "meteor/empirica:core";

export default class InstructionStepTwo extends React.Component {
  render() {
    const { hasPrev, hasNext, onNext, onPrev } = this.props;
    return (
      <Centered>
        <div className="instructions">
          <h1> Game instructions (part 2 of 3) </h1>

          <p>
             One partner will be assigned the role of <u>director</u> and the other will be the <u>guesser</u>. 
          </p>

          <p>
          On each round, one of the objects is the target, which is highlighted with a black box. Only the director can see this black box. The task of the director is to tell the guesser which of the objects is the target. The guesser, in turn, needs to select the target object based on the information provided by the speaker. 
          </p>

          <p>
          Here's a sample round from the director's perspective:
          </p>

          <center>
          <img src = "directorsample.png" width = "600px" />
          </center>

          <p>
          Remember that it doesn’t make sense for the director to describe the location of the target object, since the order of the images is different for the director and the guesser.
          </p>
          <p>
          You will use a chat window to communicate with your partner. The director can use the chat to help the guesser identify the target, and the guesser can use the chat to ask for clarification from the director.
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
