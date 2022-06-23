import React from "react";
import { gameText } from "../gameText.js";

import { Centered } from "meteor/empirica:core";

import {
	Button,
	Classes,
	FormGroup,
	RadioGroup,
	HTMLSelect,
	TextArea,
	Intent,
	Radio,
	Checkbox,
} from "@blueprintjs/core";

export default class ExitSurvey extends React.Component {
	static stepName = "ExitSurvey";

	state = {
		age: "",
		gender: "",
		language: "",
		education: "",
		correctness: "",
		workedWell: "",
		fair: "",
		chatUseful: "",
		feedback: "",
		colorblind: "",
		robot: "",
		keyboardLanguage: "",
		keyboardComfort: "",
	};

	handleChange = (event) => {
		const el = event.currentTarget;
		this.setState({ [el.name]: el.value });
	};

	handleEnabledChange = (event) => {
		const el = event.currentTarget;
		this.setState({ [el.name]: !this.state[el.name] });
	};
	handleSubmit = (event) => {
		event.preventDefault();
		console.log(this.state);
		this.props.onSubmit(this.state);
	};

	exitForm = () => {
		const {
			age,
			gender,
			language,
			education,
			correctness,
			workedWell,
			fair,
			chatUseful,
			feedback,
			colorblind,
			robot,
			keyboardLanguage,
			keyboardComfort
		} = this.state;

		const { game } = this.props;

		const gameTextInLanguage = gameText.filter(
			(row) => row.language == game.treatment.gameLanguage
		)[0];

		const educationOptions = {
			lessHighSchool: gameTextInLanguage.SURVEY_lessHighSchool,
			highSchool: gameTextInLanguage.SURVEY_highSchool,
			someCollege: gameTextInLanguage.SURVEY_someCollege,
			undergrad: gameTextInLanguage.SURVEY_undergrad,
			graduate: gameTextInLanguage.SURVEY_graduate,
		};

		const correctnessOptions = {
			yes: gameTextInLanguage.SURVEY_yesFollowedInstructions,
			no: gameTextInLanguage.SURVEY_noFollowedInstructions,
		};
 		const workedWellOptions = {
			stronglyAgree: gameTextInLanguage.SURVEY_stronglyAgree,
			agree: gameTextInLanguage.SURVEY_agree,
			neutral: gameTextInLanguage.SURVEY_neutral,
			disagree: gameTextInLanguage.SURVEY_disagree,
			stronglyDisagree: gameTextInLanguage.SURVEY_stronglyDisagree,
		};

		const robotOptions = {
			yes: gameTextInLanguage.SURVEY_yesBelievePartnerWasHuman,
			no: gameTextInLanguage.SURVEY_noBelievePartnerWasHuman,
		};

		const keyboardLanguageOptions = {
			keyboardInTargetLanguage:
				gameTextInLanguage.SURVEY_keyboardInTargetLanguage,
			keyboardInOtherLanguage:
				gameTextInLanguage.SURVEY_keyboardInOtherLanguage,
			didntType: gameTextInLanguage.SURVEY_keyboardDidntType,
		};

		const keyboardComfortOptions = {
			keyboardAllTheTime: gameTextInLanguage.SURVEY_keyboardAllTheTime,
			keyboardSometimes: gameTextInLanguage.SURVEY_keyboardSometimes,
			keyboardRarely: gameTextInLanguage.SURVEY_keyboardRarely,
		};


		return (
			<div dir="auto">
				<h1>{gameTextInLanguage.SURVEY_line1}</h1>
				<h3>{gameTextInLanguage.SURVEY_line2}</h3>
				<h3>{gameTextInLanguage.SURVEY_line3}</h3>

				<form onSubmit={this.handleSubmit}>
					<span> </span>

					<div className="form-line">
						<div>
							<label htmlFor="age">
								<b>{gameTextInLanguage.SURVEY_age + " "}</b>
							</label>
							<input
								id="age"
								type="number"
								min="0"
								max="150"
								step="1"
								name="age"
								value={age}
								onChange={this.handleChange}
							/>
						</div>
					</div>
					<br></br>

					<div className="form-line">
						<div>
							<label htmlFor="gender">
								<b>{gameTextInLanguage.SURVEY_gender + " "}</b>
							</label>
							<input
								id="gender"
								type="text"
								dir="auto"
								name="gender"
								value={gender}
								onChange={this.handleChange}
								autoComplete="off"
							/>
						</div>
					</div>
					<br></br>

					<div className="form-line">
						<div>
							<label htmlFor="language">
								<b>
									{gameTextInLanguage.SURVEY_nativeLanguages +
										" "}
								</b>
							</label>
							<input
								id="language"
								type="text"
								dir="auto"
								name="language"
								value={language}
								onChange={this.handleChange}
								autoComplete="off"
							/>
						</div>
					</div>
					<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_highestLevelOfEducation +
									" "}
							</b>
							<HTMLSelect
								name="education"
								id="education"
								onChange={this.handleChange}
								value={education}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(educationOptions, (name, key) => (
									<option key={key} value={key}>
										{name}
									</option>
								))}
							</HTMLSelect>
						</div>
					</div>{" "}

					<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_followedInstructions +
									" "}
							</b>
							<HTMLSelect
								name="correctness"
								id="correctness"
								onChange={this.handleChange}
								value={correctness}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(correctnessOptions, (name, key) => (
									<option key={key} value={key}>
										{name}
									</option>
								))}
							</HTMLSelect>
						</div>
					</div>{" "}
					<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_workedWellWithPartner +
									" "}
							</b>
							<HTMLSelect
								name="workedWell"
								id="workedWell"
								onChange={this.handleChange}
								value={workedWell}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(workedWellOptions, (name, key) => (
									<option key={key} value={key}>
										{name}
									</option>
								))}
							</HTMLSelect>
						</div>
					</div>{" "}
					<br></br>

					<div className="form-line thirds">
						<FormGroup
							className={"form-group"}
							inline={false}
							label={
								<b>
									{gameTextInLanguage.SURVEY_payWasFair}
								</b>
							}
							labelFor={"fair"}
						>
							<TextArea
								id="fair"
								name="fair"
								large={true}
								intent={Intent.PRIMARY}
								onChange={this.handleChange}
								value={fair}
								fill={true}
							/>
						</FormGroup>
					</div>

					<div className="form-line thirds">
						<FormGroup
							className={"form-group"}
							inline={false}
							label={
								<b>
									{
										gameTextInLanguage.SURVEY_inGameChatEasyToUse
									}
								</b>
							}
							labelFor={"chatUseful"}
						>
							<TextArea
								id="chatUseful"
								name="chatUseful"
								large={true}
								intent={Intent.PRIMARY}
								onChange={this.handleChange}
								value={chatUseful}
								fill={true}
							/>
						</FormGroup>
					</div>

					<div className="form-line thirds">
						<FormGroup
							className={"form-group"}
							inline={false}
							label={
								<b>
									{gameTextInLanguage.SURVEY_colorblind}
								</b>
							}
							labelFor={"colorblind"}
						>
							<TextArea
								id="colorblind"
								name="colorblind"
								large={true}
								intent={Intent.PRIMARY}
								onChange={this.handleChange}
								value={colorblind}
								fill={true}
							/>
						</FormGroup>
					</div>

					<div className="form-line thirds">
						<FormGroup
							className={"form-group"}
							inline={false}
							label={
								<b>
									{
										gameTextInLanguage.SURVEY_problemsOrComments
									}
								</b>
							}
							labelFor={"feedback"}
						>
							<TextArea
								id="feedback"
								name="feedback"
								large={true}
								intent={Intent.PRIMARY}
								onChange={this.handleChange}
								value={feedback}
								fill={true}
							/>
						</FormGroup>
					</div>
					<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_believePartnerWasHuman +
									" "}
							</b>
							<HTMLSelect
								name="robot"
								id="robot"
								onChange={this.handleChange}
								value={robot}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(robotOptions, (name, key) => (
									<option key={key} value={key}>
										{name}
									</option>
								))}
							</HTMLSelect>
						</div>{" "}
					</div>

					<div>
						<br></br>

						<div className="pt-form-group">
							<div className="pt-form-content">
								<b>
									{gameTextInLanguage.SURVEY_keyboardLanguage +
										" "}
								</b>
								<HTMLSelect
									name="keyboardLanguage"
									id="keyboardLanguage"
									onChange={this.handleChange}
									value={keyboardLanguage}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(keyboardLanguageOptions, (name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									))}
								</HTMLSelect>
							</div>{" "}
						</div>
						<br></br>

						<div className="pt-form-group">
							<div className="pt-form-content">
								<b>
									{gameTextInLanguage.SURVEY_keyboardComfort +
										" "}
								</b>
								<HTMLSelect
									name="keyboardComfort"
									id="keyboardComfort"
									onChange={this.handleChange}
									value={keyboardComfort}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(keyboardComfortOptions, (name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									))}
								</HTMLSelect>
							</div>{" "}
						</div>

						<button
							type="submit"
							className="pt-button pt-intent-primary"
						>
							{gameTextInLanguage.SURVEY_submitButtonText}
							<span className="pt-icon-standard pt-icon-key-enter pt-align-right" />
						</button>
					</div>
				</form>{" "}
			</div>
		);
	};

	componentWillMount() {}

	render() {
		const { player, game } = this.props;
		return (
			<Centered>
				<div className="exit-survey">{this.exitForm()}</div>
			</Centered>
		);
	}
}
