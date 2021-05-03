import React from "react";
import { Chat } from "@empirica/chat";
import Timer from "./Timer.jsx";

export default class PlayerProfile extends React.Component {

  constructor(props) {
    super(props);
    const { round } = this.props;
    this.updateChat = this.updateChat.bind(this)
  }
  

  updateChat(msg) {

    const { stage, round, player } = this.props;
    let chatLog = round.get('chatLog') || new Array();
    chatLog.push(msg)
    console.log(chatLog)
    round.set('chatLog', chatLog)
    return(msg)

  }

  render() {
    const { stage, round, player } = this.props;

    const timer = stage.name === "feedback" ? <Timer stage={stage} /> : null

    const roleName = player.get('role') === "listener" ? "guesser" : "director"
    
    return (
      <aside className="player-profile">
        <div style = {{align: 'center'}}> <h4> You are the <u>{roleName}</u>. </h4></div>
        <div style = {{overflow: "scroll", height: '200px', border: '1px solid #333333'}}>
        <Chat player={player} scope={round} 
        customKey="gameChat" onNewMessage={this.updateChat} />
        </div>
        {timer}

      </aside>
    );
  }
}


