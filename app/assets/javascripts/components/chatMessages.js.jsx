var ChatMessages = React.createClass({
  getInitialState: function() {
    var initialMessages = JSON.parse(this.props.initialMessages);
    return { messages: initialMessages || [] };
  },
  render: function() {
    return (
      <ul id="messages">
        {this.state.messages.map(function(message, i){ 
          return <ChatMessage color={message.color} text={message.text} key={i} />
        })}
      </ul>
    );
  },
  componentDidMount: function() {
    EventsListener.listen("chat.message", this.updateChatMessages);
  },
  updateChatMessages: function(data) {
    this.setState({ messages: this.state.messages.concat([data])});
  }
});

var ChatMessage = React.createClass({
  render: function() {
    return (
      <li className="message" style={this.getStyle()}>
        {this.props.text}
      </li>
    );
  },
  componentDidMount: function () {
    ReactDOM.findDOMNode(this).scrollIntoView();
  },
  getStyle: function() {
    return { color: this.props.color };
  }
});