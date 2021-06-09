import { NonIdealState } from "@blueprintjs/core";
import { IconNames } from "@blueprintjs/icons";
import PropTypes from "prop-types";
import React from "react";

import {gameTexts} from './gameTexts.js'

export default class GameLobby extends React.PureComponent {
  renderPlayersReady = () => {
    const { game, treatment } = this.props;
    const gameTextsLanguage = game.treatment.gameLanguage
    
    return (
      <div className="game-lobby">
        <NonIdealState
          icon={IconNames.PLAY}
          title={gameTexts[gameTextsLanguage].GAMELOBBY_loading}
          description={gameTexts[gameTextsLanguage].GAMELOBBY_loadingDescription}
        />
      </div>
    );
  };

  render() {
    const { game, treatment } = this.props;
    const gameTextsLanguage = game.treatment.gameLanguage

    const total = treatment.factor("playerCount").value;
    const existing = game.playerIds.length;

    if (existing >= total) {
      return this.renderPlayersReady();
    }

    return (
      <div className="game-lobby">
        <NonIdealState
          icon={IconNames.TIME}
          title={gameTexts[gameTextsLanguage].GAMELOBBY_lobbyHeader}
          description={
            <>
              <p>{gameTexts[gameTextsLanguage].GAMELOBBY_waitForPlayers}</p>
              <p>
                {existing} / {total} {gameTexts[gameTextsLanguage].GAMELOBBY_numPlayersReady}
              </p>
            </>
          }
        />
      </div>
    );
  }
}

GameLobby.propTypes = {
  player: PropTypes.object.isRequired,
  game: PropTypes.object.isRequired,
  treatment: PropTypes.object.isRequired
};
