import React from 'react'
import update from 'immutability-helper'
import { useCallback, useState } from 'react'
import { useDrop } from 'react-dnd'
import { DraggableBox } from './DraggableBox.js'
import { ItemTypes } from './ItemTypes.js'
import { snapToGrid as doSnapToGrid } from './snapToGrid.js'

const styles = {
  width: 300,
  height: 300,
  border: '1px solid black',
  position: 'relative',
}
export const ListenerContainer = (props) => {
const round = props.round;
  const [boxes, setBoxes] = useState({
    a: { top: 20, left: 80, title: 'Drag me around' },
    // b: { top: 180, left: 20, title: 'Drag me too' },
  })
  const moveBox = useCallback(
    (id, left, top) => {
      setBoxes(
        update(boxes, {
          [id]: {
            $merge: { left, top },
          },
        }),
      )
      round.set("left",left);
      round.set("top",top)
    },
    [boxes],
  )
  const [, drop] = useDrop(
    () => ({
      accept: ItemTypes.BOX,
      drop(item, monitor) {
        const delta = monitor.getDifferenceFromInitialOffset()
        let left = Math.round(item.left + delta.x)
        let top = Math.round(item.top + delta.y)
        if (props.snapToGrid) {
          ;[left, top] = doSnapToGrid(left, top)
        }
        moveBox(item.id, left, top)
        return undefined
      },
    }),
    [moveBox],
  )
  return (
    <div ref={drop} style={styles}>
      {Object.keys(boxes).map((key) => (
        <DraggableBox key={key} id={key} round={round} {...boxes[key]} />
      ))}
    </div>
  )
}
