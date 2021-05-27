import React from "react";

export default class Image extends React.Component {

	render() {

		const borderWidth = this.props.highlighted ? '5px' : '0px'

		return(
			<td style = {{width: "200px", height: "200px", border: 
			borderWidth + " solid " + this.props.borderColor, 
			padding: '10px'}}>
			<img id = {this.props.image.id} src = {this.props.path} 
				onClick = {this.props.onClick}
				style = {{display: "block", width: "100%", "marginLeft": "auto", "marginRight": "auto"}} />
			</td>
			)	

	}

}
