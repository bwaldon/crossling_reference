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
                            {batchGroupName === null
                                ? "Please enter your Prolific ID:"
                                : batchGroupName.includes("English") ||
                                  batchGroupName.includes("english")
                                ? "Please enter your Prolific ID:"
                                : batchGroupName.includes("chinese") ||
                                  batchGroupName.includes("Chinese")
                                ? "请输入你的Prolific账号:"
                                : batchGroupName.includes("bcs") ||
                                  batchGroupName.includes("BCS") ||
                                  batchGroupName.includes("Bcs")
                                ? "Unesite email adresu ili Prolific ID:"
                                : batchGroupName.includes("EngCS")
                                ? "Please enter your email or Prolific ID:"
                                : batchGroupName.includes("arabic") ||
                                  batchGroupName.includes("Arabic")
                                ? "الرجاء إدخال عنوان بريدك الإلكتروني حتى نتمكن من تعويضك في نهاية الدراسة. (سيتم استخدام عنوان بريدك الإلكتروني فقط للحصول على التعويض، وستكون أجوبتك جميعها مجهولة المصدر)."
                                : batchGroupName.includes("Spanish") ||
                                  batchGroupName.includes("spanish")
                                ? "Por favor, ingrese su ID de Prolific."
                                : "Please enter your Prolific ID:"}
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
                            {batchGroupName.includes("EngCS")? (
                                  <div>
                                    <br></br>Please enter your email address to which we can send your Amazon gift card.
                                    <br></br>If you have a Prolific ID, please enter the ID and <b>not</b> your email address.
                                    <br></br>To receive the correct Amazon gift card, please fill out the first question at the end of the experiment.
                                    <br></br>We offer Amazon gift cards for the following countries: USA, UK, Canada, Germany, Italy, France, Spain, and Australia.
                                  </div>
                                  ) : null}

                                  {batchGroupName.includes("bcs") ||
                                  batchGroupName.includes("BCS") ||
                                  batchGroupName.includes("Bcs") ? (
                                  <div>
                                    <br></br>Molimo vas unesite email adresu na koju možemo da vam pošaljemo Amazon gift karticu.
                                    <br></br>Ako imate Prolific ID, unesite taj broj a <b>ne</b> vašu email adresu.
                                    <br></br>Da biste dobili ispravnu Amazon karticu, na kraju studije, molimo vas odgovorite na prvo pitanje.
                                    <br></br>Mi nudimo Amazon gift kartice za sledeće zemlje: SAD (USA), Velika Britanija (UK), Kanada, Nemačka, Italija, Francuska, Španija, Australija.
                                  </div>
                                  ) : null}

                        </p>

                        <p
                            style={{ marginTop: "1cm" }}
                            className="button-holder"
                        >
                            <button type="submit">
                                {batchGroupName === null
                                    ? "Next"
                                    : batchGroupName.includes("chinese") ||
                                      batchGroupName.includes("Chinese")
                                    ? "下一页"
                                    : batchGroupName.includes("arabic") ||
                                      batchGroupName.includes("Arabic")
                                    ? "التالي"
                                    : batchGroupName.includes("Spanish") ||
                                      batchGroupName.includes("spanish")
                                    ? "Siguiente"
                                    : batchGroupName.includes("bcs") ||
                                      batchGroupName.includes("BCS") ||
                                      batchGroupName.includes("Bcs")
                                    ? "Sledeća"
                                    : "Next"}
                            </button>
                        </p>
                    </form>
                </div>
            </Centered>
        );
    }
}
