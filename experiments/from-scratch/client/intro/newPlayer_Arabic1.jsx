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
                            الرجاء إدخال عنوان بريدك الإلكتروني حتى نتمكن من تعويضك في نهاية الدراسة. (سيتم استخدام عنوان بريدك الإلكتروني فقط للحصول على التعويض، وستكون أجوبتك جميعها مجهولة المصدر).
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

                        <p
                            style={{ marginTop: "1cm" }}
                            className="button-holder"
                        >
                            <button type="submit">
                              التالي
                            </button>
                        </p>
                    </form>
                </div>
            </Centered>
        );
    }
}
