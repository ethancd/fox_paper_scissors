var Initializer = function() {
  this.initialize = function() {
    if ($('.tutorial-area').length) {
      this.initializeTutorial();
    } else {
      this.initializePlay();
    }
  };

  this.initializeTutorial = function() {
    ReactDOM.render(<TutorialChat />, document.getElementById('tutorial-chat-container'));
    new Tutorial().initialize();

    new Board($('.board')).initialize();
  };

  this.initializePlay = function() {
    var turnMarker = this.initializeTurnMarker();
    var firstPlayer = this.initializeFirstPlayer();
    var secondPlayer = this.initializeSecondPlayer();
    this.initializeChat();

    new Players([firstPlayer, secondPlayer]).initialize();
    new Board($('.board'), turnMarker).initialize();

    gameSubscribe(Helpers.getSlug());
    chatSubscribe($('#chat-container'));
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

  this.initializeChat = function() {
    var chatContainer = document.getElementById('chat-container');
    var chatId = chatContainer.getAttribute("data-chat-id");
    var initialMessages = chatContainer.getAttribute("data-initial-messages");
    var initialButtonAction = chatContainer.getAttribute("data-initial-button-action");
    var chat = <Chat chatId={chatId} initialMessages={initialMessages} initialButtonAction={initialButtonAction}/>;

    return ReactDOM.render(chat, chatContainer);
  }
};

$(document).on('ready', function() {
  new Initializer().initialize();
});