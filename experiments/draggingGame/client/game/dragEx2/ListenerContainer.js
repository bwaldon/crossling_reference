import React from 'react'
import update from 'immutability-helper'
import { useCallback, useState } from 'react'
import { useDrop } from 'react-dnd'
import { DraggableBoxSlave } from './DraggableBoxSlave.js'
import { ItemTypes } from './ItemTypes.js'
import { snapToGrid as doSnapToGrid } from './snapToGrid.js'

const styles = {
  width: 300,
  height: 300,
  border: '1px solid black',
  position: 'relative',
}

export default class ListenerContainer extends React.Component {

      render() {
        const { round } = this.props;
        const left = round.get("left")
        const top = round.get("top")
    
        return (
            <div style={styles}>
                <DraggableBoxSlave id={123} round = {round} top = {top} left = {left} title={"Drag me around"} />
            </div>
          );
      }

}

// export const ListenerContainer = (props) => {
//     const round = props.round;
//   const [boxes, setBoxes] = useState({
//     a: { top: round.get("top"), left: round.get("left"), title: 'Drag me around' },
//     // b: { top: 180, left: 20, title: 'Drag me too' },
//   })
//   const moveBox = useCallback(
//     (id, left, top) => {
//       setBoxes(
//         update(boxes, {
//           [id]: {
//             $merge: { left, top },
//           },
//         }),
//       )
//     },
//     [boxes],
//   )
//   const [, drop] = useDrop(
//     () => ({
//       accept: ItemTypes.BOX,
//       drop(item, monitor) {
//         const delta = monitor.getDifferenceFromInitialOffset()
//         let left = Math.round(item.left + delta.x)
//         let top = Math.round(item.top + delta.y)
//         if (props.snapToGrid) {
//           ;[left, top] = doSnapToGrid(left, top)
//         }
//         moveBox(item.id, left, top)
//         return undefined
//       },
//     }),
//     [moveBox],
//   )
//   return (
//     <div ref={drop} style={styles}>
//       {Object.keys(boxes).map((key) => (
//         <DraggableBox key={key} id={key} {...boxes[key]} />
//       ))}
//     </div>
//   )
// }
