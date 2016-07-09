var Board = function(){
  this.initialize = function() {
    this.attachHandlers();
  };

  this.attachHandlers =  function() {
    BoardListener.listen("piece.clicked", this.highlightLegalSquares.bind(this));

    $('.node').on('click', function () {
      if($(this).hasClass("highlighted")) {
        $('.piece').add('.node').removeClass("highlighted");
        BoardListener.send("node.clicked", { node: $(this)});
      }
    });
  };

  this.highlightLegalSquares = function(data) {
    $('.node').addClass("highlighted");
  };
};


$(document).on('turbolinks:load', function() {
  var board = new Board().initialize();
})