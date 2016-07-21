var TutorialChat = function($el) {
  this.initialize = function() {
    this.$el = $el;
    this.attachHandlers();
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
    this.$el.append(messageNode)
    this.$el.animate({scrollTop: this.$el.prop("scrollHeight")}, 500)
  };
};

$(document).on('turbolinks:load', function () {
  if ($('.tutorial-messages').length) {
    new TutorialChat($(".tutorial-messages")).initialize();
  }
})