import React, { Component } from "react";
import { Centered } from "meteor/empirica:core";
export default class PlayerId extends Component {
    state = { id: "" };

    // Update the stored state of the id
    handleUpdate = (event) => {
        const { value, name } = event.currentTarget;
        this.setState({ [name]: value });
    };

    // Submit the id when submit button is clicked
    handleSubmit = (event) => {
        event.preventDefault();

        const { handleNewPlayer } = this.props;
        const { id } = this.state;
        handleNewPlayer(id.concat("BCSEng2"));
    };

    // for BCS radio button
    setValue(event) {
      console.log(event.target.value);
    };

    render() {
        const { id } = this.state;
        const urlParams = new window.URL(document.location).searchParams;
        const batchGroupName = urlParams.get("batchGroupName");

        return (
            <Centered>
                <div className="new-player" dir="auto">
                    <form onSubmit={this.handleSubmit}>
                        <p>
                          Please enter your email or Prolific ID:
                        </p>
                        <br/>

                        <input
                            type="text"
                            name="id"
                            id="id"
                            value={id}
                            onChange={this.handleUpdate}
                            //placeholder="e.g. 1111111111"
                            required
                            autoComplete="off"
                        />

                        <p>
                          <div>
                            <br></br>If you have a Prolific ID, please enter the ID and <b>not</b> your email address.
                            <br></br>If you are a partner of someone recruited via prolific, please provide your email address (you will not receive any emails from us).
                            <br></br> A compensation of $14 (USD) is provided via a prolific bonus payment to the partner who was recruited via prolific. It is up to that person to split the compensation equally between both partners ($7 each). In other words, if you did not complete the prolific pre-registration, you will receive your compensation from your partner (and not directly from us).
                          </div>
                        </p>

                        <p
                            style={{ marginTop: "1cm" }}
                            className="button-holder"
                        >
                            <button type="submit">
                              Next
                            </button>
                        </p>
                    </form>
                </div>
            </Centered>
        );
    }
}
