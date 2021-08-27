import React from "react";
import { gameText } from "../gameText.js";
import { Centered } from "meteor/empirica:core";

export default class Consent extends React.Component {
  render() {
    const { game, onNext, hasNext } = this.props;
    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

    return (
      <Centered>
        <div className="consent">
          <img src = "stanfordlogo.png" width = "300px" />  <img src = "alpslogo.png" width = "300px" />
          <h1> { gameTextInLanguage.ConsentFormTitle } </h1>
          <p> { gameTextInLanguage.ConsentFormLine1 }
          </p>

          <p> { gameTextInLanguage.ConsentFormLine2 }
          </p>

          <p> { gameTextInLanguage.ConsentFormLine3 }
          </p>

          <p> { gameTextInLanguage.ConsentFormLine4 }
          </p>

          <p> { gameTextInLanguage.ConsentFormLine5 }
          </p>

          <p> { gameTextInLanguage.ConsentFormLine6 }
          </p>

          <br />

          <center>
          <p>
          <button type="button" onClick={onNext}> 
          {gameTextInLanguage.AgreeButtonText}
          </button>
          </p>
          </center>
        </div>
      </Centered>
    );
  }
}
