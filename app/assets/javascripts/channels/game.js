var gameSubscribe = function (slug) {
  App.game = App.cable.subscriptions.create({
      channel: "GameChannel",
      game_slug: slug
    }, {
    received: function(data) {
      if(this.hasOwnProperty(data.action)) {
        this[data.action].call(this, data);
      }
    },
    player_joined_game: function (data) {
      EventsListener.send("player.joined", data);
    },
    position_update: function (data) {
      EventsListener.send("position.updated", data);
    },
    checkmate: function (data) {
      EventsListener.send('game.over', data);
      EventsListener.send('game.won', data);
      EventsListener.send('chat.message', { text: "Checkmate! " + data.winner + " wins!" });
    },
    draw_offered: function (data) {
      EventsListener.send('chat.message', { text: data.offerer_name + " offers a draw." });
      if(data.offerer_id !== CurrentPlayer.user_id) {
        EventsListener.send('enable.button', {buttonClass: "accept-draw"});
      }
    },
    draw_accepted: function (data) {
      EventsListener.send('game.over', data);
      EventsListener.send('chat.message', { text: "It's an agreed-upon draw." });
    },
    draw_considered: function (data) {
      EventsListener.send('chat.message', { text: "dauntless_drone: " + data.message });
    },
    player_swap: function (data) {
      EventsListener.send('enable.button', {buttonClass: "offer-draw"});
      EventsListener.send('players.swapped');
    }
  });
}

$(document).on('turbolinks:load', function() {
  var slug = Helpers.getSlug();
  if (slug) {
    gameSubscribe(slug);
  }
});