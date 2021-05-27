import { StageTimeWrapper } from "meteor/empirica:core";
import React from "react";
import {gameTexts, gameTextsLanguage} from './gameTexts.js'

class timer extends React.Component {
  render() {
    const { round, stage, remainingSeconds } = this.props;

    const classes = ["timer"];
    if (remainingSeconds <= 5) {
      classes.push("lessThan5");
    } else if (remainingSeconds <= 10) {
      classes.push("lessThan10");
    }

    const label = round.get('stage') === "feedback" ? gameTexts[gameTextsLanguage].TIMER_timeUntilNextRound : ""

    return (
      <div className={classes.join(" ")}>
        <h4>{label}</h4>
        <span className="seconds">{remainingSeconds}</span>
      </div>
    );
  }
}

export default (Timer = StageTimeWrapper(timer));
