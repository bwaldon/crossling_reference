import React from "react";

import { Centered } from "meteor/empirica:core";


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
            // time,
        } = this.state;

        return (
            <div>
              {" "}
              <h1>
                Finally, please answer the following short survey. 
              </h1>
              <h3>
                You do not have to provide any information you feel uncomfortable with sharing. 
              </h3>
              <h3>
                  Your compensation does NOT depend on these answers.
                </h3>
              <form onSubmit={this.handleSubmit}>
                    <span> </span>
                    <div className="form-line">
              <div>
                <label htmlFor="age"><b>Age:</b></label>
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
                <label htmlFor="gender"><b>Gender:</b></label>
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
                <label htmlFor="language"><b>Native Language(s):</b></label>
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
                <b>Which races/ethnicities do you identify with? Select all that apply.</b>
              </label>
              <div className="bp3-form-content ">
                <div className="bp3-control bp3-checkbox ">
                  <Checkbox
                    name={"raceWhite"}
                    label="White"
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox ">
                  <Checkbox
                    name={"raceBlack"}
                    label="Black or African American"
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceNative"}
                    label="Native American or Alaska Native"
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceAsian"}
                    label="Asian"
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceIslander"}
                    label="Native Hawaiian or other Pacific Islander"
                    onChange={this.handleEnabledChange}
                  />
                </div>
                <div className="bp3-control bp3-checkbox">
                  <Checkbox
                    name={"raceHispanic"}
                    label="Hispanic or Latino"
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
                                label=<b>What's your highest level of education?</b>
                                onChange={this.handleChange}
                                selectedValue={education}
                                onChange={this.handleChange}
                            >
              <Radio
                  value="lessHighSchool"
                  label="Less than high school"
                />
                <Radio
                  value="highSchool"
                  label="High school"
                />
                <Radio
                  value="someCollege"
                  label="Some college (<2 years of study)"
                />
                <Radio
                  value="undergrad"
                  label="Undergraduate (bachelor's or associate's) degree "
                />
                <Radio
                  value="graduate"
                  label="Graduate degree"
                />
                </RadioGroup>
            </div>
            </div> <br></br>
                    <div className="pt-form-group">
                        <div className="pt-form-content">
                            <RadioGroup
                                name="correctness"
                                label=<b>Did you read the instructions and think you did the tasks correctly?</b>
                                onChange={this.handleChange}
                                selectedValue={correctness}
                            >
                                <Radio
                                    label="Yes"
                                    value="yes"
                                    className={"pt-inline"}
                                />
                                <Radio
                                    label="No, I was confused"
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
                                label=<b>Do you think you and your partner worked well together?</b>
                                onChange={this.handleChange}
                                selectedValue={workedWell}
                            >
                                <Radio
                                    label="Strongly agree"
                                    value="stronglyAgree"
                                    className={"pt-inline"}
                                />
                                <Radio label="Agree" value="agree" className={"pt-inline"} />
                                <Radio
                                    label="Neutral"
                                    value="neutral"
                                    className={"pt-inline"}
                                />

                                <Radio
                                    label="Disagree"
                                    value="disagree"
                                    className={"pt-inline"}
                                />

                                <Radio
                                    label="Strongly disagree"
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
                            label={<b>Do you feel the pay was fair?</b>}
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
    label={<b>Was the in-game chat feature easy to use?</b>}
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
                      label={<b>Did you notice any problems or have any other comments about the study?</b>}
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
                    <button type="submit" className="pt-button pt-intent-primary">
                        Submit
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