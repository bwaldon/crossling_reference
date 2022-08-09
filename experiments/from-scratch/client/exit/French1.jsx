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

export default class ExitSurveyLangSpecific extends React.Component {
	static stepName = "ExitSurveyLangSpecific";

	state = {
		primaryLanguageAtHome: "",
		otherPrimaryLanguages: "",
		otherPrimaryLanguagesSpecify: "",
		whenLanguageLearned: "",
		livedInCountry: "",
		howManyYears: "",
		languageMostFrequentHome: "",
		languageMostFrequentOutside: "",
		region: "",
		relationship: "",
		relationshipOther: "",
		familiarityRate: ""
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
			primaryLanguageAtHome,
			otherPrimaryLanguages,
			otherPrimaryLanguagesSpecify,
			whenLanguageLearned,
			livedInCountry,
			howManyYears,
			languageMostFrequentHome,
			languageMostFrequentOutside,
			region,
			relationship,
			relationshipOther,
			familiarityRate
		} = this.state;

		const { game } = this.props;

		const gameTextInLanguage = gameText.filter(
			(row) => row.language == game.treatment.gameLanguage
		)[0];

		const primaryLanguageAtHomeOptions = {
			yes: gameTextInLanguage.SURVEY_yesPrimaryLanguageAtHome,
			no: gameTextInLanguage.SURVEY_noPrimaryLanguageAtHome,
		};

		const otherPrimaryLanguagesOptions = {
			yes: gameTextInLanguage.SURVEY_yesOtherPrimaryLanguages,
			no: gameTextInLanguage.SURVEY_noOtherPrimaryLanguages,
		};

		const whenLanguageLearnedOptions = {
			firstLanguageStillDominant:
				gameTextInLanguage.SURVEY_firstLanguageStillDominant,
			firstLanguageNotDominant:
				gameTextInLanguage.SURVEY_firstLanguageNotDominant,
			notFirstLanguage: gameTextInLanguage.SURVEY_notFirstLanguage,
		};

		const livedInCountryOptions = {
			never: gameTextInLanguage.SURVEY_never,
			before8: gameTextInLanguage.SURVEY_before8,
			beforeAfter8: gameTextInLanguage.SURVEY_beforeAfter8,
			after8: gameTextInLanguage.SURVEY_after8,
		};
		const howManyYearsOptions = {
			lessThan1Year: gameTextInLanguage.SURVEY_lessThan1Year,
			oneTo5Years: gameTextInLanguage.SURVEY_1To5Years,
			moreThan5Years: gameTextInLanguage.SURVEY_moreThan5Years,
		};
		const languageMostFrequentHomeOptions = {
			targetLanguage: gameTextInLanguage.SURVEY_targetLanguage,
			otherLanguage: gameTextInLanguage.SURVEY_otherLanguage,
		};
		const languageMostFrequentOutsideOptions = {
			targetLanguage: gameTextInLanguage.SURVEY_targetLanguage,
			otherLanguage: gameTextInLanguage.SURVEY_otherLanguage,
		};

		const relationshipOptions = {
			closeFriends: "Ami·es proches",
			friends: "Ami·es",
			spouse: "Conjoint·e",
			family: "Membre de famille",
			acquiantance: "Conaissance",
			none: "Je connais pas mon partenaire",
			other: "Autre"
		};

		const familiarityRateOptions = {
			daily: "Quotidiennement",
			severalWeekly: "Plusieurs fois par semaine",
			onceWeekly: "Une fois par semaine",
			severalMonthl: "Plusieurs fois par mois",
			onceMonth: "Une fois par mois",
			rarely: "Rarement",
			never: "Je n'ai jamais parlé à cette personne."
		};

		const regionOptions = {
			FR: "France",
			CA: "Canada",
			AS: "Asie",
			AF: "Afrique",
			SW: "Suisse",
			BE: "Belgique",
			AN: "Antilles/Amérique du Sud",
			OT: "Autre",
		}

		return (
			<div dir="auto">
				<h1>{gameTextInLanguage.SURVEY_line1}</h1>
				<h3>{gameTextInLanguage.SURVEY_line2}</h3>
				<h3>{gameTextInLanguage.SURVEY_line3}</h3>
				<div className="pt-form-group">
					<br></br>
					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_primaryLanguageAtHome +
									" "}
							</b>
							<HTMLSelect
								name="primaryLanguageAtHome"
								id="primaryLanguageAtHome"
								onChange={this.handleChange}
								value={primaryLanguageAtHome}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									primaryLanguageAtHomeOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>
						</div>{" "}
					</div>

					<br></br>
					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_otherPrimaryLanguages +
									" "}
							</b>
							<HTMLSelect
								name="otherPrimaryLanguages"
								id="otherPrimaryLanguages"
								onChange={this.handleChange}
								value={otherPrimaryLanguages}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									otherPrimaryLanguagesOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>

							<label htmlFor="otherPrimaryLanguagesSpecify">
								<b>
									{" " +
										gameTextInLanguage.SURVEY_specifyOtherPrimaryLanguages +
										" "}
								</b>
							</label>
							<input
								id="otherPrimaryLanguagesSpecify"
								type="text"
								dir="auto"
								name="otherPrimaryLanguagesSpecify"
								value={otherPrimaryLanguagesSpecify}
								onChange={this.handleChange}
								autoComplete="off"
							/>
						</div>{" "}
					</div>
					<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_whenLanguageLearned +
									" "}
							</b>
							<HTMLSelect
								name="whenLanguageLearned"
								id="whenLanguageLearned"
								onChange={this.handleChange}
								value={whenLanguageLearned}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									whenLanguageLearnedOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>
						</div>{" "}
					</div>

					<br></br>
					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_livedInCountry + " "}
							</b>
							<HTMLSelect
								name="livedInCountry"
								id="livedInCountry"
								onChange={this.handleChange}
								value={livedInCountry}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(livedInCountryOptions, (name, key) => (
									<option key={key} value={key}>
										{name}
									</option>
								))}
							</HTMLSelect>
						</div>
					</div>

					<br></br>
					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_howManyYears + " "}
							</b>
							<HTMLSelect
								name="howManyYears"
								id="howManyYears"
								onChange={this.handleChange}
								value={howManyYears}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(howManyYearsOptions, (name, key) => (
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
								{gameTextInLanguage.SURVEY_languageMostFrequentHome +
									" "}
							</b>
							<HTMLSelect
								name="languageMostFrequentHome"
								id="languageMostFrequentHome"
								onChange={this.handleChange}
								value={languageMostFrequentHome}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									languageMostFrequentHomeOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>
						</div>{" "}
					</div>
					<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{gameTextInLanguage.SURVEY_languageMostFrequentOutside +
									" "}
							</b>
							<HTMLSelect
								name="languageMostFrequentOutside"
								id="languageMostFrequentOutside"
								onChange={this.handleChange}
								value={languageMostFrequentOutside}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									languageMostFrequentOutsideOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}

							</HTMLSelect>
						</div>{" "}
					</div>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{"Dans quelle région francophone avez-vous vécu le plus longtemps ou quelle région avez-vous visité le plus souvent? Si vous n\\'avez jamais visité une région francophone, à quelle région francophone vous identifiez-vous le plus?"}
							</b>
							<HTMLSelect
								name="region"
								id="region"
								onChange={this.handleChange}
								value={relationship}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									regionOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>
							</div>
						</div>
						<br></br>

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{"Comment décririez-vous votre relation avec votre parteinaire:"}
							</b>
							<HTMLSelect
								name="relationship"
								id="relationship"
								onChange={this.handleChange}
								value={relationship}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									relationshipOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>
						</div>
						<br></br>
						<div className="form-line">
							<div>
								<label htmlFor="relationshipOther">
									<b>	Si vous avez répondu Autre, veuillez préciser:</b>
								</label>
								<input
									id="relationshipOther"
									type="text"
									dir="auto"
									name="relationshipOther"
									value={relationshipOther}
									onChange={this.handleChange}
									autoComplete="off"
								/>
							</div>
						</div>
						<br></br>
						<div className="pt-form-content">
							<b>
								{"A quelle fréquence parlez-vous avec votre partenaire?"}
							</b>
							<HTMLSelect
								name="familiarityRate"
								id="familiarityRate"
								onChange={this.handleChange}
								value={familiarityRate}
							>
								<option selected>
									{gameTextInLanguage.SURVEY_selectOption}
								</option>
								{_.map(
									familiarityRateOptions,
									(name, key) => (
										<option key={key} value={key}>
											{name}
										</option>
									)
								)}
							</HTMLSelect>
						</div>
						<br></br>
					</div>

				</div>

				<form onSubmit={this.handleSubmit}>
					<span> </span>
					<div>
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
