//temporary i hope hope hope
//leaving it for react to deal with! hahaha

var Piece = function(color, type, position){
  this.initialize = function() {
    this.$el = $("." + color + "." + type);

    this.color = color;
    this.type = type;

    this.originalPosition = position;
    this.position = position;

    this.moveToPosition();
    this.attachHandlers();

    return this;
  };

  this.enemyMap = {
    "rock": "paper",
    "paper": "scissors",
    "scissors": "rock"
  };

  this.attachHandlers = function() {
    BoardListener.listen("node.clicked", this.submitMove.bind(this));
    BoardListener.listen("reset", this.resetPiece.bind(this));
    BoardListener.listen("check.threatened", this.checkThreatened.bind(this));
    BoardListener.listen("position.updated", this.checkThreatened.bind(this));

    this.$el.on('click', function() {
      if (current_player && (current_player.first ? this.color === "red" : this.color === "blue")) {
        this.highlight()
      }
    }.bind(this));
  };

  this.highlight = function(skipValidation) {
    if (!skipValidation && !this.matchesTurnColor(this.$el, $('.turn-tracker')) || this.$el.prop("disabled")) {
      return;
    }

    this.$el.toggleClass("highlighted")
    $('.piece').not(this.$el).removeClass("highlighted");

    BoardListener.send("piece.clicked", {
      piece: this,
      active: this.$el.hasClass("highlighted")
    });
  };

  this.submitMove = function(data) {
    if (!this.$el.hasClass("highlighted")) {
      return;
    }

    var target = getPosition(data.node);
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
        piece.delayedMove(response.move.target, 1000);
      }
    }.bind(this));
  };

  this.delayedMove = function (target, tick) {
    setTimeout(function() {
      this.movePiece(target);
      $('.node').removeClass("highlighted");
    }.bind(this), tick);
  };

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
      var coords = getPosition($(el));
      return isSameSpace(this.position, coords);
    }.bind(this))

    this.$el.detach();
    $target.append(this.$el);

    BoardListener.send("check.threatened");
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
  };

  this.isMobile = function () {
    var threatenedPieces = getThreatenedPieces(this.color);

    if (!threatenedPieces.length) {
      return true;
    }

    if (threatenedPieces.length == 1 && this.isThreatened()) {
      return true;
    }

    return false;
  };

  this.checkThreatened = function () {
    this.$el.toggleClass("threatened", this.isThreatened());
  }

  this.isThreatened = function () {
    var enemy = this.getEnemy();

    return isAdjacent(this.position, enemy.position);
  };

  this.getEnemy = function () {
    var enemyColor = this.color === "red" ? "blue" : "red";
    var enemyType = this.enemyMap[this.type];

    return Pieces.find(function(piece) {
      return piece.color == enemyColor && piece.type == enemyType;
    });
  };
};

var getThreatenedPieces = function (activeColor) {
  return $.grep(Pieces, function(piece) {
    return piece.color === activeColor && piece.isThreatened();
  });
};

var getPosition = function(node) {
  return node.attr("id").match(/\d/g);
}

var getPieceData = function() {
  var pieceData = [];

  for (var i = 0; i < Pieces.length; i++) {
    var piece = Pieces[i];

    pieceData.push(piece.serialize())
  }

  return pieceData;
}

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

var getCoords = function(letter) {
  var base = "a".charCodeAt(0);
  var index = letter.charCodeAt(0) - base;
  var coords = [
      [0,0],
      [2,0],
      [4,0],
      [6,0],
      [1,1],
      [3,1],
      [5,1],
      [0,2],
      [2,2],
      [4,2],
      [6,2],
      [1,3],
      [3,3],
      [5,3],
      [0,4],
      [2,4],
      [4,4],
      [6,4],
      [1,5],
      [3,5],
      [5,5],
      [0,6],
      [2,6],
      [4,6],
      [6,6]
  ];

  return coords[index];
}

var isSameSpace = function(pos1, pos2) {
  for (var i = 0; i < pos1.length; i++) {
    if (parseInt(pos1[i]) !== parseInt(pos2[i])) {
      return false;
    }
  }

  return true;
};

var createHtmlPieces = function() {
  for (var i = 0; i < Pieces.length; i++) {
    var pieceData = Pieces[i]
    var $pieceEl = $("<div>", {"class": "piece " + pieceData.color + " " + pieceData.type });
    
    var $target = $('.node').filter(function(i, el) {
      var coords = getPosition($(el));
      return isSameSpace(pieceData.position, coords);
    }.bind(this))

    $target.append($pieceEl);
  }
}


$(document).on('turbolinks:load', function () {
  initializePieces();
})