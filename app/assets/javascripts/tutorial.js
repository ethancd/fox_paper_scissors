var tickMs = 3000;

var runTutorial = function(exampleGames) {
  var gameCounter = 0;
  var moveCounter = 0;

  displayTutorialMessage(buildTutorialMessage("<span>Demo Game 1:</span>"));

  setTimeout(function() {
    tickTutorial(exampleGames, gameCounter, moveCounter);
  }, tickMs / 2)
}

var tickTutorial = function (exampleGames, gameCounter, moveCounter) {
  var exampleGame = exampleGames[gameCounter];
  executeTutorialStep(exampleGame.moves[moveCounter]);
  publishTutorialMessage(exampleGame.messages[moveCounter]);
  moveCounter++;

  if (moveCounter >= exampleGame.moves.length) {
    moveCounter = 0;
    gameCounter++;

    if (gameCounter >= exampleGames.length) {
      gameCounter = 0;
    }

    setTimeout(function() {
      setPiecesToPosition(startingPosition)
      displayTutorialMessage(buildTutorialMessage("<span>Demo Game " + (gameCounter + 1) + ":</span>"));

      setTimeout(function() {
        tickTutorial(exampleGames, gameCounter, moveCounter);
      }, tickMs)
    }, tickMs * 2)
  } else {
    setTimeout(function() {
      tickTutorial(exampleGames, gameCounter, moveCounter);
    }, tickMs);
  }
};

var executeTutorialStep = function(delta) {
  var origin = getCoords(delta[0]);
  var target = getCoords(delta[delta.length - 1]);
  var piece = findPieceByPosition(origin);

  piece.highlight(true);
  piece.delayedMove(target, tickMs / 3);
};

var findPieceByPosition = function(position) {
  return Pieces.find(function(p) {
    return isSameSpace(position, p.position);
  });
};

var publishTutorialMessage = function(message) {
  if(!message) {
    return;
  }
  var messageNode = buildTutorialMessage(message);

  setTimeout(function() {
    displayTutorialMessage(messageNode);
  }, tickMs / 3);
};

var displayTutorialMessage = function(messageNode) {
  $(".tutorial-messages").append(messageNode)
  $(".tutorial-messages").animate({scrollTop: $('.tutorial-messages').prop("scrollHeight")}, 500)
}

var buildTutorialMessage = function(message) {
  var $el = $("<li/>", {
    class: "message"
  });

  $el.html(message);
  return $el;
};

var exampleGameQuickBlueScissorsWin = {
  moves: [
    "h_i",
    "r_q",
    "b_f",
    "q_m",
    "i_e",
    "m_i"
  ],
  messages: [
    "",
    "",
    "",
    "<span class='blue'>Blue Scissors</span> puts <span class='red'>Red Paper</span> in check.",
    "",
    "<span class='blue'>Blue Scissors</span> puts <span class='red'>Red Paper</span> in checkmate!",
  ]
};

var exampleGameMediumRedRockWin = {
  moves: [
    "b_f",
    "r_q",
    "a_e",
    "q_m",
    "e_i",
    "m_t",
    "i_p",
    "t_u",
    "f_m",
    "x_w",
    "p_q"
  ],
  messages: [
    "",
    "",
    "",
    "",
    "<span class='red'>Red Rock</span> puts <span class='blue'>Blue Scissors</span> in check.",
    "",
    "<span class='red'>Red Rock</span> puts <span class='blue'>Blue Scissors</span> in check.",
    "",
    "",
    "<span class='blue'>Blue Paper</span> puts <span class='red'>Red Rock</span> in check.",
    "<span class='red'>Red Rock</span> puts <span class='blue'>Blue Scissors</span> in checkmate!",
  ]
};

var exampleGameLongMirrorOpeningRedWin = {
  moves: [
    "a_e",
    "y_u",
    "h_l",
    "x_t",
    "b_i",
    "r_q",
    "i_p",
    "t_x",
    "e_i",
    "u_t",
    "p_o",
    "x_u",
    "i_m",
    "q_r",
    "l_p",
    "t_x",
    "p_t",
    "x_y",
    "t_x"
  ],
  messages: [
    "",
    "",
    "",
    "",
    "",
    "",
    "<span class='red'>Red Scissors</span> puts <span class='blue'>Blue Paper</span> in check.",
    "",
    "",
    "<span class='blue'>Blue Rock</span> puts <span class='red'>Red Scissors</span> in check.",
    "",
    "",
    "<span class='red'>Red Rock</span> puts <span class='blue'>Blue Scissors</span> in check.",
    "",
    "<span class='red'>Red Paper</span> puts <span class='blue'>Blue Rock</span> in check.",
    "",
    "<span class='red'>Red Paper</span> puts <span class='blue'>Blue Rock</span> in check.",
    "",
    "<span class='red'>Red Paper</span> puts <span class='blue'>Blue Rock</span> in checkmate!",
  ]
};

var exampleGames = [
  exampleGameQuickBlueScissorsWin,
  exampleGameMediumRedRockWin,
  exampleGameLongMirrorOpeningRedWin
];

$(document).on('turbolinks:load', function () {
  if ($('.tutorial-area').length) {
    runTutorial(exampleGames);
  }
})