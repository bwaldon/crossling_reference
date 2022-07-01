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
			amazon,
			yugoslavCountryYears,
			yugoslavCountry,
			languageAtHomeBCS,
			otherLanguageAtHomeBCS,
			languageAtSchoolBCS,
			currentOutsideHomeLanguageBCS,
			dialectOneBCS,
			dialectTwoBCS,
			relationship,
			relationshipOther,
			familiarityRate
		} = this.state;

		const { game } = this.props;

		const gameTextInLanguage = gameText.filter(
			(row) => row.language == game.treatment.gameLanguage
		)[0];


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

		const amazonOptions = {
			usa: "Sjedinjene Američke Države (USA) ",
			uk: "Velika Britanija (UK)",
			ca: "Kanada",
			de: "Nemačka",
			it: "Italija",
			fr: "Francuska",
			es: "Španija",
			au: "Australija"
		};

		const relationshipOptions = {
			closeFriends: "dobri prijatelji",
			friends: "prijatelji",
			spouse: "muž/žena",
			family: "članovi porodice (n.pr. roditelj, brat/sestra, idt)",
			acquiantance: "poznanici",
			none: "ne poznajem svog partnera",
			other: "drugo"
		};

		const familiarityRateOptions = {
			daily: "dnevno",
			severalWeekly: "otprilike nekoliko puta nedeljno",
			onceWeekly: "otprilike jedanput nedeljno",
			severalMonthl: "otprilike nekoliko puta mesečno",
			onceMonth: "otprilike jedanput puta mesečno",
			rarely: "manje od jedanput mesečno",
			never: "nikada nisam pričao/la sa ovom osobom pre"
		};

		return (
			<div dir="auto">
				<h2> Molimo vas odgovorite na sledeće pitanje da biste dobili ispravnu Amazon gift karticu. </h2>
				<p> Ako vi imate ili vaš partner ima Prolific ID, slobodno preskočite ovo pitanje </p>
				<div className="pt-form-content">
					<b>
						{"Za naknadu, ja hoću Amazon gift karticu za sledeću zemlju:"}
					</b>
					<HTMLSelect
						name="amazon"
						id="amazon"
						onChange={this.handleChange}
						value={amazon}
					>
						<option selected>
							{gameTextInLanguage.SURVEY_selectOption}
						</option>
						{_.map(
							amazonOptions,
							(name, key) => (
								<option key={key} value={key}>
									{name}
								</option>
							)
						)}
					</HTMLSelect>
				</div>
				<h2>  </h2>

				<h2> Ostala pitanja nisu obavezna ali nam pomažu da razumemo vaše rezultate </h2>
				<form onSubmit={this.handleSubmit}>
					<span> </span>

					<div className="pt-form-group">
						<br></br>

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

					<div className="pt-form-group">
						<div className="pt-form-content">
							<b>
								{"Kako poznajete partnera s kime ste igrali igricu:"}
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
									<b>	Ako ste odgovorilo "drugo" u prethodnom pitanju, molimo vas opišite kako se poznajete:</b>
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
								{"Koliko često pričate sa vašim partnerom:"}
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
