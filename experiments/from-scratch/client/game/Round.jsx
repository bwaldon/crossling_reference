import React from "react";
import PlayerProfile from "./PlayerProfile.jsx";
import SocialExposure from "./SocialExposure.jsx";
import Task from "./Task.jsx";
import {gameTexts} from './gameTexts.js'

export default class Round extends React.Component {

  componentDidMount() {
    const { player, game } = this.props;
    const gameTextsLanguage = game.treatment.gameLanguage
    
    player.get('role') === "listener" ? player.set('name', gameTexts[gameTextsLanguage].PLAYERPROFILE_guesser) : player.set('name', gameTexts[gameTextsLanguage].PLAYERPROFILE_director) 
  }

  render() {
    const { round, stage, player, game } = this.props;
    const gameTextsLanguage = game.treatment.gameLanguage;

    const view = <Task game={game} round={round} stage={stage} player={player} />
    return (
      <div className="round">
    
        <div className="content" style = {{alignItems: 'center'}} >

          <PlayerProfile player={player} stage={stage} game={game} round = {round} />

          <div className = "view" style = {{display: 'inline-block'}}> {view} </div>

        </div>
      </div>
    );
  }
}

