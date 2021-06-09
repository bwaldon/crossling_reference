import React from "react";
import {chatTexts} from './chatTexts.js';

export default class Author extends React.Component {
  render() {
    const { gameLanguage, player, self, type } = this.props;
    const you = chatTexts[gameLanguage].You;

    if(type == "message") {
      return (
      <div className="author">
        <img src={player.get("avatar")} style={{width: 40}} />
        <span className="name" style={{ color: player.get("nameColor") }}>
          {self ? you : player.get("name")}
        </span>
      </div>
      );
    } else {

        return null;
    }
  }
}