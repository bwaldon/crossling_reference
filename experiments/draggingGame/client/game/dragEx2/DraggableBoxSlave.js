import React from 'react'
import { memo, useEffect } from 'react'
import Round from '../Round.jsx'
import { Box } from './Box.js'

function getStyles(left, top, isDragging) {
  const transform = `translate3d(${left}px, ${top}px, 0)`
  return {
    position: 'absolute',
    transform,
    WebkitTransform: transform,
    // IE fallback: hide the real node using CSS when dragging
    // because IE will ignore our custom "empty image" drag preview.
    opacity: isDragging ? 0 : 1,
    height: isDragging ? 0 : '',
  }
}
export const DraggableBoxSlave = memo(function DraggableBoxSlave(props) {
  const { id, title, left, top } = props
  return (
    <div
      style={getStyles(left, top, false)}
      role="DraggableBox"
    >
      <Box title={title} />
    </div>
  )
})
