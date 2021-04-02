import React from "react";
// from Robert Hawkins

export default class customBreadcrumb extends React.Component {
  render() {
    const { game, round, stage } = this.props;
    return (
      <ul className="breadcrumb">
      <li>Round {round.index + 1} / {game.get('length')}</li>
      {round.stages.map(s => (
        <li key={s.name} className={s.name === stage.name ? "current" : ""}>
        {s.displayName}
        </li>
        ))}
      </ul>
    );
  }
}


