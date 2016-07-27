var PlayerName = React.createClass({
  getInitialState: function() {
    return {
      userName: this.props.initialName,
      winHistory: ""
    };
  },
  render: function () {
    return (
      <h3 className="player-name" data-side={this.getSide()} data-content={this.state.winHistory}>
        {this.getName()} ({this.getNoun()})
      </h3>
    );
  },
  componentDidMount: function() {
    EventsListener.listen('set.player.name', this.setPlayerName);
    EventsListener.listen('game.won', this.addStar);
  },
  isVacant: function() {
    return !this.state.userName;
  },
  isAI: function() {
    return this.state.userName.match("dauntless_drone"); //what a hack
  },
  getName: function() {
    return this.state.userName || "waiting";
  },
  getSide: function() {
    return this.isVacant() ? "vacant" : this.props.color;
  },
  getNoun: function() {
    if(this.isVacant()) {
      return "...";
    }

    if(this.isAI()) {
      return "AI";
    }

    if(!CurrentPlayer) {
      return "Them";
    } 

    return this.state.userName === CurrentPlayer.user_name ? "You" : "Them";
  },
  addStar: function(data) {
    if(!this.state.userName.match(data.winner)) {
      return;
    }

    this.setState({winHistory: this.state.winHistory + "*"})
  },
  setPlayerName: function(data) {
    if (!this.isVacant()) {
      return;
    }

    this.setState({ userName: data.userName });
  }
});