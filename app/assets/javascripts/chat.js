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
  $.post('/chat', { "text": $(".chat textarea").val() }, function( data ) {
    $(".chat .messages").append(buildMessage(data))
  });

  $(".chat textarea").val("");
};

var buildMessage = function(data) {
  var $el = $("<li/>", {
    class: "message",
    text: data.text
  });

  $el.css("color", data.color)
  return $el;
}

$(document).on('turbolinks:load', attachHandlers)