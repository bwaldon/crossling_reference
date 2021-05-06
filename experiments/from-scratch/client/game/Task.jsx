import React from "react";
import Image from "./Image.jsx";
import { AlertToaster } from "meteor/empirica:core";

export default class Task extends React.Component {

	render() {
		const { round, stage, player } = this.props;
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

	handleSubmit(e) {
		e.preventDefault();
		const { round, stage } = this.props;

		if(stage.name !== "feedback" & this.state.selected === "NONE"){
			AlertToaster.show({
       		 message:
          	"Please make a selection before proceeding!"
      		});
			return
		} else if (stage.name === "response") {
			round.set("listenerSelection", this.state.selected)
			this.props.player.stage.submit();
		}

	};

	handleChange(e) {
		const { round, stage } = this.props;

		const chatLog = round.get('chatLog') || new Array();
		// Filter on only speaker messages
		const filteredLog = chatLog.filter((msg) => msg.player.name === "Director");
		if (stage.name === "response" & filteredLog.length === 0) {
			AlertToaster.show({
       		 message:
          	"Your partner has to say something before you can select an image!"
      		});
			return
		} else if (stage.name === "response") {
			this.setState({ selected: e.target.id });
		} else {

		}	
	};

	render() {

		const { round, stage, player } = this.props;
		let feedbackMessage;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false	
		if (stage.name === "feedback") {	
			if (listenerSelection == "NONE") {
			feedbackMessage = "You didn't select an image!"
		} else if(!(correct)){
			feedbackMessage = "You selected the wrong image!"
		} else {
			feedbackMessage = "You selected the correct image!"
			}
		}
		
		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";
			let highlighted;
			let borderColor;
			if (stage.name === "feedback") {
				highlighted = listenerSelection == image.id || target.id == image.id ? true : false
				borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green'
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
				<button onClick={this.handleSubmit}>Submit</button>
				</td>
				</tr>
				<tr>
				<td align ="center" colspan="5">
				<h4> {feedbackMessage} </h4>
				</td>
				</tr>
				</table>	
			</div>
			);
	}
}

class SpeakerTask extends React.Component {

	// We 'submit' for the speaker upon loading the component, as there's no response to wait for.
	componentDidMount() {
		const { stage } = this.props;
		if(stage.name === "response") {
			this.props.player.stage.submit()
		}
		
	}

	constructor(props) {
		super(props);
		const { round } = this.props;
		this.images = round.get("speakerImages")
	}

	render() {

		const { round, stage, player } = this.props;
		let feedbackMessage;
		const listenerSelection = round.get("listenerSelection")
		const target = round.get("target")
		const correct = listenerSelection == target.id ? true : false
		if (stage.name === "feedback") {	
		if (listenerSelection == "NONE") {
			feedbackMessage = "Your partner didn't select an image!"
		} else if(!(correct)){
			feedbackMessage = "Your partner selected the wrong image!"
		} else {
			feedbackMessage = "Your partner selected the correct image!"
			}
		}

		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";
			let highlighted;
			let borderColor;
			if (stage.name === "feedback") {
				highlighted = listenerSelection == image.id || target.id == image.id ? true : false
				borderColor = !(correct) & image.id == listenerSelection ? 'red' : 'green'
			} else {
				highlighted = round.get("target").id === image.id ? true : false
			}
			return(<Image image={image} path= {path} borderColor = {borderColor} highlighted = {highlighted} /> )})
		
		return (
			<div className="task-stimulus">		
				<table>
				<tr align ="center">
				{images}
				</tr>
				</table>
				<tr>
				<td align ="center" colspan="5">
				<h4> {feedbackMessage} </h4>
				</td>
				</tr>
			</div>
			);

	}

}