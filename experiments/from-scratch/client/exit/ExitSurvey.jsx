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
		raceWhite: "",
		raceBlack: "",
		raceAsian: "",
		raceNative: "",
		raceIslander: "",
		raceHispanic: "",
		education: "",
		correctness: "",
		workedWell: "",
		fair: "",
		chatUseful: "",
		feedback: "",
		colorblind: "",
		robot: "",
		primaryLanguageAtHome: "",
		otherPrimaryLanguages: "",
		otherPrimaryLanguagesSpecify: "",
		whenLanguageLearned: "",
		livedInCountry: "",
		howManyYears: "",
		languageMostFrequentHome: "",
		languageMostFrequentOutside: "",
		keyboardLanguage: "",
		keyboardComfort: "",
		dialectArabic: "",
		dialectArabicSpecify: "",
		spanishVariety: "",
		whereLive: "",
		whereGrowUp: "",
		spanishCommunitySpecify: "",
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
			raceWhite,
			raceBlack,
			raceAsian,
			raceNative,
			raceIslander,
			raceHispanic,
			education,
			correctness,
			workedWell,
			fair,
			chatUseful,
			feedback,
			colorblind,
			robot,
			primaryLanguageAtHome,
			otherPrimaryLanguages,
			otherPrimaryLanguagesSpecify,
			whenLanguageLearned,
			livedInCountry,
			howManyYears,
			languageMostFrequentHome,
			languageMostFrequentOutside,
			keyboardLanguage,
			keyboardComfort,
			dialectArabic,
			dialectArabicSpecify,
			spanishVariety,
			whereLive,
			whereGrowUp,
			spanishCommunitySpecify,
			yugoslavCountryYears,
			yugoslavCountry,
			languageAtHomeBCS,
			otherLanguageAtHomeBCS,
			languageAtSchoolBCS,
			currentOutsideHomeLanguageBCS,
			dialectOneBCS,
			dialectTwoBCS
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
		const dialectArabicOptions = {
			egyptian: "المصرية",
			levantine: "الشامية",
			gulf: "الخليجية",
			maghrebi: "المغربية",
			other: "لهجة مختلفة",
		};

		const yugoslavCountryYearsOptions = {
			never: "Ne, nikada nisam živeo/la u Jugoslaviji/zemlji bivše Jugoslavije.",
			neverButVisited: "Ne, ali sam često posečivao/la Jugoslaviju/zemlju bivše Jugoslavije u detinjstvu.",
			before8: "Da, ali pre nego što sam napunio/la 8 godina.",
			beforeAfter8: "Da, pre i nakon što sam napunio/la 8 godina.",
			after8: "Da, nakon što sam napunio/la 8 godina."
		};

		const dialectOneBCSOptions = {
			ekavica: "Lepo",
			ikavica: "Lipo",
			ijekavica: "Lijepo",
			other: "Nešto drugo"
		};

		const dialectTwoBCSOptions = {
			stakavski: "Što/šta",
			cakavski: "Ča/zač",
			kajkavski: "Kaj",
			other: "Nešto drugo"
		};

		const yugoslavCountryOptions = {
			none: "Nisam živeo/la u zemlji bivše jugoslavije",
			bih: "Bosna i Hercegovina",
			mne: "Crna Gora",
			hr: "Hrvatska",
			mk: "Makedonija",
			si: "Slovenia",
			srb: "Srbija"
		};

		return (
			<div dir="auto">
				{" "}
				<h1>{gameTextInLanguage.SURVEY_line1}</h1>
				<h3>{gameTextInLanguage.SURVEY_line2}</h3>
				<h3>{gameTextInLanguage.SURVEY_line3}</h3>
				<form onSubmit={this.handleSubmit}>
					<span> </span>

					{game.treatment.gameLanguage == "Spanish" ? (
						<div className="pt-form-group">
							<div className="form-line thirds">
								{" "}
								<FormGroup
									className={"pt-form-content"}
									inline={false}
									label={
										<b>
											Por favor, describa la variedad de
											español que usted habla:
										</b>
									}
									labelFor={"spanishVariety"}
								>
									<TextArea
										id="spanishVariety"
										name="spanishVariety"
										large={true}
										intent={Intent.PRIMARY}
										onChange={this.handleChange}
										value={spanishVariety}
										fill={true}
									/>
								</FormGroup>{" "}
							</div>
							<br></br>
							<div className="pt-form-content">
								<div>
									<label htmlFor="whereLive">
										<b>¿En dónde vive usted?</b>
									</label>{" "}
									<input
										id="whereLive"
										type="text"
										dir="auto"
										name="whereLive"
										value={whereLive}
										onChange={this.handleChange}
										autoComplete="off"
									/>
								</div>{" "}
							</div>
							<br></br>
							<div className="pt-form-content">
								<div>
									<label htmlFor="whereLive">
										<b>¿En dónde creció?</b>
									</label>{" "}
									<input
										id="whereGrowUp"
										type="text"
										dir="auto"
										name="whereGrowUp"
										value={whereGrowUp}
										onChange={this.handleChange}
										autoComplete="off"
									/>
								</div>
								<br></br>
							</div>
						</div>
					) : null}

					{game.treatment.gameLanguage == "BCS" ? (


						<div className="pt-form-group">

						<div className="form-line">
							<div>
								<label htmlFor="languageAtHomeBCS">
									<b>Dok ste odrastali, koji ste jezik (ili jezike) govorili u domaćinstvu/kućanstvu:   </b>
								</label>
								<input
									id="languageAtHomeBCS"
									type="text"
									dir="auto"
									name="languageAtHomeBCS"
									value={languageAtHomeBCS}
									onChange={this.handleChange}
									autoComplete="off"
								/>
							</div>
						</div>

						<br></br>

						<div className="form-line">
							<div>
								<label htmlFor="otherLanguageAtHomeBCS">
									<b>	Dok ste odrastali, da li ste govorili bilo koje druge jezike u domaćinstvu/kućanstvu?   </b>
								</label>
								<input
									id="otherLanguageAtHomeBCS"
									type="text"
									dir="auto"
									name="otherLanguageAtHomeBCS"
									value={otherLanguageAtHomeBCS}
									onChange={this.handleChange}
									autoComplete="off"
								/>
							</div>
						</div>

						<br></br>

						<div className="form-line">
							<div>
								<label htmlFor="languageAtSchoolBCS">
									<b> Dok ste odrastali, koji se jezik govorio kao primarni jezik u školi?   </b>
								</label>
								<input
									id="languageAtSchoolBCS"
									type="text"
									dir="auto"
									name="languageAtSchoolBCS"
									value={languageAtSchoolBCS}
									onChange={this.handleChange}
									autoComplete="off"
								/>
							</div>
						</div>

						<br></br>


							<div className="pt-form-content">
								<b>
									{"Da li ste ikada živeli u Jugoslaviji ili u nekoj od zemalja bivše Jugoslavije?"}
								</b>
								<HTMLSelect
									name="yugoslavCountryYears"
									id="yugoslavCountryYears"
									onChange={this.handleChange}
									value={yugoslavCountryYears}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(
										yugoslavCountryYearsOptions,
										(name, key) => (
											<option key={key} value={key}>
												{name}
											</option>
										)
									)}
								</HTMLSelect>
							</div>
							<br></br>

							<div className="pt-form-content">
								<b>
									{"U kojoj zemlji bivše Jugoslavije ste živeli ili proveli dosta vremena?  "}
								</b>
								<HTMLSelect
									name="yugoslavCountry"
									id="yugoslavCountry"
									onChange={this.handleChange}
									value={yugoslavCountry}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(
										yugoslavCountryOptions,
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
									<label htmlFor="currentOutsideHomeLanguageBCS">
										<b> Koji jezik trenutno najčešće koristite van kuće?   </b>
									</label>
									<input
										id="currentOutsideHomeLanguageBCS"
										type="text"
										dir="auto"
										name="currentOutsideHomeLanguageBCS"
										value={currentOutsideHomeLanguageBCS}
										onChange={this.handleChange}
										autoComplete="off"
									/>
								</div>
							</div>

							<br></br>

							<div className="pt-form-content">
								<b>
									{"Kada koristim maternji oblik svog jezika ja bih rekao/la:   "}
								</b>
								<HTMLSelect
									name="dialectOneBCS"
									id="dialectOneBCS"
									onChange={this.handleChange}
									value={dialectOneBCS}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(
										dialectOneBCSOptions,
										(name, key) => (
											<option key={key} value={key}>
												{name}
											</option>
										)
									)}
								</HTMLSelect>
							</div>
							<br></br>

							<div className="pt-form-content">
								<b>
									{"Kada koristim maternji oblik svog jezika ja bih rekao/la:   "}
								</b>
								<HTMLSelect
									name="dialectTwoBCS"
									id="dialectTwoBCS"
									onChange={this.handleChange}
									value={dialectTwoBCS}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(
										dialectTwoBCSOptions,
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
					) : null}

					{game.treatment.gameLanguage == "Arabic" ? (
						<div className="pt-form-group">
							<div className="pt-form-content">
								<b>
									{"ما هي اللهجة العربية التي تتحدثها؟" + " "}
								</b>
								<HTMLSelect
									name="dialectArabic"
									id="dialectArabic"
									onChange={this.handleChange}
									value={dialectArabic}
								>
									<option selected>
										{gameTextInLanguage.SURVEY_selectOption}
									</option>
									{_.map(
										dialectArabicOptions,
										(name, key) => (
											<option key={key} value={key}>
												{name}
											</option>
										)
									)}

								</HTMLSelect>
								<label htmlFor="dialectArabicSpecify">
									<b>
										{" " +
											"إذا كنت تتحدث لهجة مختلفة الرجاء التحديد:" +
											" "}
									</b>
								</label>
								<input
									id="dialectArabicSpecify"
									type="text"
									dir="auto"
									name="dialectArabicSpecify"
									value={dialectArabicSpecify}
									onChange={this.handleChange}
									autoComplete="off"
								/>
							</div>{" "}
						</div>
					) : null}



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

					{game.treatment.gameLanguage == "English" ? (
						<div className="bp3-form-group">
							<label className="bp3-label" htmlFor="race">
								<b>
									{
										gameTextInLanguage.SURVEY_raceEthnicityIdentify
									}
								</b>
							</label>
							<div className="bp3-form-content ">
								<div className="bp3-control bp3-checkbox ">
									<Checkbox
										name={"raceWhite"}
										label={
											gameTextInLanguage.SURVEY_raceWhite
										}
										onChange={this.handleEnabledChange}
									/>
								</div>
								<div className="bp3-control bp3-checkbox ">
									<Checkbox
										name={"raceBlack"}
										label={
											gameTextInLanguage.SURVEY_raceBlack
										}
										onChange={this.handleEnabledChange}
									/>
								</div>
								<div className="bp3-control bp3-checkbox">
									<Checkbox
										name={"raceNative"}
										label={
											gameTextInLanguage.SURVEY_raceNative
										}
										onChange={this.handleEnabledChange}
									/>
								</div>
								<div className="bp3-control bp3-checkbox">
									<Checkbox
										name={"raceAsian"}
										label={
											gameTextInLanguage.SURVEY_raceAsian
										}
										onChange={this.handleEnabledChange}
									/>
								</div>
								<div className="bp3-control bp3-checkbox">
									<Checkbox
										name={"raceIslander"}
										label={
											gameTextInLanguage.SURVEY_raceIslander
										}
										onChange={this.handleEnabledChange}
									/>
								</div>
								<div className="bp3-control bp3-checkbox">
									<Checkbox
										name={"raceHispanic"}
										label={
											gameTextInLanguage.SURVEY_raceHispanic
										}
										onChange={this.handleEnabledChange}
									/>
								</div>
							</div>
						</div>
					) : null}
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
								//className={"form-group"}
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

					{game.treatment.gameLanguage != "BCS" ? (
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
							{game.treatment.gameLanguage == "Spanish" ? (
								<div>
									<label htmlFor="spanishCommunitySpecify">
										<b>
											{" " + "Si es así, ¿dónde?" + " "}
										</b>
									</label>
									<input
										id="spanishCommunitySpecify"
										type="text"
										dir="auto"
										name="spanishCommunitySpecify"
										value={spanishCommunitySpecify}
										onChange={this.handleChange}
										autoComplete="off"
									/>{" "}
								</div>
							) : null}
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
				</div>
				) : null}
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
