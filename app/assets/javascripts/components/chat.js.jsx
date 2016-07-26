var Chat = React.createClass({
  render: function() {
    return (
      <div id="chat">
        <ChatMessages initialMessages={this.props.initialMessages}/>
        <ChatForm chatId={this.props.chatId} initialButtonAction={this.props.initialButtonAction}/>
      </div>
    );
  }
});