import React from "react";

export default class Image_var extends React.Component {
//width=100%
	render() {
		console.log("var: "+this.props)
		const borderWidth = this.props.highlighted ? '5px' : '0px'
		const sizePercent = this.props.image.size =="big" ? "100%" : "50%"
		return(
			<td style = {{width: "400px", height: "300px", border:
			borderWidth + " solid " + this.props.borderColor,
			padding: '10px'}}>

			<img id = {this.props.image.id} src = {this.props.path}
				onClick = {this.props.onClick}
				style = {{display: "block", "max-height": sizePercent, "max-width": sizePercent, "marginLeft": "0px", "marginRight": "0px"}} />
			</td>
			)

	}

}
