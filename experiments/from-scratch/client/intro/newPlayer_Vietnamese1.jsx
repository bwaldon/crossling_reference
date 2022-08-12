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
        handleNewPlayer(id.concat("Vietnamese1"));
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
                        <p>Vui lòng nhập email hoặc Prolific ID của quý vị:
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
                            <br></br> Vui lòng nhập Prolific ID của quý vị nếu quý vị có.
                            <br></br> Nếu quý vị là đối tác của một người nào đó từ Prolific, vui lòng nhập email (quý vị sẽ không nhận email từ chúng tôi).
                            <br></br> Chúng tôi sẽ trả tiền $14 (USD) bằng Prolific Bonus Payment cho người nào đó sử dụng Prolific. Người đó sẽ cần phải chia đều số tiền cho hai người ($7 USD cho mỗi người). Người không phải từ Prolific sẽ được trả bằng người kia và không phải từ chúng tôi.
                          </div>
                        </p>

                        <p
                            style={{ marginTop: "1cm" }}
                            className="button-holder"
                        >
                            <button type="submit">
                                Gửi
                            </button>
                        </p>
                    </form>
                </div>
            </Centered>
        );
    }
}