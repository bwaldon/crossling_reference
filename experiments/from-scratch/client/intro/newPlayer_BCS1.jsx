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
                        <p>Unesite email adresu ili Prolific ID:
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
                            <br></br>Molimo vas unesite email adresu na koju možemo da vam pošaljemo Amazon gift karticu.
                            <br></br>Ako imate Prolific ID, unesite taj broj a <b>ne</b> vašu email adresu.
                            <br></br>Da biste dobili ispravnu Amazon karticu, na kraju studije, molimo vas odgovorite na prvo pitanje.
                            <br></br>Mi nudimo Amazon gift kartice za sledeće zemlje: SAD (USA), Velika Britanija (UK), Kanada, Nemačka, Italija, Francuska, Španija, Australija.
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
