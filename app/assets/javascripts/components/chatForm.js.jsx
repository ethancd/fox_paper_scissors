var ChatForm = React.createClass({
  getInitialState: function() {
    return {value: ""};
  },
  render: function() {
    return (
      <form onChange={this.handleChange}>
        <textarea onKeyPress={this.sendMessageIfEnter} value={this.state.value}/>
        <GameButton initialAction={this.props.initialButtonAction}/>
        <button className="send" onClick={this.sendMessage}>Send</button>
      </form>
    );
  },
  handleChange: function(event) {
    this.setState({value: event.target.value});
  },
  sendMessageIfEnter: function (event) {
    if(event.key == "Enter" && !event.shiftKey) {
      this.sendMessage(event);
    }
  },
  sendMessage: function (event) {
    event.preventDefault();
    if (!this.state.value.trim()) {
      return;
    }
    
    $.post('/message', { 
      "author_id": Cookies.get('user_id'),
      "chat_id": this.props.chatId,
      "text": this.state.value
    });

    this.setState({value: ""});
  }
});