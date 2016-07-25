var GameButton = function($el){
  this.initialize = function() {
    this.$el = $el;
    this.attachHandlers();
  };

  this.buttonText = {
    "new-game": "New Game!",
    "offer-draw": "Offer Draw",
    "accept-draw": "Accept Draw"
  };

  this.attachHandlers = function() {
    this.$el.on('click', this.activateButton.bind(this));
    EventsListener.listen('button.modified', this.modifyButton.bind(this))
    EventsListener.listen('enable.button', this.setActiveButton.bind(this))

    EventsListener.listen("game.over", function() {
      this.setActiveButton({ action: "new-game"})
    }.bind(this));

    EventsListener.listen("position.updated", function() {
      this.setActiveButton({ action: "offer-draw"})
    }.bind(this));
  };

  this.setActiveButton = function(data) {
    this.toggleGameButton(true);
    this.$el.attr("action", data.action);
    this.$el.text(this.buttonText[data.action]);
  };

  this.modifyButton = function(data) {
    this.toggleGameButton(data.enable);
  };

  this.activateButton = function(event) {
    switch(this.$el.attr("action")) {
      case "new-game": 
        this.createNewGame(event);
        break;
      case "offer-draw": 
        this.offerDraw(event);
        break;
      case "accept-draw": 
        this.acceptDraw(event);
        break;
    }
  };

  this.gameButtonAction = function(event, url) {
    if($(event.target).prop("disabled")) {
      return;
    }

    $.post(url, { slug: Helpers.getSlug() });
    this.toggleGameButton(false);
  };

  this.createNewGame = function(event) {
    this.gameButtonAction(event, '/play/create/');
  };

  this.offerDraw = function(event) {
    this.gameButtonAction(event, '/play/offer-draw/');
  };

  this.acceptDraw = function(event) {
    this.gameButtonAction(event, '/play/accept-draw/');
  };

  this.toggleGameButton = function(enabled) {
    this.$el.prop("disabled", !enabled);
  };
};