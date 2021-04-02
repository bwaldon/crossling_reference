import { StageTimeWrapper } from "meteor/empirica:core";
import React from "react";

class timer extends React.Component {
  render() {
    const { remainingSeconds, stage } = this.props;

    const classes = ["timer"];
    if (remainingSeconds <= 5) {
      classes.push("lessThan5");
    } else if (remainingSeconds <= 10) {
      classes.push("lessThan10");
    }

    const label = stage.name === "feedback" ? "Time until next round:" : "Timer:"

    return (
      <div className={classes.join(" ")}>
        <h4>{label}</h4>
        <span className="seconds">{remainingSeconds}</span>
      </div>
    );
  }
}

export default (Timer = StageTimeWrapper(timer));
