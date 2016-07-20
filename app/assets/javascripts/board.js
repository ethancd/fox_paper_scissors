var Board = function(){
  this.initialize = function() {
    this.attachHandlers();
  };

  this.attachHandlers =  function() {
    EventsListener.listen("piece.clicked", this.highlightLegalSquares.bind(this));

    $('.node').on('click', function () {
      if($(this).hasClass("highlighted")) {
        $('.node').removeClass("highlighted");
        EventsListener.send("node.clicked", { node: $(this)});
      }
    });

    $('button.reset').on('click', function() {
      EventsListener.send("reset")
    });
  };

  this.highlightLegalSquares = function(data) {
    $('.node').removeClass("highlighted");

    if(!data.active) {
      return;
    }

    var piece = data.piece;

    if(!piece.isMobile()) {
      return;
    }

    var enemy = piece.getEnemy();

    $('.node').each(function(i, el) {
      if ($(el).children().length) {
        return;
      }

      var coords = $(el).attr("id").match(/\d/g);
      var adjacent = isAdjacent(coords, piece.position);
      var threatened = isAdjacent(coords, enemy.position);

      if(adjacent && !threatened) {
        $(el).addClass("highlighted");
      }
    }.bind(this));

  };
};

var isAdjacent = function(pos1, pos2) {
  return 2 == (Math.abs(pos1[0] - pos2[0]) + Math.abs(pos1[1] - pos2[1]))
}


$(document).on('turbolinks:load', function() {
  new Board().initialize();
})