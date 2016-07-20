var PlayerNames = function(){
  this.initialize = function() {
    this.attachHandlers();
  };

  this.attachHandlers = function() {
    EventsListener.listen('player.changed', this.setPlayerName.bind(this))
    EventsListener.listen('game.won', this.addStar.bind(this))
    EventsListener.listen("player.joined", this.playerJoinedGame.bind(this));
    EventsListener.listen("players.swapped", this.swapPlayers.bind(this));
  };

  this.addStar = function(data) {
    var $winnerNameEl = $('.player-name').filter(function() {
      return $(this).text().match(data.winner);
    })

    var currentScore = $winnerNameEl.attr('data-content');
    $winnerNameEl.attr('data-content', currentScore + "*");
  }

  this.setPlayerName = function(data) {
    var $el = $('.player-name.waiting');
    if (!$el.length) {
      return;
    }

    var player = data.player;

    $el.removeClass("waiting")
    $el.addClass(player.color).text(player.user_name + " (" + this.getNoun(player) + ")");
  };

  this.getNoun = function(player) {
    if(!current_player) {
      return "Them";
    } 

    return current_player.user_id === player.user_id ? "You" : "Them";
  };

  this.samePlayer = function(data) {
    return current_player && current_player.user_id === new_player.user_id;
  };

  this.tellUserToShare = function() {
    if($('.player-name.waiting').length) {
      EventsListener.send('chat.message', { text: "Share this page's url with a friend to start playing: " + window.location });
    }
  };

  this.playerJoinedGame = function(data) {
    var newPlayer = JSON.parse(data.player);

    if(!newPlayer) {
      return;
    }

    if(this.samePlayer(data)) {
      this.tellUserToShare();
      return;
    }

    this.setPlayerName(newPlayer);

    if(data.pieces) {
      Pieces = JSON.parse(data.pieces);
      createHtmlPieces();
      initializePieces();
    }

    EventsListener.send('position.updated', {position: data.position, color: Helpers.swapColor(newPlayer.color)})
  };

  this.swapPlayers = function() {
    current_player.color = Helpers.swapColor(current_player.color);
    current_player.first = !current_player.first;

    var redName = $(".player-name.red").text();
    var redWins = $(".player-name.red").attr("data-content")
    var blueName =  $(".player-name.blue").text();
    var blueWins = $(".player-name.blue").attr("data-content")

    $(".player-name.red").text(blueName).attr("data-content", blueWins);
    $(".player-name.blue").text(redName).attr("data-content", redWins);
  };
};

$(document).on('turbolinks:load', function() {
  new PlayerNames().initialize();
})