import React from "react";

export default class Image extends React.Component {
//width=100%
	render() {
		console.log(this.props)
		const borderWidth = this.props.highlighted ? '5px' : '0px'

		return(
			<td colspan= "2" style = {{width: "200px", height: "200px", border:
			borderWidth + " solid " + this.props.borderColor,
			padding: '10px'}}>

			<img id = {this.props.image.id} src = {this.props.path}
				onClick = {this.props.onClick}
				style = {{display: "block", "max-height": "100%", "max-width":"100%", "marginLeft": "auto", "marginRight": "auto"}} />
			</td>
			)

	}

}
