//when $el gets deleted/removed from page,
//these js should get destroyed
//+ removed from Pieces array

//leaving it for react to deal with! hahaha

var Piece = function(color, type, position){
  this.initialize = function() {
    this.$el = $("." + color + "." + type);

    this.color = color;
    this.type = type;

    // this.originalPosition = position;
    // this.position = position;

    // this.moveToPosition();
    this.attachHandlers();

    return this;
  };

  this.attachHandlers = function() {
    BoardListener.listen("node.clicked", this.submitMove.bind(this));
    BoardListener.listen("reset", this.resetPiece.bind(this));

    this.$el.on('click', function() {
      if (this.color === "red") {
        this.highlight()
      }
    }.bind(this));
  };

  this.highlight = function() {
    if (!this.matchesTurnColor(this.$el, $('.turn-tracker'))) {
      return;
    }
    //TODO: validate your own pieces are the one you're clicking
    this.$el.toggleClass("highlighted")
    $('.piece').not(this.$el).removeClass("highlighted");

    BoardListener.send("piece.clicked", {
      position: this.position,
      active: this.$el.hasClass("highlighted")
    });
  };

  this.submitMove = function(data) {
    if (!this.$el.hasClass("highlighted")) {
      return;
    }

    var target = this.getPosition(data.node);
    var turn = $(".turn-tracker").hasClass("red") ? "red" : "blue";

    var data = {
      slug: window.location.pathname.match(/[0-9|a-f]{8}/)[0],
      move: {
        target: target,
        piece: this.position
      }
    };

    this.movePiece(target)

    $.post('/play/move/', data, function(response) {
      if (!response.success) {
        this.unMovePiece()
        alert("Invalid move, sorry");
        return
      }

      if(response.victory) {
        alert("Congratulations, you win!")
        return
      }

      if(response.move) {
        var targetPiece = response.move.piece;
        var piece = Pieces.find(function(p) {
          return p.color == targetPiece.color && p.type == targetPiece.type;
        });

        piece.highlight();

        setTimeout(function() {
          piece.movePiece(response.move.target);
          $('.node').removeClass("highlighted");
        }, 1000);
      }
    }.bind(this));
  }

  this.movePiece = function(target) {
    if (!this.$el.hasClass("highlighted")) {
      return;
    }

    this.priorPosition = this.position;
    this.position = target;
    this.moveToPosition();
    BoardListener.send("piece.moved", {color: this.color});

    this.$el.removeClass("highlighted")
  };

  this.unMovePiece = function () {
    this.position = this.priorPosition;
    this.moveToPosition();

    BoardListener.send("piece.unmoved", {color: this.color})
  }

  this.moveToPosition = function() {
    var $target = $('.node').filter(function(i, el) {
      var coords = this.getPosition($(el));
      return this.isSameSpace(this.position, coords);
    }.bind(this))

    this.$el.detach();
    $target.append(this.$el);
  };

  this.getPosition = function(node) {
    return node.attr("id").match(/\d/g);
  }

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
  };

  this.serialize = function() {
    return {
      position: this.position,
      type: this.type,
      color: this.color
    };
  }
};

var Pieces = [];

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

  if (Pieces.length) {
    Pieces = [];
  }
  
  for (var i = 0; i < colors.length; i++) {
    for (var j = 0; j < types.length; j++) {
      var piece = new Piece(colors[i], types[j], positions[i*3 + j]).initialize();
      Pieces.push(piece);
    }
  }
};

var getPieceData = function() {
  var pieceData = [];

  for (var i = 0; i < Pieces.length; i++) {
    var piece = Pieces[i];

    pieceData.push(piece.serialize())
  }

  return pieceData;
}

$(document).on('turbolinks:load', function () {
  generatePieces();
})