import React from 'react'
import { NonDraggableBox } from './NonDraggableBox.js'

const styles = {
  width: 300,
  height: 300,
  border: '1px solid black',
  position: 'relative',
}

export default class SpeakerView extends React.Component {

      render() {
        const { round } = this.props;
        const left = round.get("left")
        const top = round.get("top")
        return (
            <div style={styles}>
                <NonDraggableBox id={123} round = {round} top = {top} left = {left} title={"Drag me around"} />
            </div>
          );
      }

}