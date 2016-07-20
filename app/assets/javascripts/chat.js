var Chat = function($el) {
  this.initialize = function() {
    this.$el = $el;
    this.attachHandlers();
  };

  this.attachHandlers = function() {
    this.$el.find("textarea").on('keypress', function(event) {
      if(event.which == 13) {
        event.preventDefault();
        this.sendMessage();
      }
    }.bind(this));

    this.$el.find("button.send").on('click', this.sendMessage.bind(this));

    EventsListener.listen("chat.message", this.displayMessage.bind(this));
  };

  this.sendMessage = function () {
    var $textarea = this.$el.find("textarea");
    if (!$textarea.val().trim()) {
      return;
    }
    
    $.post('/message', { 
      "author_id": Cookies.get('user_id'),
      "chat_id": this.$el.attr("id"),
      "text": $textarea.val()
    });

    $textarea.val("");
  };

  this.displayMessage = function(data) {
    var $message = this.buildMessage(data);
    this.$el.find(".messages").append($message)
    this.$el.find(".messages").animate({scrollTop: $el.find('.messages').prop("scrollHeight")}, 500)
  };

  this.buildMessage = function(data) {
    var $message = $("<li/>", {
      class: "message",
      text: data.text
    });

    if (data.color) {
      $message.css("color", data.color)
    }
    
    return $message;
  };
};


$(document).on('turbolinks:load', function() {
  if ($('.chat').length) {
    new Chat($('.chat')).initialize();
  }
});
