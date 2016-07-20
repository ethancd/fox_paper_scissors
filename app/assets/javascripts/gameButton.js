var GameButton = function(){
  this.initialize = function() {
    this.attachHandlers();
  };

  this.buttonClasses = [
    "new-game",
    "offer-draw",
    "accept-draw"
  ];

  this.attachHandlers = function() {
    $("button.game.new-game").on('click', this.createNewGame.bind(this));
    $("button.game.offer-draw").on('click', this.offerDraw);
    $("button.game.accept-draw").on('click', this.acceptDraw);
    EventsListener.listen('button.modified', this.modifyButton.bind(this))
    EventsListener.listen('enable.button', this.setActiveButton.bind(this))
  };

  this.setActiveButton = function(data) {
    _.each(this.buttonClasses, function(buttonClass) {
      this.toggleGameButton(buttonClass, buttonClass === data.buttonClass);
    }.bind(this));
  };

  this.modifyButton = function(data) {
    this.toggleGameButton(data.buttonClass, data.enable);
  };

  this.gameButtonAction = function(event, url, buttonClass) {
    if($(event.target).prop("disabled")) {
      return;
    }

    $.post(url, { slug: Helpers.getSlug() });
    this.toggleGameButton(buttonClass, false);
  };

  this.createNewGame = function(event) {
    this.gameButtonAction(event, '/play/create/', "new-game");
  };

  this.offerDraw = function(event) {
    this.gameButtonAction(event, '/play/offer-draw/', "offer-draw");
  };

  this.acceptDraw = function(event) {
    this.gameButtonAction(event, '/play/accept-draw/', "accept-draw");
  };

  this.toggleGameButton = function(type, enabled) {
    $("button." + type).prop("disabled", !enabled);
  };
};

$(document).on('turbolinks:load', function() {
  new GameButton().initialize();
});