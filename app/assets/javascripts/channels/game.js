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
          BoardListener.send("position.updated", {color: data.color});
          break;
        case "checkmate":
          enableNewGameButton();
          displayMessage(buildMessage({
            message: "Checkmate! " + data.winner + " wins!"
          }));
          break;
        case "player_swap":
          disableNewGameButton();
          swapPlayers();
      };
    }
  });
}

var getSlug = function() {
  var match = window.location.pathname.match(/[0-9|a-f]{8}/);

  return match && match[0];
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
};

var swapPlayers = function() {
  current_player.color = (current_player.color == "red" ? "blue" : "red")
  current_player.first = !current_player.first

  var redName = $(".player-name.red").text();
  var blueName =  $(".player-name.blue").text();

  $(".player-name.red").text(blueName);
  $(".player-name.blue").text(redName);
};

$(document).on('turbolinks:load', function() {
  var slug = getSlug();
  if (slug) {
    gameSubscribe(slug);
  }
});