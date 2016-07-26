var Players = function(playerNames){
  this.initialize = function() {
    this.playerNames = playerNames;
    EventsListener.listen("player.joined", this.playerJoinedGame.bind(this));
    EventsListener.listen("players.swapped", this.swapPlayers.bind(this));
  };

  this.playerJoinedGame = function(data) {
    var newPlayer = JSON.parse(data.player);

    if(!newPlayer) {
      return;
    }

    if (!this.vacancy()) {
      return;
    }

    if(this.samePlayer(newPlayer)) {
      this.tellUserToShare();
    } else {
      EventsListener.send('set.player.name', {userName: newPlayer.user_name})
      EventsListener.send('board.initialized', {position: data.position})
      EventsListener.send('position.updated', {position: data.position, color: "red"})
    }
  };

  this.swapPlayers = function() {
    this.modifyCurrentPlayerProperties();

    var firstState = this.playerNames[0].state;
    var secondState = this.playerNames[1].state;

    this.playerNames[0].setState(secondState);
    this.playerNames[1].setState(firstState);
  };

  this.modifyCurrentPlayerProperties = function() {
    CurrentPlayer.color = Helpers.swapColor(CurrentPlayer.color);
    CurrentPlayer.first = !CurrentPlayer.first;
  };

  this.vacancy = function() {
    return _.some(this.playerNames, function(playerName) {
      return playerName.isVacant();
    });
  };

  this.samePlayer = function(newPlayer) {
    return CurrentPlayer && CurrentPlayer.user_id === newPlayer.user_id;
  };

  this.tellUserToShare = function() {
    EventsListener.send('chat.message', { text: "Share this page's url with a friend to start playing: " + window.location });
  };
};