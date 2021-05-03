import React from "react";
import PlayerProfile from "./PlayerProfile.jsx";
import SocialExposure from "./SocialExposure.jsx";
import Task from "./Task.jsx";
import Feedback from "./Feedback.jsx";

export default class Round extends React.Component {

  componentDidMount() {
    const { player } = this.props;
    player.get('role') === "listener" ? player.set('name', "Guesser") : player.set('name', "Director") 
  }

  render() {
    const { round, stage, player, game } = this.props;
    const view = stage.name === "feedback" ? <Feedback game={game} round={round} stage={stage} player={player} /> : <Task game={game} round={round} stage={stage} player={player} />
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

