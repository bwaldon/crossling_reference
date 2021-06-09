import React from "react";
import Image from "./Image.jsx";
import { AlertToaster } from "meteor/empirica:core";
import {gameTexts} from './gameTexts.js'

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
		this.images = round.get("listenerImages")	
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
		const gameTextsLanguage = game.treatment.gameLanguage

		if(round.get('stage') !== "feedback" & this.state.selected === "NONE"){
			AlertToaster.show({
       		 message:
				gameTexts[gameTextsLanguage].TASK_pleaseMakeSelection
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
		const gameTextsLanguage = game.treatment.gameLanguage

		const chatLog = round.get('chatLog') || new Array();
		// Filter on only speaker messages

		const filteredLog = chatLog.filter((msg) => msg.player.name === gameTexts[gameTextsLanguage].PLAYERPROFILE_director);
		if (round.get('stage') === "selection" & filteredLog.length === 0) {
			AlertToaster.show({
       		 message:
				gameTexts[gameTextsLanguage].TASK_partnerHasToSaySomething
      		});
			return
		} else if (round.get('stage') === "selection") {
			this.setState({ selected: e.target.id });
		} else {

		}	

	};

	render() {

		const { round, stage, player, game } = this.props;
		const gameTextsLanguage = game.treatment.gameLanguage;
		
		let button;
		let feedbackMessage;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false	
		if (round.get('stage') === "feedback") {	
			if (listenerSelection == "NONE") {
			feedbackMessage = gameTexts[gameTextsLanguage].TASK_youDidntSelectImage
		} else if(!(correct)){
			feedbackMessage = gameTexts[gameTextsLanguage].TASK_youSelectedWrongImage
		} else {
			feedbackMessage = gameTexts[gameTextsLanguage].TASK_youSelectedCorrectImage
			}
		} else {
			button = <button onClick={this.handleSubmit}>{gameTexts[gameTextsLanguage].TASK_submitButtonText}</button>
		}
		
		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";
			let highlighted;
			let borderColor;
			
			if (round.get('stage') === "feedback") {
				highlighted = listenerSelection == image.id || target.id == image.id ? true : false
				borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green';
			} else {
				highlighted = this.state.selected == image.id ? true : false
				borderColor = "black"
			}
			return(<Image image={image} path= {path} onClick = {this.handleChange} borderColor = {borderColor} highlighted = {highlighted} /> )})
		
		return (
			<div className="task-stimulus">
				<table>
				<tr align ="center">
				{images}
				</tr>
				<tr align="center">
				<td colspan="5">
				{button}
				</td>
				</tr>
				<tr>
				<td align ="center" colspan="5">
				<h4> {feedbackMessage} </h4>
				<i> {round.get('stage') == 'feedback' ? gameTexts[gameTextsLanguage].TASK_clickAnywhereToAdvance : ""} </i>
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
		this.images = round.get("speakerImages")
	}

	render() {

		const { round, stage, player, game } = this.props;
		const gameTextsLanguage = game.treatment.gameLanguage
		
		let feedbackMessage;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false
		if (round.get('stage') === "feedback") {
		if (listenerSelection == "NONE") {
			feedbackMessage = gameTexts[gameTextsLanguage].TASK_partnerDidntSelectImage
		} else if(!(correct)){
			feedbackMessage = gameTexts[gameTextsLanguage].TASK_partnerSelectedWrongImage
		} else {
			feedbackMessage = gameTexts[gameTextsLanguage].TASK_partnerSelectedCorrectImage
			}
		}

		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";
			let highlighted;
			let borderColor;
			if (round.get('stage') === "feedback") {
				highlighted = listenerSelection == image.id || target.id == image.id ? true : false
				borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green'
			} else if (round.get('stage') === "selection") {
				highlighted = target.id === image.id ? true : false
				borderColor = 'black'
			}
			return(<Image image={image} path= {path} borderColor = {borderColor} highlighted = {highlighted} /> )})
		
		return (
			<div className="task-stimulus">		
				<table>
				<tr align ="center">
				{images}
				</tr>
				<tr>
				<td colspan="5" align = "center">
				<h4>{feedbackMessage}</h4>
				<i> {round.get('stage') == 'feedback' ? gameTexts[gameTextsLanguage].TASK_waitForPartnerToClickAnywhere : ""} </i>
				</td>
				</tr>
				</table>
			</div>
			);

	}

}