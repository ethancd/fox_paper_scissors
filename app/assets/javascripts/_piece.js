var Piece = function(options, $el, board){
  this.initialize = function() {
    this.$el = $el;
    this.board = board;

    this.color = options.color;
    this.type = options.type;
    this.originalPosition = options.position;
    this.position = options.position;

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
    EventsListener.listen("check.threatened", this.checkThreatened.bind(this));
    EventsListener.listen("position.updated", this.checkThreatened.bind(this));
    EventsListener.listen("piece.highlight", this.processHighlightRequest.bind(this));
    EventsListener.listen("piece.move", this.processMoveRequest.bind(this));

    this.$el.on('click', function() {
      if (CurrentPlayer && CurrentPlayer.color === this.color) {
        this.highlight()
      }
    }.bind(this));
  };

  this.processHighlightRequest = function(data) {
    var origin = Helpers.getCoordinatesFromLetter(data.delta[0]);
    if (this.isInSpace(origin)) {
      this.highlight(true);
    }
  };

  this.processMoveRequest = function(data) {
    var origin = Helpers.getCoordinatesFromLetter(data.delta[0]);
    var target = Helpers.getCoordinatesFromLetter(data.delta[data.delta.length - 1]);

    if (this.isInSpace(origin)) {
      this.movePiece(target);
      $('.node').removeClass("highlighted");
    }
  };

  this.highlight = function(skipValidation) {
    if (!skipValidation && !this.matchesTurnColor() || this.$el.prop("disabled")) {
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

  this.matchesTurnColor = function() {
    return this.color === this.board.turnColor();
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

  this.movePiece = function(target) {
    if (!this.$el.hasClass("highlighted")) {
      return;
    }

    this.priorPosition = this.position;
    this.position = target;
    this.moveToPosition();
    EventsListener.send("piece.moved", {color: this.color});
    EventsListener.send("check.threatened");

    this.$el.removeClass("highlighted")
  };

  this.moveToPosition = function() {
    var $target = $('.node').filter(function(i, el) {
      var coords = Helpers.getPositionFromNode($(el));
      return this.isInSpace(coords);
    }.bind(this))

    this.$el.detach();
    $target.append(this.$el);
  };

  this.isMobile = function () {
    var threatenedPieces = this.board.getThreatenedPieces(this.color);

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

    return this.board.pieces.find(function(piece) {
      return piece.color == enemyColor && piece.type == enemyType;
    });
  };

  this.disable = function () {
    this.$el.prop("disabled", true);
  };

  this.enable = function () {
    this.$el.prop("disabled", false);
  };
};