import React from "react";
import Image from "./Image.jsx";

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
		const { round } = this.props;

		if(this.state.selected === "NONE"){
			round.set('error',"Please make a selection before proceeding!")
			return
		} else {
			round.set("listenerSelection", this.state.selected)
			this.props.player.stage.submit();
		}

	};

	handleChange(e) {
		const { round } = this.props;

		const chatLog = round.get('chatLog') || new Array();
		// Filter on only speaker messages
		const filteredLog = chatLog.filter((msg) => msg.player.name === "Speaker");
		if (filteredLog.length === 0) {
			round.set('error',"Your partner has to say something before you can select an image!")
			return
		} else {
			this.setState({ selected: e.target.id });
		}	
	};

	render() {

		const { round, stage, player } = this.props;
		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";
			const highlighted = this.state.selected == image.id ? true : false
			return(<Image image={image} path= {path} onClick = {this.handleChange} borderColor = 'green' highlighted = {highlighted} /> )})
		
		return (
			<div className="task-stimulus">
				<table>
				<tr>
				{images}
				</tr>
				<tr>
				<td align="center">
				<button onClick={this.handleSubmit}>Submit</button>
				</td>
				</tr>
				<tr>
				<td align ="center">
				<h4> {round.get('error')} </h4>
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
		this.props.player.stage.submit()
	}

	constructor(props) {
		super(props);
		const { round } = this.props;
		this.images = round.get("speakerImages")
	}

	render() {

		const { round, stage, player } = this.props;
		const images = this.images.map((image,) => { 
			let path = "images/" + image.name + ".jpg";
			const highlighted = round.get("target").id === image.id ? true : false
			return(<Image image={image} path= {path} borderColor = 'black' highlighted = {highlighted} /> )})
		
		return (
			<div className="task-stimulus">		
				<table>
				<tr>
				{images}
				</tr>
				</table>
			</div>
			);

	}

}