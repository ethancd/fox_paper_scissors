var Tutorial = function(){
  this.initialize = function() {
    this.runTutorial();
  };

  this.tickMs = 3000;
  this.gameCounter = 0;
  this.moveCounter = 0;

  this.runTutorial = function() {
    this.sendTutorialMessage(this.getGameTitle());
    setTimeout(this.tickTutorial.bind(this), this.tickMs / 2)
  };
  
  this.sendTutorialMessage = function(message, delay) {
    if (delay) {
      setTimeout(this.sendTutorialMessage.bind(this, message), delay);
    } else {   
      EventsListener.send('tutorial.message', { innerHtml: message });
    }
  };

  this.tickTutorial = function () {
    var exampleGame = this.exampleGames[this.gameCounter];
    var move = exampleGame[this.moveCounter][0];
    var message = exampleGame[this.moveCounter][1];

    this.executeTutorialStep(move, message);
    this.moveCounter++;
    this.setUpNextAction(exampleGame);
  };

  this.setUpNextAction = function (exampleGame) {
    if (this.moveCounter >= _.size(exampleGame)) {
      this.resetCounters();
      this.startNewGame();
    } else {
      setTimeout(this.tickTutorial.bind(this), this.tickMs);
    }
  };

  this.resetCounters = function () {
    this.moveCounter = 0;
    this.gameCounter++;

    if (this.gameCounter >= this.exampleGames.length) {
      this.gameCounter = 0;
    }
  };

  this.startNewGame = function() {
    this.sendTutorialMessage(this.getGameTitle(), this.tickMs * 2);

    setTimeout(function() {
      EventsListener.send('position.updated', { position: StartingPosition });
    }.bind(this), this.tickMs * 2);
    
    setTimeout(this.tickTutorial.bind(this), this.tickMs * 3);
  };

  this.executeTutorialStep = function(move, message) {
    EventsListener.send('piece.highlight', { delta: move })

    setTimeout(function() {
      EventsListener.send('piece.move', { delta: move })
    }, this.tickMs / 3);

    this.sendTutorialMessage(message, this.tickMs / 3);
  };

  this.getGameTitle = function() {
    return "<span>Demo Game " + (this.gameCounter + 1) + ":</span>";
  };

  this.getCommentary = function(activePieceDescription, passivePieceDescription, checkmate) {
    var firstSpan = this.buildSpan.apply(this, activePieceDescription.split(" "));
    var secondSpan = this.buildSpan.apply(this, passivePieceDescription.split(" "));
    var action = checkmate ? "checkmate!" : "check."

    return firstSpan + " puts " + secondSpan + " in " + action;
  };

  this.buildSpan = function(color, type) {
    var capitalizedColor = this.capitalizeString(color);
    var capitalizedType = this.capitalizeString(type);
    var firstTag = "<span class='" + color + "'>";
    var text = capitalizedColor + " " + capitalizedType;
    var secondTag = "</span>";

    return firstTag + text + secondTag;
  };

  this.capitalizeString = function (string) {
    return string.charAt(0).toUpperCase() + string.slice(1)
  };

  this.quickBlueScissorsWin = [
    ["h_i", ""],
    ["r_q", ""],
    ["b_f", ""],
    ["q_m", this.getCommentary("blue scissors", "red paper")],
    ["i_e", ""],
    ["m_i", this.getCommentary("blue scissors", "red paper", true)]
  ];

  this.mediumRedRockWin = [
    ["b_f", ""],
    ["r_q", ""],
    ["a_e", ""],
    ["q_m", ""],
    ["e_i", this.getCommentary("red rock", "blue scissors")],
    ["m_t", ""],
    ["i_p", this.getCommentary("red rock", "blue scissors")],
    ["t_u", ""],
    ["f_m", ""],
    ["x_w", this.getCommentary("blue paper", "red rock")],
    ["p_q", this.getCommentary("red rock", "blue scissors", true)]
  ];

  this.longMirrorOpeningRedWin = [
    ["a_e", ""],
    ["y_u", ""],
    ["h_l", ""],
    ["x_t", ""],
    ["b_i", ""],
    ["r_q", ""],
    ["i_p", this.getCommentary("red scissors", "blue paper")],
    ["t_x", ""],
    ["e_i", ""],
    ["u_t", this.getCommentary("blue rock", "red scissors")],
    ["p_o", ""],
    ["x_u", ""],
    ["i_m", this.getCommentary("red rock", "blue scissors")],
    ["q_r", ""],
    ["l_p", this.getCommentary("red paper", "blue rock")],
    ["t_x", ""],
    ["p_t", this.getCommentary("red paper", "blue rock")],
    ["x_y", ""],
    ["t_x", this.getCommentary("red paper", "blue rock", true)]
  ];

  this.exampleGames = [
    this.quickBlueScissorsWin,
    this.mediumRedRockWin,
    this.longMirrorOpeningRedWin
  ];
};