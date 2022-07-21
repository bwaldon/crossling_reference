import { NonIdealState } from "@blueprintjs/core";
import { IconNames } from "@blueprintjs/icons";
import { gameText } from "../gameText.js";
import PropTypes from "prop-types";
import React from "react";

export default class GameLobby extends React.PureComponent {
  renderPlayersReady = () => {
    const { game, treatment } = this.props;
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    return (
      <div className="game-lobby" dir="auto">
        <NonIdealState
          icon={IconNames.PLAY}
          title={gameTextInLanguage.GAMELOBBY_loading}
          description={gameTextInLanguage.GAMELOBBY_loadingDescription}
        />
      </div>
    );
  };

  render() {
    const { game, treatment } = this.props;
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    const total = treatment.factor("playerCount").value;
    const existing = game.playerIds.length;

    if (existing >= total) {
      return this.renderPlayersReady();
    }

    return (
      <div className="game-lobby" dir="auto">
        <NonIdealState
          icon={IconNames.TIME}
          title={gameTextInLanguage.GAMELOBBY_lobbyHeader}
          description={
            <>
              <p>{gameTextInLanguage.GAMELOBBY_waitForPlayers}</p>
              <p>
                {existing} / {total}{" "}
                {gameTextInLanguage.GAMELOBBY_numPlayersReady}
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
  treatment: PropTypes.object.isRequired,
};
