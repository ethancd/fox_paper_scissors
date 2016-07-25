var TutorialChat = React.createClass({
  getInitialState: function() {
    return { rawInnerHtmlMessages: [] };
  },
  render: function() {
    return (
      <ul id="tutorial-messages">
        {this.state.rawInnerHtmlMessages.map(function(message, i){ 
          return <TutorialMessage content={message} key={i} />
        })}
      </ul>
    );
  },
  componentDidMount: function() {
    EventsListener.listen('tutorial.message', this.publishTutorialMessage);
  },
  publishTutorialMessage: function(data) {
    if(!data.innerHtml) {
      return;
    }

    this.updateTutorialMessages({content: data.innerHtml});
  },
  updateTutorialMessages: function(data) {
    this.setState({ rawInnerHtmlMessages: this.state.rawInnerHtmlMessages.concat([data.content])});
  }
});

var TutorialMessage = React.createClass({
  rawMarkup: function () {
    var rawMarkup = this.props.content;
    return { __html: this.props.content };
  },
  render: function() {
    return (
      <li className="message" dangerouslySetInnerHTML={this.rawMarkup()}/>
    );
  },
  componentDidMount: function () {
    ReactDOM.findDOMNode(this).scrollIntoView();
  }
});