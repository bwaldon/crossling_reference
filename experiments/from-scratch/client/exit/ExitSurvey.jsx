import React from "react";

import { Centered } from "meteor/empirica:core";

import { exitTexts, exitTextsLanguage } from './exitTexts.js';

import {
    Button,
    Classes,
    FormGroup,
    RadioGroup,
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
        // human: "",
        workedWell: "",
        fair: "",
        chatUseful: "",
        feedback: "",
        // time: "",
        colorblind: "",
        robot: ""
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
            // human,
            workedWell,
            fair,
            chatUseful,
            feedback,
            colorblind,
            // time,
            robot
        } = this.state;

        return (
            <div>
              {" "}
              <h1>
                {exitTexts[exitTextsLanguage].SURVEY_line1}
              </h1>
              <h3>
              {exitTexts[exitTextsLanguage].SURVEY_line2}
              </h3>
              <h3>
              {exitTexts[exitTextsLanguage].SURVEY_line3}
                </h3>
              <form onSubmit={this.handleSubmit}>
                    <span> </span>
                    <div className="form-line">
              <div>
                <label htmlFor="age"><b>{exitTexts[exitTextsLanguage].SURVEY_age}</b></label>
                <div>
                  <input
                    id="age"
                    type="number"
                    min="0"
                    max="150"
                    step="1"
                    dir="auto"
                    name="age"
                    value={age}
                    onChange={this.handleChange}
                  />
                </div>
              </div>
                </div>
                <div className="form-line">
              <div>
                <label htmlFor="gender"><b>{exitTexts[exitTextsLanguage].SURVEY_gender}</b></label>
                <div>
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
            </div>
            <div className="form-line">
            <div>
                <label htmlFor="language"><b>{exitTexts[exitTextsLanguage].SURVEY_nativeLanguages}</b></label>
                <div>
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
            </div>
          <br></br>
            <div className="bp3-form-group">
              <label className="bp3-label" htmlFor="race">
                <b>{exitTexts[exitTextsLanguage].SURVEY_raceEthnicityIdentify}</b>
              </label>
              <div className="bp3-form-content ">
                <div className="bp3-control bp3-checkbox ">
                  <Checkbox
                    name={"raceWhite"}
                    label={exitTexts[exitTextsLanguage].SURVEY_raceWhite}
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox ">
                  <Checkbox
                    name={"raceBlack"}
                    label={exitTexts[exitTextsLanguage].SURVEY_raceBlack}
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceNative"}
                    label={exitTexts[exitTextsLanguage].SURVEY_raceNative}
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceAsian"}
                    label={exitTexts[exitTextsLanguage].SURVEY_raceAsian}
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceIslander"}
                    label={exitTexts[exitTextsLanguage].SURVEY_raceIslander}
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceHispanic"}
                    label={exitTexts[exitTextsLanguage].SURVEY_raceHispanic}
                    onChange={this.handleEnabledChange}
                  />
                </div>
              </div>
            </div>


            <div>
            <div className="pt-form-group">
                        <div className="pt-form-content">
                            <RadioGroup
                                name="education"
                                label={<b>{exitTexts[exitTextsLanguage].SURVEY_highestLevelOfEducation}</b>}
                                onChange={this.handleChange}
                                selectedValue={education}
                                onChange={this.handleChange}
                            >
              <Radio
                  value="lessHighSchool"
                  label={exitTexts[exitTextsLanguage].SURVEY_lessHighSchool}
                />
                <Radio
                  value="highSchool"
                  label={exitTexts[exitTextsLanguage].SURVEY_highSchool}
                />
                <Radio
                  value="someCollege"
                  label={exitTexts[exitTextsLanguage].SURVEY_someCollege}
                />
                <Radio
                  value="undergrad"
                  label={exitTexts[exitTextsLanguage].SURVEY_undergrad}
                />
                <Radio
                  value="graduate"
                  label={exitTexts[exitTextsLanguage].SURVEY_graduate}
                />
                </RadioGroup>
            </div>
            </div> <br></br>
                    <div className="pt-form-group">
                        <div className="pt-form-content">
                            <RadioGroup
                                name="correctness"
                                label=<b>{exitTexts[exitTextsLanguage].SURVEY_followedInstructions}</b>
                                onChange={this.handleChange}
                                selectedValue={correctness}
                            >
                                <Radio
                                    label={exitTexts[exitTextsLanguage].SURVEY_yesFollowedInstructions}
                                    value="yes"
                                    className={"pt-inline"}
                                />
                                <Radio
                                    label={exitTexts[exitTextsLanguage].SURVEY_noFollowedInstructions}
                                    value="no"
                                    className={"pt-inline"}
                                />
                            </RadioGroup>
                        </div>
                    </div> <br></br>


                   {/* <div className="pt-form-group">
                        <div className="pt-form-content">
                            <RadioGroup
                                name="human"
                                label=<b>Did you believe that you were playing with real human partners?</b>
                                onChange={this.handleChange}
                                selectedValue={human}
                            >
                                <Radio
                                    label="Yes, my partners were real participants."
                                    value="yes"
                                    className={"pt-inline"}
                                />
                                <Radio
                                    label="No, my partners were secretly computers."
                                    value="no"
                                    className={"pt-inline"}
                                />
                            </RadioGroup>
                        </div>
                    </div> <br></br>*/}

                    <div className="pt-form-group">
                        <div className="pt-form-content">
                            <RadioGroup
                                name="workedWell"
                                label=<b>{exitTexts[exitTextsLanguage].SURVEY_workedWellWithPartner}</b>
                                onChange={this.handleChange}
                                selectedValue={workedWell}
                            >
                                <Radio
                                    label={exitTexts[exitTextsLanguage].SURVEY_stronglyAgree}
                                    value="stronglyAgree"
                                    className={"pt-inline"}
                                />
                                <Radio label={exitTexts[exitTextsLanguage].SURVEY_agree} value="agree" className={"pt-inline"} />
                                <Radio
                                    label={exitTexts[exitTextsLanguage].SURVEY_neutral}
                                    value="neutral"
                                    className={"pt-inline"}
                                />

                                <Radio
                                    label={exitTexts[exitTextsLanguage].SURVEY_disagree}
                                    value="disagree"
                                    className={"pt-inline"}
                                />

                                <Radio
                                    label={exitTexts[exitTextsLanguage].SURVEY_stronglyDisagree}
                                    value="stronglyDisagree"
                                    className={"pt-inline"}
                                />
                            </RadioGroup>
                        </div>
                    </div> <br></br>

                    <div className="form-line thirds">

                        <FormGroup
                            className={"form-group"}
                            inline={false}
                            label={<b>{exitTexts[exitTextsLanguage].SURVEY_payWasFair}</b>}
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
    label={<b>{exitTexts[exitTextsLanguage].SURVEY_inGameChatEasyToUse}</b>}
    labelFor={"chatUseful"}
    //className={"form-group"}
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

{/*<div className="form-line thirds">

<FormGroup
    className={"form-group"}
    inline={false}
    label={<b>Did you feel like you had enough time on each round?</b>}
    labelFor={"time"}
    //className={"form-group"}
>
    <TextArea
        id="time"
        name="time"
        large={true}
        intent={Intent.PRIMARY}
        onChange={this.handleChange}
        value={time}
        fill={true}
    />
</FormGroup>
</div>*/}
                    <div className="form-line thirds">
                    <FormGroup
                      className={"form-group"}
                      inline={false}
                      label={<b>{exitTexts[exitTextsLanguage].SURVEY_colorblind}</b>}
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
                      label={<b>{exitTexts[exitTextsLanguage].SURVEY_problemsOrComments}</b>}
                      labelFor={"feedback"}
                      //className={"form-group"}
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
                    
                    </div>

                <div className="pt-form-group">
                        <div className="pt-form-content">
                            <RadioGroup
                                name="robot"
                                label=<b>{exitTexts[exitTextsLanguage].SURVEY_believePartnerWasHuman}</b>
                                onChange={this.handleChange}
                                selectedValue={robot}
                            >
              <Radio
                  value="yes"
                  label="Yes"
                />
                <Radio
                  value="no"
                  label="No"
                />
                </RadioGroup>
            </div> </div>

                    <button type="submit" className="pt-button pt-intent-primary">
                        {exitTexts[exitTextsLanguage].SURVEY_submitButtonText}
                        <span className="pt-icon-standard pt-icon-key-enter pt-align-right" />
                    </button>
                </form>{" "}
            </div>
        );
    };

    componentWillMount() {}

    render() {
        const { player, game } = this.props;
        return (
            <Centered>
                <div className="exit-survey">
                    {this.exitForm()}
                </div>
            </Centered>
        );
    }
}