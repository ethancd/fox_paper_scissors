var chatSubscribe = function($el) {
  App.chat = App.cable.subscriptions.create({
      channel: "ChatChannel",
      chat_id: $el.attr('id')
    }, {
    received: function(data) {
      if(this.hasOwnProperty(data.action)) {
        this[data.action].call(this, data);
      }
    },
    user_joined: function(data) {
      EventsListener.send('chat.message', { text: data.text + " has joined the room." });
    },
    new_message: function(data) {
      EventsListener.send('chat.message', { text: data.text, color: data.color });
    }
  });
}

$(document).on('turbolinks:load', function() {
  chatSubscribe($('.chat'));
});
