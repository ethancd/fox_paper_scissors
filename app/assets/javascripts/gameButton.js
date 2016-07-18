var attachHandlers = function() {
  $("button.game.new-game").on('click', function() {
    if($(event.target).prop("disabled")) {
      return;
    }

    var data = {
      slug: window.location.pathname.match(/[0-9|a-f]{8}/)[0],
    };

    $.post('/play/create/', data);
    
    disableNewGameButton();
  });
};

var enableNewGameButton = function() {
  $("button.game").prop("disabled", false);
};

var disableNewGameButton = function() {
  $("button.game").prop("disabled", true);
};

$(document).on('turbolinks:load', function() {
  attachHandlers();
});