import React from "react";
import {gameTexts, gameTextsLanguage} from './gameTexts.js'

export default class WaitingForServer extends React.Component {
  render() {
    return (
      <div className="game waiting">
        <div className="pt-non-ideal-state">
          <div className="pt-non-ideal-state-visual pt-non-ideal-state-icon">
            <span className="pt-icon pt-icon-automatic-updates" />
          </div>
          <h4 className="pt-non-ideal-state-title">
            {/* A more neutral message in case it was a single player */}
            {gameTexts[gameTextsLanguage].WAITINGFORSERVER_waitingForServerResponse}
          </h4>
          <div className="pt-non-ideal-state-description">
          {gameTexts[gameTextsLanguage].WAITINGFORSERVER_waitingForPlayers}
          </div>
        </div>
      </div>
    );
  }
}