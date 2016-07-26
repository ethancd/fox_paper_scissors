var GameButton = React.createClass({
  getInitialState: function() {
    return {action: this.props.initialAction };
  },
  render: function () {
    return (
      <button className="game" onClick={this.activateButton} action={this.state.action}>
        {this.buttonText[this.state.action]}
      </button>
    );
  },
  componentDidMount: function() {
    EventsListener.listen('enable.button', this.setButtonAction)
    EventsListener.listen("game.over", this.setButtonAction.bind(this, {action: "new-game"}));
    EventsListener.listen("position.updated", this.setButtonAction.bind(this, {action: "offer-draw"}));
  },
  activateButton: function() {
    $.post(this.buttonUrl[this.state.action], {slug: Helpers.getSlug()});
    this.setButtonAction({action: "none"});
  },
  setButtonAction: function(data) {
    this.setState({action: data.action});
  },
  buttonText: {
    "new-game": "New Game!",
    "offer-draw": "Offer Draw",
    "accept-draw": "Accept Draw"
  },
  buttonUrl: {
    "new-game": "/play/create/",
    "offer-draw": "/play/offer-draw/",
    "accept-draw": "/play/accept-draw/"
  }
});