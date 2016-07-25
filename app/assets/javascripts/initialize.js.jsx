$(document).on('turbolinks:load', function() {
  if ($('.tutorial-area').length) {
    new Tutorial().initialize();
    ReactDOM.render(<TutorialChat />, document.getElementById('tutorial-chat-container'));
  } else {
    var turnTracker = document.getElementById('turn-tracker');

    if(turnTracker) {
      var initialColor = turnTracker.getAttribute("data-initial-color");
      var turnMarker = ReactDOM.render(<TurnMarker initialColor={initialColor} />, turnTracker);
    }

    new PlayerNames().initialize();
    new Chat($('.chat')).initialize();
    new GameButton($('button.game')).initialize();
  }

  new Board($('.board'), turnMarker).initialize();
});