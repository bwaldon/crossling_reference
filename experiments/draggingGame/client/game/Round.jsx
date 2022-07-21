import React from "react";
import SocialInteractions from "./SocialInteractions.jsx";
// import DraggingTask from "./DraggingTask";
// import Example from './example';
import { gameText } from "../gameText.js";
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import SpeakerView from './dragEx2/SpeakerView.js' 
import { ListenerView } from './dragEx2/ListenerView.js' 

export default class Round extends React.Component {
  componentDidMount() {
    const { player, game } = this.props;
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    player.get("role") === "listener"
      ? player.set("name", gameTextInLanguage.PLAYERPROFILE_guesser)
      : player.set("name", gameTextInLanguage.PLAYERPROFILE_director);
  }

  render() {
    const { round, stage, player, game } = this.props;
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    const view = player.get('role') == 'listener' ? <ListenerView round={round}/> : <SpeakerView round={round}/> 

    return (
      <div className="round" dir="auto">
        <div className="content">
          <SocialInteractions
            player={player}
            stage={stage}
            game={game}
            round={round}
          />{" "}
        <DndProvider backend={HTML5Backend}>{view}</DndProvider>
        </div>
      </div>
    );
  }
}
