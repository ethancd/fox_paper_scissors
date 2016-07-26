var TurnMarker = React.createClass({
  getInitialState: function() {
    return {color: this.props.initialColor };
  },
  render: function () {
    return (
      <div className="turn-marker" color={this.state.color} />
    );
  },
  componentDidMount: function() {
    EventsListener.listen("position.updated", this.setTurnMarker);
  },
  setTurnMarker: function(data) {
    this.setState({color: data.color});
  }
});