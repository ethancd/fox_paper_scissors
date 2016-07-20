var TurnTracker = function (){
  this.initialize = function() {
    this.turnMarkerEl = $('.turn-marker');

    BoardListener.listen("piece.moved", this.toggleTurnMarker.bind(this));
    BoardListener.listen("position.updated", this.toggleTurnMarker.bind(this));
    BoardListener.listen("piece.unmoved", this.resetTurnMarker.bind(this));
  };
  
  this.toggleTurnMarker = function(data) {
    this.turnMarkerEl.removeClass(data.color);

    if (data.color === "red") {
      this.turnMarkerEl.addClass("blue");
    } else if (data.color === "blue") {
      this.turnMarkerEl.addClass("red");
    }
  };

  this.resetTurnMarker = function(data) {
    this.turnMarkerEl.removeClass("red blue");
    this.turnMarkerEl.addClass(data.color);
  }
};


$(document).on('turbolinks:load', function() {
  var turnTracker = new TurnTracker().initialize();
})