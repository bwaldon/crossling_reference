import React from "react";
import EventLog from "./EventLog";
import ChatLog from "./ChatLog";
import ReactHtmlParser from 'react-html-parser';
import { gameText } from "../gameText.js";

export default class SocialInteractions extends React.Component {
  renderPlayer(player, self = false) {
    return (
      <div className="player" key={player._id}>
        <span className="image"></span>
        <img src={player.get("avatar")} />
        <span className="name" style={{ color: player.get("nameColor") }}>
          {player.get("name")}
          {self ? " (You)" :  ""}
        </span>
        <span className="name" style={{ color: player.get("nameColor") }}>
          ${(player.get("bonus")||0).toFixed(2)}
        </span>
      </div>
    );
  }

  render() {
    const { game, round, stage, player } = this.props;
    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

    const otherPlayers = _.reject(game.players, p => p._id === player._id);
    const messages = round.get("chat")
          .map(({ text, playerId, type }) => ({
            text,
            subject: game.players.find(p => p._id === playerId),
            type : type
          }));

    return (
      <div className="social-interactions">    
        <center>
        {player.get('role') === "listener" ? ReactHtmlParser("<b>" + gameTextInLanguage.PLAYERPROFILE_youAreGuesser + "</b>") : ReactHtmlParser("<b>" + gameTextInLanguage.PLAYERPROFILE_youAreDirector + "</b>")}
        </center>
        <ChatLog messages={messages} game={game} round={round} stage={stage} player={player} />

      </div>
    );
  }
}
