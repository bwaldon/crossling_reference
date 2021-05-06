import React from "react";

import { Centered } from "meteor/empirica:core";

export default class Thanks extends React.Component {
  static stepName = "Thanks";
  render() {
    const { game } = this.props;
    return (
        <div>
          <h4>Finished!</h4>
          <p>Thank you for participating!</p>
          <p>Your Prolific participation code is <b> {game.treatment.prolificCode}</b>.</p>
        </div>
        
    );
  }
}
