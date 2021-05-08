import React from "react";

import { Centered, ConsentButton } from "meteor/empirica:core";

export default class Consent extends React.Component {
  render() {
    return (
      <Centered>
        <div className="consent">
          <img src = "stanfordlogo.png" width = "300px" />  <img src = "alpslogo.png" width = "300px" />
          <h1> Consent Form </h1>
          <p> We invite you to participate in a research study on language production and comprehension. Your experimenter will ask you to do a linguistic task such as reading sentences or words, naming pictures or describing scenes, making up sentences of your own, or participating in a simple language game. 
          </p>

          <p> There are no risks or benefits of any kind involved in this study. 
          </p>

          <p> You will be paid for your participation at the posted rate. If you have read this form and have decided to participate in this experiment, please understand your participation is voluntary and you have the right to withdraw your consent or discontinue participation at any time without penalty or loss of benefits to which you are otherwise entitled. You have the right to refuse to do particular tasks. Your individual privacy will be maintained in all published and written data resulting from the study. You may print this form for your records.
          </p>

          <p> <b>CONTACT INFORMATION:</b> If you have any questions, concerns or complaints about this research study, its procedures, risks and benefits, you should contact the Protocol Director Meghan Sumner at (650)-725-9336. If you are not satisfied with how this study is being conducted, or if you have any concerns, complaints, or general questions about the research or your rights as a participant, please contact the Stanford Institutional Review Board (IRB) to speak to someone independent of the research team at (650)-723-2480 or toll free at 1-866-680-2906. 
          </p>

          <p> You can also write to the Stanford IRB, Stanford University, 3000 El Camino Real, Five Palo Alto Square, 4th Floor, Palo Alto, CA 94306 USA. 
          </p>

          <p> If you agree to participate, please proceed to the study tasks.
          </p>

          <br />
          <ConsentButton text="I AGREE" />
        </div>
      </Centered>
    );
  }
}
