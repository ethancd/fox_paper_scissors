var Board = function(){
  this.initialize = function() {
    this.attachHandlers();
  };

  this.attachHandlers =  function() {
    $('.node').on('click', this.nodeClicked);

    EventsListener.listen("piece.clicked", this.highlightLegalNodes.bind(this));
    EventsListener.listen("game.over", disablePieces);
    EventsListener.listen("position.updated", setPiecesByData);
  };

  this.nodeClicked = function() {
    if($(this).hasClass("highlighted")) {
      $('.node').removeClass("highlighted");
      EventsListener.send("node.clicked", { node: $(this)});
    }
  }

  this.highlightLegalNodes = function(data) {
    $(data.nodes).addClass("highlighted");
  };
};

var getThreatenedPieces = function (activeColor) {
  return _.filter(Pieces, function(piece) {
    return piece.color === activeColor && piece.isThreatened();
  });
};

var getPieceData = function() {
  var pieceData = [];

  for (var i = 0; i < Pieces.length; i++) {
    var piece = Pieces[i];

    pieceData.push(piece.serialize())
  }

  return pieceData;
}

var setPiecesByData = function(data) {
  setPiecesToPosition(data.position);
};

var setPiecesToPosition = function(position) {
  enablePieces();
  for (var i = 0; i < Pieces.length; i++) {
    var piece = Pieces[i]
    coords = getCoords(position[i]);
    piece.position = coords;
    piece.moveToPosition();
  }
};

var disablePieces = function() {
  $('.piece').prop("disabled", true);
};

var enablePieces = function() {
  $('.piece').prop("disabled", false);
};

var initializePieces = function() { 
  for (var i = 0; i < Pieces.length; i++) {
    var pieceData = Pieces[i]
    var piece = new Piece(pieceData.color, pieceData.type, pieceData.position).initialize();
    Pieces[i] = piece;
  }
};

var createHtmlPieces = function() {
  for (var i = 0; i < Pieces.length; i++) {
    var pieceData = Pieces[i]
    var $pieceEl = $("<div>", {"class": "piece " + pieceData.color + " " + pieceData.type });
    
    var $target = $('.node').filter(function(i, el) {
      var coords = Helpers.getPositionFromNode($(el));
      return _.isEqual(pieceData.position, coords);
    }.bind(this))

    $target.append($pieceEl);
  }
}


$(document).on('turbolinks:load', function() {
  new Board().initialize();
})