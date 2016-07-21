var Board = function($el){
  this.initialize = function() {
    this.$el = $el;
    this.attachHandlers();

    if(StartingPosition) {
      this.initializePieces({position: StartingPosition});
    }
  };

  this.pieceColors = [ "red", "blue"];
  this.pieceTypes = ["rock", "paper", "scissors"];

  this.attachHandlers =  function() {
    $('.node').on('click', this.nodeClicked);

    EventsListener.listen("piece.clicked", this.highlightLegalNodes.bind(this));
    EventsListener.listen("game.over", this.disablePieces.bind(this));
    EventsListener.listen("position.updated", this.setPiecesToPosition.bind(this));
    EventsListener.listen("board.initialized", this.initializePieces.bind(this));
  };

  this.initializePieces = function(data) {
    this.pieces = [];

    var i = 0;
    _.each(this.pieceColors, function(color) {
      _.each(this.pieceTypes, function(type) {
        var options = {
          color: color,
          type: type,
          position: Helpers.getCoordinatesFromLetter(data.position[i])
        };

        var $piece = this.findOrCreatePiece(options);
        var piece = new Piece(options, $piece, this).initialize();

        this.pieces.push(piece);
        i++;
      }.bind(this));
    }.bind(this));
  };

  this.getThreatenedPieces = function (activeColor) {
    return _.filter(this.pieces, function(piece) {
      return piece.color === activeColor && piece.isThreatened();
    });
  };

  this.nodeClicked = function() {
    if($(this).hasClass("highlighted")) {
      $('.node').removeClass("highlighted");
      EventsListener.send("node.clicked", { node: $(this)});
    }
  };

  this.highlightLegalNodes = function(data) {
    $(data.nodes).addClass("highlighted");
  };

  this.disablePieces = function() {
    _.each(this.pieces, function(piece) {
      piece.disable();
    });
  };

  this.enablePieces = function() {
    _.each(this.pieces, function(piece) {
      piece.enable();
    });
  };

  this.setPiecesToPosition = function(data) {
    this.enablePieces();

    _.each(this.pieces, function(piece, i) {
      piece.position = Helpers.getCoordinatesFromLetter(data.position[i]);
      piece.moveToPosition();
    });
  };

  this.findOrCreatePiece = function(data) {
    var $piece = this.$el.find(".piece." + data.color + "." + data.type);

    if (!$piece.length) {
      $piece = $("<div>", {"class": "piece " + data.color + " " + data.type});
      this.appendPieceToTarget($piece, data.position);
    }

    return $piece;
  };

  this.appendPieceToTarget = function($piece, position) {
    var $target = $('.node').filter(function(i, el) {
      var coords = Helpers.getPositionFromNode($(el));
      return _.isEqual(position, coords);
    }.bind(this))

    $target.append($piece);
  };
};

$(document).on('turbolinks:load', function() {
  if($('.board').length) {
    new Board($('.board')).initialize();
  }
})