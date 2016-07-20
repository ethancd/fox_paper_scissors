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
    this.attachPieceHandlers();

    return this;
  };

  this.enemyMap = {
    "rock": "paper",
    "paper": "scissors",
    "scissors": "rock"
  };

  this.attachPieceHandlers = function() {
    EventsListener.listen("node.clicked", this.submitMove.bind(this));
    EventsListener.listen("reset", this.resetPiece.bind(this));
    EventsListener.listen("check.threatened", this.checkThreatened.bind(this));
    EventsListener.listen("position.updated", this.checkThreatened.bind(this));
    EventsListener.listen("piece.launched", this.launchPiece.bind(this));

    this.$el.on('click', function() {
      if (current_player && current_player.color === this.color) {
        this.highlight()
      }
    }.bind(this));
  };

  this.launchPiece = function(data) {
    var delta = data.delta;
    var origin = getCoords(delta[0]);
    var target = getCoords(delta[delta.length - 1]);

    if (this.isInSpace(origin)) {
      this.highlight(true);
      this.delayedMove(target, data.tickMs);
    } 
  }

  this.highlight = function(skipValidation) {
    if (!skipValidation && !this.matchesTurnColor(this.$el, $('.turn-marker')) || this.$el.prop("disabled")) {
      return;
    }

    this.$el.toggleClass("highlighted")
    $('.piece').not(this.$el).removeClass("highlighted");
    $('.node').removeClass("highlighted");

    if(this.$el.hasClass("highlighted") && this.isMobile()) {
      var legalNodes = this.getLegalNodes();
      EventsListener.send("piece.clicked", { nodes: legalNodes });
    }
  };

  this.getLegalNodes = function() {
    return $('.node').filter(this.isLegalNode.bind(this));
  };

  this.isLegalNode = function(i, node) {
    var occupied = $(node).children().length;
    var space = Helpers.getPositionFromNode($(node));
    var adjacent = this.isAdjacent(space);
    var threatened = this.getEnemy().isAdjacent(space);

    return !occupied && adjacent && !threatened; 
  };

  this.isAdjacent = function(space) {
    var distance = (Math.abs(this.position[0] - space[0]) + Math.abs(this.position[1] - space[1]));
    return distance === 2;
  };

  this.isInSpace = function(position) {
    return _.isEqual(this.position, position);
  };

  this.submitMove = function(data) {
    if (!this.$el.hasClass("highlighted")) {
      return;
    }

    var target = Helpers.getPositionFromNode(data.node);
    var turn = $(".turn-marker").hasClass("red") ? "red" : "blue";

    var data = {
      slug: Helpers.getSlug(),
      move: {
        target: target,
        piece: this.position
      }
    };

    this.movePiece(target)

    $.post('/play/move/', data);
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
    EventsListener.send("piece.moved", {color: this.color});

    this.$el.removeClass("highlighted")
  };

  this.unMovePiece = function () {
    this.position = this.priorPosition;
    this.moveToPosition();

    EventsListener.send("piece.unmoved", {color: this.color})
  }

  this.moveToPosition = function() {
    var $target = $('.node').filter(function(i, el) {
      var coords = Helpers.getPositionFromNode($(el));
      return this.isInSpace(coords);
    }.bind(this))

    this.$el.detach();
    $target.append(this.$el);

    EventsListener.send("check.threatened");
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
    return this.isAdjacent(this.getEnemy().position);
  };

  this.getEnemy = function () {
    var enemyColor = Helpers.swapColor(this.color);
    var enemyType = this.enemyMap[this.type];

    return Pieces.find(function(piece) {
      return piece.color == enemyColor && piece.type == enemyType;
    });
  };
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

$(document).on('turbolinks:load', function () {
  initializePieces();
})