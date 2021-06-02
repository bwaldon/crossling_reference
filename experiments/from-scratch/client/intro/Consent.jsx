import React from "react";
import { introTexts, introLanguage } from "./introTexts.js";

import { Centered, ConsentButton } from "meteor/empirica:core";

export default class Consent extends React.Component {
  render() {
    // // const { game } = this.props;
    // console.log(this.props)
    // // var introLanguage = game.treatment.gameLanguage;

    return (
      <Centered>
        <div className="consent">
          <img src = "stanfordlogo.png" width = "300px" />  <img src = "alpslogo.png" width = "300px" />
          <h1> { introTexts[introLanguage].ConsentFormTitle } </h1>
          <p> { introTexts[introLanguage].ConsentFormLine1 }
          </p>

          <p> { introTexts[introLanguage].ConsentFormLine2 }
          </p>

          <p> { introTexts[introLanguage].ConsentFormLine3 }
          </p>

          <p> { introTexts[introLanguage].ConsentFormLine4 }
          </p>

          <p> { introTexts[introLanguage].ConsentFormLine5 }
          </p>

          <p> { introTexts[introLanguage].ConsentFormLine6 }
          </p>

          <br />
          <ConsentButton text={ introTexts[introLanguage].AgreeButtonText } />
        </div>
      </Centered>
    );
  }
}
