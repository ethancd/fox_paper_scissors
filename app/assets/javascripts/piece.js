var Piece = function(color, type){
  this.initialize = function() {
    this.$el = $("." + color + "." + type);
    this.attachHandlers();
  };

  this.attachHandlers = function() {
    BoardListener.listen("node.clicked", this.movePiece.bind(this));

    this.$el.on('click', function () {
      //validate your own pieces are the one you're clicking
      $(this).toggleClass("highlighted")
      $('.piece').not(this).removeClass("highlighted");

      BoardListener.send("piece.clicked", {
        piece: $(this),
        active: $(this).hasClass("highlighted")
      })
    });
  };

  this.movePiece = function(data) {
    console.log("piece moved");
    //if piece is highlighted
    //get pos of data.node
    //$.css pos of piece to equal pos of node
  }
};

var generatePieces = function() {
  var types = ["rock", "paper", "scissors"];
  var colors = ["red", "blue"];

  for (var i = 0; i < colors.length; i++) {
    for (var j = 0; j < types.length; j++) {
      var piece = new Piece(colors[i], types[j]).initialize();
    }
  }
};

$(document).on('turbolinks:load', function () {
  generatePieces();
})