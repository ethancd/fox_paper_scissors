var tickMs = 2000;

var runTutorial = function(exampleGames) {
  var gameCounter = 0;
  var moveCounter = 0;

  tickTutorial(exampleGames, gameCounter, moveCounter);
}

var tickTutorial = function (exampleGames, gameCounter, moveCounter) {
  var exampleGame = exampleGames[gameCounter];
  executeTutorialStep(exampleGame[moveCounter]);
  moveCounter++;

  if (moveCounter >= exampleGame.length) {
    //declareVictory();
    moveCounter = 0;
    gameCounter++;

    if (gameCounter >= exampleGames.length) {
      gameCounter = 0;
    }

    setTimeout(function() {
      setPiecesToPosition(startingPosition)

      setTimeout(function() {
        tickTutorial(exampleGames, gameCounter, moveCounter);
      }, tickMs)
    }, tickMs * 3)
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
  piece.delayedMove(target, tickMs / 2);
};

var findPieceByPosition = function(position) {
  return Pieces.find(function(p) {
    return isSameSpace(position, p.position);
  });
};

var exampleGameQuickBlueScissorsWin = [
  "h_i",
  "r_q",
  "b_f",
  "q_m",
  "i_e",
  "m_i"
];

var exampleGameMediumRedRockWin = [
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
]

var exampleGameLongMirrorOpeningRedWin = [
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
];

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