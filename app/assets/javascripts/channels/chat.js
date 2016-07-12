App.chat = App.cable.subscriptions.create("ChatChannel", {
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
        var message = buildMessage("New user joined! Say hello!")
        displayMessage(message);
        break;
      case "new_message":
       displayMessage(buildMessage(data.message));
       break;
    };
  }
});
  

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
  $.post('/chat', { "text": $(".chat textarea").val() });

  $(".chat textarea").val("");
};

var displayMessage = function(messageNode) {
  $(".chat .messages").append(messageNode)
}

var buildMessage = function(text) {
  var $el = $("<li/>", {
    class: "message",
    text: text
  });

  //$el.css("color", data.color)
  return $el;
};

$(document).on('turbolinks:load', attachHandlers);
