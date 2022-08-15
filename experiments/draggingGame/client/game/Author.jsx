import React from "react";
import { gameText } from "../gameText.js";

export default class Author extends React.Component {
  render() {
    const { gameLanguage, player, self, type } = this.props;
    const you = gameText.filter(row => row.language == gameLanguage)[0].CHAT_You

    if(type == "message") {
      return (
      <div className="author">
        <span className="name" style={{ color: player.get("nameColor") }}>
          {self ? you : player.get("name")}:
        </span>
      </div>
      );
    } else {

        return null;
    }
  }
}