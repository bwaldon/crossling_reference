import React from "react";
import Author from "./Author";
import { gameText } from "../gameText.js";

export default class ChatLog extends React.Component {
  state = { comment: "" };

  
  handleChange = e => {
    const el = e.currentTarget;
    this.setState({ [el.name]: el.value });
  };

  handleSubmit = e => {
    e.preventDefault();
    const text = this.state.comment.trim();
    if (text !== "") {
      const { round, player } = this.props;
      const room = player.get('roomId')
      round.append("chat", {
        text,
        playerId: player._id,
        target: round.get('target'),
        role: player.get('role'),
        name: player.get('name'),
        type: "message",
        time: Date.now()
      });
      console.log(round.get("chat"));
      this.setState({ comment: "" });
    }
  };

  render() {
    const { comment } = this.state;
    const { messages, player, game } = this.props;

    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

    return (
      <div className="chat bp3-card">
        <Messages game={game} messages={messages} player={player} />
        <form onSubmit={this.handleSubmit}>
          <div className="bp3-control-group">
            <input
              name="comment"
              type="text"
              className="bp3-input bp3-fill"
              placeholder={gameTextInLanguage.CHAT_EnterChatMessagePlaceholder}
              value={comment}
              onChange={this.handleChange}
              autoComplete="off"
            />
            <button type="submit" className="bp3-button bp3-intent-primary">
              {gameTextInLanguage.CHAT_SendButtonText}
            </button>
          </div>
        </form>
      </div>
    );
  }
}

class Messages extends React.Component {
  componentDidMount() {
    this.messagesEl.scrollTop = this.messagesEl.scrollHeight;
  }
  
  componentDidUpdate(prevProps) {
    if (prevProps.messages.length < this.props.messages.length) {
      this.messagesEl.scrollTop = this.messagesEl.scrollHeight;
    }
  }

  render() {
    const { messages, player, game } = this.props;

    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

    return (
      <div className="messages" ref={el => (this.messagesEl = el)}>
        {messages.length === 0 ? (
          <div className="empty">{gameTextInLanguage.CHAT_NoMessagesYet}</div>
        ) : null}
        {messages.map((message, i) => (
           <Message gameLanguage={game.treatment.gameLanguage} key={i} message={message} self={message.subject ? player._id === message.subject._id : null} />   
        ))}
      </div>
    );
  }
}

class Message extends React.Component {
  render() {
    const { text, subject, type } = this.props.message;
    const { self } = this.props;
    return (
      <div className="message">
        <Author gameLanguage={this.props.gameLanguage} player={subject} self={self} type = {type} /> {text}
      </div>
    );
  }
}


