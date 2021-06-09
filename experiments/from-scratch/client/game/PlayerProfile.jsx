import React from "react";
import ReactHtmlParser from 'react-html-parser';
import { Chat } from "@empirica/chat";
import ChatLog from "./ChatLog";
import Timer from "./Timer.jsx";
import {gameTexts} from './gameTexts.js';

export default class PlayerProfile extends React.Component {

  constructor(props) {
    super(props);
    const { round, player } = this.props;
    this.updateChat = this.updateChat.bind(this);

    round.append("chat", {
      text: null,
      playerId: player._id,
      target: round.get('target'),
      role: player.get('role'),
      type: "alert"
    });
  }
  

  updateChat(msg) {

    const { stage, round, player } = this.props;
    let chatLog = round.get('chatLog') || new Array();
    msg['stage'] = round.get('stage');
    chatLog.push(msg)
    console.log(chatLog)
    round.set('chatLog', chatLog)
    return(msg)

  }

  render() {
    const { stage, round, player, game } = this.props;
    const gameTextsLanguage = game.treatment.gameLanguage;

    const messages = round.get("chat")
          .map(({ text, playerId, type }) => ({
            text,
            subject: game.players.find(p => p._id === playerId),
            type : type
          }));

    // const timer = round.get('stage') === "feedback" ? <Timer stage={stage} round={round} /> : null

    const roleNameText = player.get('role') === "listener" ? gameTexts[gameTextsLanguage].PLAYERPROFILE_youAreGuesser : gameTexts[gameTextsLanguage].PLAYERPROFILE_youAreDirector

    return (
      <aside className="player-profile">
        <div style = {{align: 'center'}}> <h4> {ReactHtmlParser(roleNameText)} </h4></div>
        <div style = {{overflow: "scroll", height: '200px', border: '1px solid #333333'}}>
        {/* <Chat player={player} scope={round} customKey="gameChat" onNewMessage={this.updateChat} /> */}
        <ChatLog messages={messages} game={game} round={round} stage={stage} player={player} />
        </div>
        {/*{timer}*/}

      </aside>
    );
  }
}


