import React from "react";

import { Centered, AlertToaster } from "meteor/empirica:core:dnd";

import { Radio, RadioGroup } from "@blueprintjs/core";

import { Checkbox } from "@blueprintjs/core";

import { gameText } from "../gameText.js";

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
    document.querySelector("main").scrollTo(0, 0);
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

    const { game } = this.props;

    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    //it should be this.state.nParticipants !== "3" but we don't have "treatment" in QUIZ
    if (
      this.state.directorCanClick !== "false" ||
      this.state.guesserWantsToClick !== "true" ||
      this.state.targetRedCircle !== "false" ||
      this.state.onlyDirector !== "false" ||
      this.state.total72rounds !== "true" ||
      this.state.sameLocations !== "false"
    ) {
      AlertToaster.show({
        message: gameTextInLanguage.QUIZ_MistakesMessage,
      });
    } else {
      this.props.onNext();
    }
  };

  render() {
    const { hasPrev, onPrev, game, treatment } = this.props;

    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    return (
      <Centered>
        <div className="quiz">
          <h1 className={"bp3-heading"}>
            {" "}
            {gameTextInLanguage.QUIZ_HeaderText}{" "}
          </h1>
          <form onSubmit={this.handleSubmit}>
            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label={gameTextInLanguage.QUIZ_Question1}
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.directorCanClick}
                  name="directorCanClick"
                  required
                >
                  <Radio
                    label={gameTextInLanguage.QUIZ_TrueButtonText}
                    value="true"
                  />
                  <Radio
                    label={gameTextInLanguage.QUIZ_FalseButtonText}
                    value="false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label={gameTextInLanguage.QUIZ_Question2}
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.guesserWantsToClick}
                  name="guesserWantsToClick"
                  required
                >
                  <Radio
                    label={gameTextInLanguage.QUIZ_TrueButtonText}
                    value="true"
                  />
                  <Radio
                    label={gameTextInLanguage.QUIZ_FalseButtonText}
                    value="false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label={gameTextInLanguage.QUIZ_Question3}
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.targetRedCircle}
                  name="targetRedCircle"
                  required
                >
                  <Radio
                    label={gameTextInLanguage.QUIZ_TrueButtonText}
                    value="true"
                  />
                  <Radio
                    label={gameTextInLanguage.QUIZ_FalseButtonText}
                    value="false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label={gameTextInLanguage.QUIZ_Question4}
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.onlyDirector}
                  name="onlyDirector"
                  required
                >
                  <Radio
                    label={gameTextInLanguage.QUIZ_TrueButtonText}
                    value="true"
                  />
                  <Radio
                    label={gameTextInLanguage.QUIZ_FalseButtonText}
                    value="false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label={gameTextInLanguage.QUIZ_Question5}
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.total72rounds}
                  name="total72rounds"
                  required
                >
                  <Radio
                    label={gameTextInLanguage.QUIZ_TrueButtonText}
                    value="true"
                  />
                  <Radio
                    label={gameTextInLanguage.QUIZ_FalseButtonText}
                    value="false"
                  />
                </RadioGroup>
              </div>
            </div>

            <div className="bp3-form-group">
              <div className="bp3-form-content">
                <RadioGroup
                  label={gameTextInLanguage.QUIZ_Question6}
                  onChange={this.handleRadioChange}
                  selectedValue={this.state.sameLocations}
                  name="sameLocations"
                  required
                >
                  <Radio
                    label={gameTextInLanguage.QUIZ_TrueButtonText}
                    value="true"
                  />
                  <Radio
                    label={gameTextInLanguage.QUIZ_FalseButtonText}
                    value="false"
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
              {gameTextInLanguage.QUIZ_BackToInstructionsText}
            </button>
            <button type="submit" className="bp3-button bp3-intent-primary">
              {gameTextInLanguage.QUIZ_StartGameText}
              <span className="bp3-icon-standard bp3-icon-key-enter bp3-align-right" />
            </button>
          </form>
        </div>
      </Centered>
    );
  }
}
