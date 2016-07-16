var subscribe = function (slug) {
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
          var new_player = JSON.parse(data.player);

          if(current_player.user_id == new_player.user_id) {
            return;
          }

          if(data.pieces) {
            Pieces = JSON.parse(data.pieces);
            createHtmlPieces();
            initializePieces();
          }

          setPiecesToPosition(data.position);
          setPlayerName(new_player);
          break;
        case "position_update":
          setPiecesToPosition(data.position);
          BoardListener.send("position.updated", {color: data.color});
          break;
      };
    }
  });
}

var getSlug = function() {
  var match = window.location.pathname.match(/[0-9|a-f]{8}/);

  return match && match[0];
};


$(document).on('turbolinks:load', function() {
  var slug = getSlug();
  if (slug) {
    subscribe(slug);
  }
});