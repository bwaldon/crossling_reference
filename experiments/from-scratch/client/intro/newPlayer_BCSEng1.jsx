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
        handleNewPlayer(id);
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
                            <br></br>Please enter your email address to which we can send your Amazon gift card.
                            <br></br>If you have a Prolific ID, please enter the ID and <b>not</b> your email address.
                            <br></br>To receive the correct Amazon gift card, please fill out the first question at the end of the experiment.
                            <br></br>We offer Amazon gift cards for the following countries: USA, UK, Canada, Germany, Italy, France, Spain, and Australia.
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
