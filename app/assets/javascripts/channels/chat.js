var attachChatHandlers = function() {
  $(".chat textarea").on('keypress', function(event) {
    if(event.which == 13) {
      send();
      event.preventDefault();
    }
  });

  $(".chat button.send").on('click', send);
  EventsListener.listen("chat.message", function(data) {
    displayMessage(buildMessage(data));
  });
};

var send = function () {
  if (!$(".chat textarea").val().trim()) {
    return;
  }
  
  $.post('/message', { 
    "author_id": Cookies.get('user_id'),
    "chat_id": $(".chat").attr("id"),
    "text": $(".chat textarea").val()
  });

  $(".chat textarea").val("");
};

var displayMessage = function(messageNode) {
  $(".chat .messages").append(messageNode)
  $(".chat .messages").animate({scrollTop: $('.chat .messages').prop("scrollHeight")}, 500)
};

var buildMessage = function(data) {
  var $el = $("<li/>", {
    class: "message",
    text: data.text
  });

  if (data.color) {
    $el.css("color", data.color)
  }
  
  return $el;
};

var chatSubscribe = function() {
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
  attachChatHandlers();
  chatSubscribe();
});
