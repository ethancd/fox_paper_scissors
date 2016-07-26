var Initializer = function() {
  this.initialize = function() {
    if ($('.tutorial-area').length) {
      this.initializeTutorial();
    } else {
      this.initializePlay();
    }
  };

  this.initializeTutorial = function() {
    new Tutorial().initialize();
    ReactDOM.render(<TutorialChat />, document.getElementById('tutorial-chat-container'));

    new Board($('.board')).initialize();
  };

  this.initializePlay = function() {
    var turnMarker = this.initializeTurnMarker();
    var firstPlayer = this.initializeFirstPlayer();
    var secondPlayer = this.initializeSecondPlayer();
    this.initializeGameButton();

    new Players([firstPlayer, secondPlayer]).initialize();
    new Chat($('.chat')).initialize();

    new Board($('.board'), turnMarker).initialize();
  };

  this.initializeTurnMarker = function() {
    var turnTracker = document.getElementById('turn-tracker');
    var initialColor = turnTracker.getAttribute("data-initial-color");
    return ReactDOM.render(<TurnMarker initialColor={initialColor} />, turnTracker);
  };
  
  this.initializeFirstPlayer = function() {
    var firstPlayerContainer = document.getElementById('first-player-container');
    var firstInitialName = firstPlayerContainer.getAttribute("data-initial-name");
    return ReactDOM.render(<PlayerName color="red" initialName={firstInitialName} />, firstPlayerContainer);
  };
  
  this.initializeSecondPlayer = function() {
    var secondPlayerContainer = document.getElementById('second-player-container');
    var secondInitialName = secondPlayerContainer.getAttribute("data-initial-name");
    return ReactDOM.render(<PlayerName color="blue" initialName={secondInitialName} />, secondPlayerContainer);
  };
  
  this.initializeGameButton = function() {
    var gameButtonContainer = document.getElementById('game-button-container');
    var initialAction = gameButtonContainer.getAttribute("data-initial-action");
    return ReactDOM.render(<GameButton initialAction={initialAction} />, gameButtonContainer);
  };
};

$(document).on('turbolinks:load', function() {
  new Initializer().initialize();
});