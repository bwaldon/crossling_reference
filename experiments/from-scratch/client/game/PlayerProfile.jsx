import React from "react";
import ReactHtmlParser from 'react-html-parser';
import { Chat } from "@empirica/chat";
import Timer from "./Timer.jsx";
import {gameTexts, gameTextsLanguage} from './gameTexts.js';

export default class PlayerProfile extends React.Component {

  constructor(props) {
    super(props);
    const { round } = this.props;
    this.updateChat = this.updateChat.bind(this)
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
    const { stage, round, player } = this.props;

    // const timer = round.get('stage') === "feedback" ? <Timer stage={stage} round={round} /> : null

    const roleNameText = player.get('role') === "listener" ? gameTexts[gameTextsLanguage].PLAYERPROFILE_youAreGuesser : gameTexts[gameTextsLanguage].PLAYERPROFILE_youAreDirector

    return (
      <aside className="player-profile">
        <div style = {{align: 'center'}}> <h4> {ReactHtmlParser(roleNameText)} </h4></div>
        <div style = {{overflow: "scroll", height: '200px', border: '1px solid #333333'}}>
        <Chat player={player} scope={round} 
        customKey="gameChat" onNewMessage={this.updateChat} />
        </div>
        {/*{timer}*/}

      </aside>
    );
  }
}


