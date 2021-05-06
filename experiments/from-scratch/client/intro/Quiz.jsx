import React from "react";

import { Centered, AlertToaster } from "meteor/empirica:core";

import { Radio, RadioGroup } from "@blueprintjs/core";

import { Checkbox } from "@blueprintjs/core";

export default class GroupQuiz extends React.Component {
  state = {
    directorCanClick: "",
    guesserWantsToClick: "",
    targetRedCircle: "",
    onlyDirector: "",
    total72rounds: "",
    sameLocations: "",
    // selectionControl: "",
    // aftertask: "",
   // chat: ""
  };

  componentDidMount() {
    const { game } = this.props;
    document.querySelector("main").scrollTo(0,0)
    this.state.num_players = game.treatment.playerCount;
  }

  handleChange = (event) => {
    const el = event.currentTarget;
    this.setState({ [el.name]: el.value.trim().toLowerCase() });
  };

  handleRadioChange = (event) => {
    const el = event.currentTarget;
    console.log("el", el);
    console.log("ev", event);
    this.setState({ [el.name]: el.value });
  };

  handleEnabledChange = (event) => {
    const el = event.currentTarget;
    this.setState({ [el.name]: !this.state[el.name] });
  };

  handleSubmit = (event) => {
    event.preventDefault();

    //it should be this.state.nParticipants !== "3" but we don't have "treatment" in QUIZ
    if(this.state.directorCanClick !== "false" ||
      this.state.guesserWantsToClick !== "true" ||
      this.state.targetRedCircle !== "false" ||
      this.state.onlyDirector !== "false" ||
      this.state.total72rounds !== "true" ||
      this.state.sameLocations !== "false"

      ) {
      AlertToaster.show({
        message:
          "Sorry, you have one or more mistakes. Please ensure that you answer the questions correctly, or go back to the instructions.",
      });
    } else {
      this.props.onNext();
    }
  };

  render() {
    const { hasPrev, onPrev, game, treatment } = this.props;
    return (
      <Centered>
        <div className="quiz">
          <h1 className={"bp3-heading"}> Quiz </h1>
          <form onSubmit={this.handleSubmit}>
      

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label="The director can click on an object."
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.directorCanClick}
                  name="directorCanClick"
                  required
                >
                  <Radio
                    label="True"
                    value= "true"
                  />
                  <Radio
                    label="False"
                    value= "false"
                  />
                </RadioGroup>
              </div>
            </div>

             <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label="The guesser clicks on the object that the director is telling them about."
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.guesserWantsToClick}
                  name="guesserWantsToClick"
                  required
                >
                  <Radio
                    label="True"
                    value= "true"
                  />
                  <Radio
                    label="False"
                    value= "false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label="The target is the object that has the red circle around it."
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.targetRedCircle}
                  name="targetRedCircle"
                  required
                >
                  <Radio
                    label="True"
                    value= "true"
                  />
                  <Radio
                    label="False"
                    value= "false"
                  />
                </RadioGroup>
              </div>
            </div>

              <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label="Only the director can send messages in the chat."
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.onlyDirector}
                  name="onlyDirector"
                  required
                >
                  <Radio
                    label="True"
                    value= "true"
                  />
                  <Radio
                    label="False"
                    value= "false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label="There are a total of 72 rounds."
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.total72rounds}
                  name="total72rounds"
                  required
                >
                  <Radio
                    label="True"
                    value= "true"
                  />
                  <Radio
                    label="False"
                    value= "false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label="The locations of the objects are the same for the director and the guesser."
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.sameLocations}
                  name="sameLocations"
                  required
                >
                  <Radio
                    label="True"
                    value= "true"
                  />
                  <Radio
                    label="False"
                    value= "false"
                  />
                </RadioGroup>
              </div>
            </div>
          
          
            <button
              type="button"
              className="bp3-button bp3-intent-nope bp3-icon-double-chevron-left"
              onClick={onPrev}
              disabled={!hasPrev}
            >
              Back to instructions
            </button>
            <button type="submit" className="bp3-button bp3-intent-primary">
              Submit
              <span className="bp3-icon-standard bp3-icon-key-enter bp3-align-right" />
            </button>
          </form>
        </div>
      </Centered>
    );
  }
}

