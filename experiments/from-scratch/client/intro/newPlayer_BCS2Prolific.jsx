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
                        <p>Unesite vaš Prolific ID ili email adresu:
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
                            <br></br> Molimo vas da unesete Prolific ID ukoliko ga imate.
                            <br></br> Ukoliko niste popunili formular za prijavu na Prolific-u, molimo vas unesite vašu email adresu.
                            <br></br> Mi ćemo poslati nadoknadu od 14 dolara (USD) preko Prolific Bonus Payment učestniku koji je registrovan na Prolific-u. Taj učesnik treba da podeli nadoknadu sa svojim suigračem (svakoj osobi po $7). Drugim rečima, suigrač koji nije registrovan na Prolific-u može svoju nadoknadu da dobije samo od svog suigrača. 
                          </div>
                        </p>

                        <p
                            style={{ marginTop: "1cm" }}
                            className="button-holder"
                        >
                            <button type="submit">
                                Sledeća
                            </button>
                        </p>
                    </form>
                </div>
            </Centered>
        );
    }
}
