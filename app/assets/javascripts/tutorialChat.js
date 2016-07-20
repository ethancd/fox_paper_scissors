var TutorialChat = function() {
  this.initialize = function() {
    this.attachHandlers();
    EventsListener.send('tutorial.chat.ready');
  };
  
  this.attachHandlers = function() {
    EventsListener.listen('tutorial.message', this.publishTutorialMessage.bind(this));
  };

  this.publishTutorialMessage = function(data) {
    if(!data.text) {
      return;
    }

    var messageNode = this.buildTutorialMessage(data.text);
    setTimeout(this.displayTutorialMessage.bind(this, messageNode), data.tickMs);
  };

  this.buildTutorialMessage = function(text) {
    var $el = $("<li/>", { class: "message" });

    $el.html(text);
    return $el;
  };

  this.displayTutorialMessage = function(messageNode) {
    $(".tutorial-messages").append(messageNode)
    $(".tutorial-messages").animate({scrollTop: $('.tutorial-messages').prop("scrollHeight")}, 500)
  };
};

$(document).on('turbolinks:load', function () {
  if ($('.tutorial-messages').length) {
    new TutorialChat().initialize();
  }
})