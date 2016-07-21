var ReactTutorialChat = React.createClass({
  getInitialState: function() {
    EventsListener.listen('tutorial.message', this.publishTutorialMessage);

    return {
      rawInnerHtmlMessages: []
    }; //empty list
  },
  render: function() {
    return (
      <ul id="tutorial-messages">
        {this.state.rawInnerHtmlMessages.map(function(message, i){ 
          return <ReactTutorialMessage content={message} key={i} />
        })}
      </ul>
    );
  },
  componentDidUpdate: function() {
    // var $el = $(React.findDOMNode(this));
    // $el.animate({scrollTop: $el.prop("scrollHeight")}, 500);
  },
  publishTutorialMessage: function(data) {
    if(!data.innerHtml) {
      return;
    }

    setTimeout(this.updateTutorialMessages.bind(this, {content: data.innerHtml}), data.tickMs);
  },
  updateTutorialMessages: function(data) {
    this.setState({ rawInnerHtmlMessages: this.state.rawInnerHtmlMessages.concat([data.content])});
  },
});

var ReactTutorialMessage = React.createClass({
  rawMarkup: function () {
    var rawMarkup = this.props.content;
    return { __html: this.props.content };
  },
  render: function() {
    return (
      <li className="message" dangerouslySetInnerHTML={this.rawMarkup()}/>
    );
  }
})

$(document).on('turbolinks:load', function () {
  var tutorialChat = <ReactTutorialChat />;
  ReactDOM.render(tutorialChat, document.getElementById('tutorial-chat-container'));
})


