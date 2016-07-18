var attachHandlers = function() {
  $("button.game.new-game").on('click', createNewGame);
  $("button.game.offer-draw").on('click', offerDraw);
  $("button.game.accept-draw").on('click', acceptDraw);
};

var createNewGame = function(event) {
  if($(event.target).prop("disabled")) {
    return;
  }

  var data = {
    slug: window.location.pathname.match(/[0-9|a-f]{8}/)[0],
  };

  $.post('/play/create/', data);
  
  disableNewGameButton();
};

var offerDraw = function(event) {
  if($(event.target).prop("disabled")) {
    return;
  }

  var data = {
    slug: window.location.pathname.match(/[0-9|a-f]{8}/)[0],
  };

  $.post('/play/offer-draw/', data);
  
  disableOfferDrawButton();
};

var acceptDraw = function(event) {
  if($(event.target).prop("disabled")) {
    return;
  }

  var data = {
    slug: window.location.pathname.match(/[0-9|a-f]{8}/)[0],
  };

  $.post('/play/accept-draw/', data);
  
  disableAcceptDrawButton();
};

var enableNewGameButton = function() {
  $("button.new-game").prop("disabled", false);
};

var disableNewGameButton = function() {
  $("button.new-game").prop("disabled", true);
};

var enableOfferDrawButton = function () {
  $("button.offer-draw").prop("disabled", false);
};

var disableOfferDrawButton = function () {
  $("button.offer-draw").prop("disabled", true);
};

var enableAcceptDrawButton = function () {
  $("button.accept-draw").prop("disabled", false);
};

var disableAcceptDrawButton = function () {
  $("button.accept-draw").prop("disabled", true);
};


$(document).on('turbolinks:load', function() {
  attachHandlers();
});