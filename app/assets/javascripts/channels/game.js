var gameSubscribe = function (slug) {
  App.game = App.cable.subscriptions.create({
      channel: "GameChannel",
      game_slug: slug
    }, {
    connected: function() {
      //Called when the subscription is ready for use on the server
    },
    disconnected: function () {
      //Called when the subscription has been terminated by the server
    },
    received: function(data) {
      //Called when there's incoming data on the websocket for this channel

      switch(data.action) {
        case "player_joined_game":
          playerJoinedGame(data)
          break;
        case "position_update":
          setPiecesToPosition(data.position);
          EventsListener.send("position.updated", {color: data.color});
          EventsListener.send('enable.button', {buttonClass: "offer-draw"})
          break;
        case "checkmate":
          disablePieces();
          EventsListener.send('enable.button', {buttonClass: "new-game"})
          addStarToWinner(data.winner);
          displayMessage(buildMessage({
            message: "Checkmate! " + data.winner + " wins!"
          }));
          break;
        case "draw_offered":
          displayMessage(buildMessage({
            message: data.offerer_name + " offers a draw."
          }));
          
          if(data.offerer_id != current_player.user_id) {
            EventsListener.send('enable.button', {buttonClass: "accept-draw"})
          }
          break;
        case "draw_accepted":
          disablePieces();
          EventsListener.send('enable.button', {buttonClass: "new-game"})
          displayMessage(buildMessage({
            message: "It's an agreed-upon draw."
          }));
          break;
        case "draw_considered":
            displayMessage(buildMessage({
              message: "dauntless_drone: " + data.message
            }));
          break;
        case "player_swap":
          EventsListener.send('enable.button', {buttonClass: "offer-draw"})
          swapPlayers();
          break;
      };
    }
  });
}

var addStarToWinner = function (winner) {
  var $winnerNameEl = $('.player-name').filter(function() {
    return $(this).text().match(winner);
  })

  var currentScore = $winnerNameEl.attr('data-content');
  $winnerNameEl.attr('data-content', currentScore + "*");
};

var playerJoinedGame = function(data) {
  var new_player = JSON.parse(data.player);

  if(!new_player) {
    return;
  }

  if(current_player && current_player.user_id == new_player.user_id) {
    if($('.player-name.waiting').length) {
      displayMessage(buildMessage({
        message: "Share this page's url with a friend to start playing: " + window.location
      }));
    } else {
      EventsListener.send('enable.button', {buttonClass: "offer-draw"})
    }
    return;
  }

  if(data.pieces) {
    Pieces = JSON.parse(data.pieces);
    createHtmlPieces();
    initializePieces();
  }

  setPiecesToPosition(data.position);
  setPlayerName(new_player);
  EventsListener.send('enable.button', {buttonClass: "offer-draw"})
};

var swapPlayers = function() {
  current_player.color = (current_player.color == "red" ? "blue" : "red")
  current_player.first = !current_player.first

  var redName = $(".player-name.red").text();
  var redWins = $(".player-name.red").attr("data-content")
  var blueName =  $(".player-name.blue").text();
  var blueWins = $(".player-name.blue").attr("data-content")

  $(".player-name.red").text(blueName).attr("data-content", blueWins);
  $(".player-name.blue").text(redName).attr("data-content", redWins);
};

$(document).on('turbolinks:load', function() {
  var slug = Helpers.getSlug();
  if (slug) {
    gameSubscribe(slug);
  }
});