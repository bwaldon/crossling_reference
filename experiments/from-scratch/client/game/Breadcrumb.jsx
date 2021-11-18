import React from "react";
import { gameText } from "../gameText.js";
import { Breadcrumb as Crumb, Classes } from "@blueprintjs/core";

export default class Breadcrumb extends React.Component {
  render() {
    const { round, stage, game } = this.props;
    const gameTextInLanguage = gameText.filter(
      (row) => row.language == game.treatment.gameLanguage
    )[0];

    return (
      <nav className="round-nav" dir="auto">
        <ul className={Classes.BREADCRUMBS}>
          <li>
            <Crumb
              text={`${gameTextInLanguage.ROUND_roundText} ${
                round.index + 1
              } / ${game.get("length")}`}
            />
          </li>
          {/*{round.stages.map(s => {
            const disabled = s.name !== stage.name;
            const current = disabled ? "" : Classes.BREADCRUMB_CURRENT;
            return (
              <li key={s.name}>
                <Crumb
                  text={s.displayName}
                  disabled={disabled}
                  className={current}
                />
              </li>
            );
          })}*/}
        </ul>
      </nav>
    );
  }
}
