import React from "react";

export default class Image extends React.Component {

	render() {

		const borderWidth = this.props.highlighted ? '5px' : '0px'

		return(
			<img id = {this.props.image.id} src = {this.props.path} 
				onClick = {this.props.onClick}
				style = {{width: '150px', height: 'auto', border: borderWidth + " solid " + this.props.borderColor, padding: '10px'}} />
			)

	}


}