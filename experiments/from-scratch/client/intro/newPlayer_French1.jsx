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
        handleNewPlayer(id.concat("French1"));
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
                          Veuillez saisir votre ID Prolific ou votre adresse email.
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
                            <br></br> Veuillez saisir votre ID Prolific si vous en avez un.
                            <br></br> Si vous n'avez pas complété l'étude de registration sur Prolific, saisissez votre adresse email.
                            <br></br>Nous enverrons une compensation de $14 (USD) via Prolific Bonus Payment au·à la participant·e qui est enregistré·e auprès de Prolific.
                            Le·la participant·e doit partager la compensation avec son·sa partenaire ($7 chacun·e).
                            Autrement dit, un·e partenaire qui n'est pas inscrit·e sur Prolific ne peut obtenir sa compensation que de son·sa partenaire.
                          </div>
                        </p>

                        <p
                            style={{ marginTop: "1cm" }}
                            className="button-holder"
                        >
                            <button type="submit">
                              Soumettre
                            </button>
                        </p>
                    </form>
                </div>
            </Centered>
        );
    }
}
