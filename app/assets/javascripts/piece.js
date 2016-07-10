var Piece = function(color, type, position){
  this.initialize = function() {
    this.$el = $("." + color + "." + type);

    this.color = color;

    this.originalPosition = position;
    this.position = position;

    this.moveToPosition();
    this.attachHandlers();
  };

  this.attachHandlers = function() {
    BoardListener.listen("node.clicked", this.movePiece.bind(this));
    BoardListener.listen("reset", this.resetPiece.bind(this));

    this.$el.on('click', this.highlight.bind(this));
  };

  this.highlight = function(event) {
    var el = event.currentTarget;

    if (!this.matchesTurnColor($(el), $('.turn-tracker'))) {
      return;
    }
    //validate your own pieces are the one you're clicking
    $(el).toggleClass("highlighted")
    $('.piece').not(el).removeClass("highlighted");

    BoardListener.send("piece.clicked", {
      position: this.position,
      active: $(el).hasClass("highlighted")
    });
  };

  this.movePiece = function(data) {
    if (!this.$el.hasClass("highlighted")) {
      return;
    }

    this.position = data.node.attr("id").match(/\d/g);
    this.moveToPosition();
    BoardListener.send("piece.moved", {color: this.color});

    this.$el.removeClass("highlighted")
  };

  this.moveToPosition = function() {
    var $target = $('.node').filter(function(i, el) {
      var coords = $(el).attr("id").match(/\d/g);
      return this.isSameSpace(this.position, coords);
    }.bind(this))

    this.$el.detach();
    $target.append(this.$el);
  };

  this.isSameSpace = function(pos1, pos2) {
    for (var i = 0; i < pos1.length; i++) {
      if (parseInt(pos1[i]) !== parseInt(pos2[i])) {
        return false;
      }
    }

    return true;
  };

  this.resetPiece = function() {
    this.position = this.originalPosition;
    this.moveToPosition();
  };

  this.matchesTurnColor = function(piece, tracker) {
    var colors = ["red", "blue"];
    for (var i = 0; i < colors.length; i++) {
      if (piece.hasClass(color) && tracker.hasClass(color)) {
        return true;
      }
    }
  }
};

var generatePieces = function() {
  var colors = ["red", "blue"];
  var types = ["rock", "paper", "scissors"];
  var positions = [
    [0, 0],
    [0, 2],
    [2, 0],
    [6, 6],
    [4, 6],
    [6, 4]
  ];

  for (var i = 0; i < colors.length; i++) {
    for (var j = 0; j < types.length; j++) {
      var piece = new Piece(colors[i], types[j], positions[i*3 + j]).initialize();
    }
  }
};

$(document).on('turbolinks:load', function () {
  generatePieces();
})