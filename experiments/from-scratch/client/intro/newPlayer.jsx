import React, { Component } from 'react';
import { Centered } from "meteor/empirica:core";
import {newPlayerTexts, newPlayerLanguage} from './newPlayerTexts.js'
export default class PlayerId extends Component {
    state = { id: "" };
    
    // Update the stored state of the id
    handleUpdate = event => {
        const { value, name } = event.currentTarget;
        this.setState({ [name]: value });
    }; 
    
    // Submit the id when submit button is clicked
    handleSubmit = event => {
        event.preventDefault();

        const { handleNewPlayer } = this.props;
        const { id } = this.state;
        handleNewPlayer(id);
    };

    render() {
        const { id } = this.state;


        return (
            <Centered>
                <div className="new-player">
                    <form onSubmit={this.handleSubmit}>
                        <h1>{newPlayerTexts[newPlayerLanguage].IdentificationHeaderText}</h1>

                        <p>
                        {newPlayerTexts[newPlayerLanguage].EnterProlificIDPrompt}
                        </p>

                        <input
                            dir="auto"
                            type="text"
                            name="id"
                            id="id"
                            value={id}
                            onChange={this.handleUpdate}
                            //placeholder="e.g. 1111111111"
                            required
                            autoComplete="off"
                        /> 


                        <p style={{marginTop:"1cm"}} className="button-holder">
                            <button type="submit">{newPlayerTexts[newPlayerLanguage].SubmitButtonText}</button>
                        </p>

                    </form>
                </div>
            </Centered>
        )
    }
}
