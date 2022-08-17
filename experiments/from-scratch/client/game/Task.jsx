import React from "react";
import Image from "./Image.jsx";
import Image_var from "./Image_var.jsx"
import { AlertToaster } from "meteor/empirica:core";
import { gameText } from "../gameText.js";

export default class Task extends React.Component {

	render() {
		const { round, player } = this.props;
		const TaskView = player.get('role') == 'listener' ? <ListenerTask {...this.props} /> : <SpeakerTask {...this.props} />;
		return (
			<div className="task">
			{TaskView}
			</div>
			);
	}

}

class ListenerTask extends React.Component {

	constructor(props) {
		super(props);
		const { round } = this.props;
		this.state = { selected: "NONE" };
		round.set("listenerSelection", this.state.selected)
		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
		this.images = round.get("listenerImages");
		this.imageType = round.get("imageType");
	}

	// handle the click anywhere to proceed after selection

	handleClick = event => {
		const { round } = this.props;
		if (round.get('stage') === "feedback") {
			this.props.player.stage.submit();
			document.removeEventListener('click', this.handleClick, true);
		}
    }

    // handle the submit button

	handleSubmit(e) {
		e.preventDefault();
		const { round, stage, game } = this.props;
    	const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

		if(round.get('stage') !== "feedback" & this.state.selected === "NONE"){
			AlertToaster.show({
       		 message:
				gameTextInLanguage.TASK_pleaseMakeSelection
      		});
			return
		} else if (round.get('stage') === "selection") {
			round.set("listenerSelection", this.state.selected)
			round.set('stage', 'feedback')
			document.addEventListener('click', this.handleClick, true);
		}

	};

	// handle a click on an image during selection

	handleChange(e) {
		const { round, stage, game } = this.props;
    	const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

		const chatLog = round.get('chat'); // || new Array();
		// Filter on only speaker messages

		const filteredLog = chatLog.filter((msg) => msg.name === gameTextInLanguage.PLAYERPROFILE_director);
		if (round.get('stage') === "selection" & filteredLog.length === 0) {
			AlertToaster.show({
       		 message:
				gameTextInLanguage.TASK_partnerHasToSaySomething
      		});
			return
		} else if (round.get('stage') === "selection") {
			this.setState({ selected: e.target.id });
		} else {

		}

	};

	render() {

		const { round, stage, player, game } = this.props;
    	const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

		let button;
		let feedbackMessage;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false
		if (round.get('stage') === "feedback") {
			if (listenerSelection == "NONE") {
			feedbackMessage = gameTextInLanguage.TASK_youDidntSelectImage
		} else if(!(correct)){
			feedbackMessage = gameTextInLanguage.TASK_youSelectedWrongImage
		} else {
			feedbackMessage = gameTextInLanguage.TASK_youSelectedCorrectImage
			}
		} else {
			button = <button onClick={this.handleSubmit}>{gameTextInLanguage.TASK_submitButtonText}</button>
		}

		const images = this.images.map((image,) => {
			let path = ""
			if (game.treatment.sceneGenerator != "French1" && game.treatment.sceneGenerator != "Vietnamese1"){
				path = "images/" + this.imageType + "/" + image.name + ".jpg";
			} else{
				path = "images/pophristic_stimuli/" + image.name + ".jpg";
			}
			let highlighted;
			let borderColor;

			if (round.get('stage') === "feedback") {
				highlighted = listenerSelection == image.id || target.id == image.id ? true : false
				borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green';
			} else {
				highlighted = this.state.selected == image.id ? true : false
				borderColor = "black"
			}
			if (game.treatment.sceneGenerator != "French1" && game.treatment.sceneGenerator != "Vietnamese1"){
				return(<Image image={image} path= {path} onClick = {this.handleChange} borderColor = {borderColor} highlighted = {highlighted} /> )
			} else {// variable sizes for images
				return(<Image_var image={image} path= {path} onClick = {this.handleChange} borderColor = {borderColor} highlighted = {highlighted} /> )
			}
		})

		return (
			<div className="task-stimulus">
				<table>
				<tr align ="center">
				{images.slice(0,images.length/2)}
				</tr>
				<tr align ="center">
				{images.slice(images.length/2,)}
				</tr>
				<tr align="center">
				<td colspan="5">
				{button}
				</td>
				</tr>
				<tr>
				<td align ="center" colspan="5">
				<h4> {feedbackMessage} </h4>
				<i> {round.get('stage') == 'feedback' ? gameTextInLanguage.TASK_clickAnywhereToAdvance : ""} </i>
				</td>
				</tr>
				</table>
			</div>
			);
	}
}

class SpeakerTask extends React.Component {

	componentDidMount() {
		this.props.player.stage.submit();
	}

	constructor(props) {
		super(props);
		const { round } = this.props;
		this.images = round.get("speakerImages");
		this.imageType = round.get("imageType");
	}

	render() {

		const { round, stage, player, game } = this.props;
    	const gameTextInLanguage = gameText.filter(row => row.language == game.treatment.gameLanguage)[0]

		let feedbackMessage;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false
		if (round.get('stage') === "feedback") {
		if (listenerSelection == "NONE") {
			feedbackMessage = gameTextInLanguage.TASK_partnerDidntSelectImage
		} else if(!(correct)){
			feedbackMessage = gameTextInLanguage.TASK_partnerSelectedWrongImage
		} else {
			feedbackMessage = gameTextInLanguage.TASK_partnerSelectedCorrectImage
			}
		}

		const images = this.images.map((image,) => {
			let path = ""
			console.log(image)
			if (game.treatment.sceneGenerator != "French1" && game.treatment.sceneGenerator != "Vietnamese1"){
				path = "images/" + this.imageType + "/" + image.name + ".jpg";
			} else{
				path = "images/pophristic_stimuli/" + image.name + ".jpg";
			}
			console.log(path)
			let highlighted;
			let borderColor;
			if (round.get('stage') === "feedback") {
				highlighted = listenerSelection == image.id || target.id == image.id ? true : false
				borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green'
			} else if (round.get('stage') === "selection") {
				highlighted = target.id === image.id ? true : false
				borderColor = 'black'
			}
			if (game.treatment.sceneGenerator != "French1" && game.treatment.sceneGenerator != "Vietnamese1"){
				return(<Image image={image} path= {path} onClick = {this.handleChange} borderColor = {borderColor} highlighted = {highlighted} /> )
			} else {
				return(<Image_var image={image} path= {path} onClick = {this.handleChange} borderColor = {borderColor} highlighted = {highlighted} /> )
			}
		})

		return (
			<div className="task-stimulus">
				<table>
				<tr align ="center">
				{images.slice(0,images.length/2)}
				</tr>
				<tr align ="center">
				{images.slice(images.length/2)}
				</tr>
				<tr>
				<td colspan="5" align = "center">
				<h4>{feedbackMessage}</h4>
				<i> {round.get('stage') == 'feedback' ? gameTextInLanguage.TASK_waitForPartnerToClickAnywhere : ""} </i>
				</td>
				</tr>
				</table>
			</div>
			);

	}

}
