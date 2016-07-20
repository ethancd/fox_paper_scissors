var PlayerName = function(){
  this.initialize = function() {
    this.attachHandlers();
  };

  this.attachHandlers = function() {
    EventsListener.listen('player.changed', this.setPlayerName.bind(this))
  };

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
};

$(document).on('turbolinks:load', function() {
  new PlayerName().initialize();
})