import React from "react";
import Image from "./Image.jsx";

export default class Feedback extends React.Component {

	constructor(props) {
		super(props);
		const { round, player } = this.props;
		this.images = player.get('role') === 'listener' ? round.get("listenerImages") : round.get("speakerImages")
	}

	render() {

		const { round, stage, player } = this.props;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false
		const role = player.get('role')
		// subject of the feedback message
		const subject = player.get('role') === 'speaker' ? 'Your partner' : 'You'

		let feedbackMessage;

		if (listenerSelection == "NONE") {
			feedbackMessage = subject + " didn't select an image!"
		} else if(!(correct)){
			feedbackMessage = subject + " selected the wrong image!"
		} else {
			feedbackMessage = subject + " selected the correct image!"
		}

		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";

			const highlighted = listenerSelection == image.id || target.id == image.id ? true : false
			const borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green'
			return(<Image image={image} path= {path} borderColor = {borderColor} highlighted = {highlighted} />)})
		
		return (
			<div className = "task">
			<div className="task-stimulus">
				<table>
				<tr align ="center">
				{images}
				</tr>
				<tr>
				<td align ="center" colspan="5">
				<h4> { feedbackMessage } </h4>
				</td>
				</tr>
				</table>
			</div>
			</div>
			);
		
	}
}

