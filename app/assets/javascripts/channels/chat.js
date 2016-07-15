var attachHandlers = function() {
  $(".chat textarea").on('keypress', function(event) {
    if(event.which == 13) {
      send();
      event.preventDefault();
    }
  });

  $(".chat button").on('click', send);
};

var send = function () {
  $.post('/message', { 
    "author_id": Cookies.get('user_id'),
    "chat_id": $(".chat").attr("id"),
    "text": $(".chat textarea").val()
  });

  $(".chat textarea").val("");
};

var displayMessage = function(messageNode) {
  $(".chat .messages").append(messageNode)
}

var buildMessage = function(data) {
  var $el = $("<li/>", {
    class: "message",
    text: data.message
  });

  $el.css("color", data.color)
  return $el;
};

var subscribe = function() {
  App.chat = App.cable.subscriptions.create({
      channel: "ChatChannel",
      chat_id: $(".chat").attr('id')
    }, {
    connected: function() {
      //Called when the subscription is ready for use on the server
    },
    disconnected: function () {
      //Called when the subscription has been terminated by the server
    },
    received: function(data) {
      //Called when there's incoming data on the websocket for this channel

      switch(data.action) {
        case "user_joined":
          var message = buildMessage(data.message + " has joined")
          displayMessage(message);
          break;
        case "new_message":
         displayMessage(buildMessage(data));
         break;
      };
    }
  });
}

$(document).on('turbolinks:load', function() {
  attachHandlers();
  subscribe();
});
