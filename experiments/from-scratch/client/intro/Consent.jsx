import React from "react";
import { gameText } from "../gameText.js";
import { Centered } from "meteor/empirica:core";

export default class Consent extends React.Component {
  render() {
    const { game, onNext, hasNext } = this.props;
    let gameLang;
    if (game.treatment.showConsentInNativeLanguage) {
      gameLang = game.treatment.gameLanguage;
    } else {
      gameLang = "English";
    }
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == gameLang
    )[0];

    return (
      <Centered>
        <div className="consent" dir="auto">
          <img src="stanfordlogo.png" width="300px" />{" "}
          <img src="alpslogo.png" width="300px" />
          <h1> {gameTextInLanguage.CONSENT_Title} </h1>
          <p> {gameTextInLanguage.CONSENT_Line1}</p>
          <p> {gameTextInLanguage.CONSENT_Line2}</p>
          <p> {gameTextInLanguage.CONSENT_Line3}</p>
          <p> {gameTextInLanguage.CONSENT_Line4}</p>
          <p> {gameTextInLanguage.CONSENT_Line5}</p>
          <p> {gameTextInLanguage.CONSENT_Line6}</p>
          <br />
          <center>
            <p>
              <button type="button" onClick={onNext}>
                {gameTextInLanguage.CONSENT_AgreeButtonText}
              </button>
            </p>
          </center>
        </div>
      </Centered>
    );
  }
}
