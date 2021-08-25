import React from "react";
import SocialInteractions from "./SocialInteractions.jsx";
import Task from "./Task.jsx";
import { gameText } from "../gameText.js";

export default class Round extends React.Component {

  componentDidMount() {
    const { player, game } = this.props;
    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]
    
    player.get('role') === "listener" ? player.set('name', gameTextInLanguage.PLAYERPROFILE_guesser) : player.set('name', gameTextInLanguage.PLAYERPROFILE_director) 
  }

  render() {
    const { round, stage, player, game } = this.props;
    const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

    const view = <Task game={game} round={round} stage={stage} player={player} />

    return (
      <div className="round">
    
        <div className="content" >

          <SocialInteractions player={player} stage={stage} game={game} round = {round} /> <div className = "view"> {view} </div>

        </div>
      </div>
    );
  }
}

