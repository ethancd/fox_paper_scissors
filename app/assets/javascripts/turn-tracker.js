var TurnTracker = function (){
  this.initialize = function() {
    this.turnMarkerEl = $('.turn-marker');

    EventsListener.listen("piece.moved", this.toggleTurnMarker.bind(this));
    EventsListener.listen("position.updated", this.toggleTurnMarker.bind(this));
    EventsListener.listen("piece.unmoved", this.resetTurnMarker.bind(this));
  };
  
  this.toggleTurnMarker = function(data) {
    var newColor = Helpers.swapColor(data.color);

    this.turnMarkerEl.removeClass(data.color);
    this.turnMarkerEl.addClass(newColor);
  };

  this.resetTurnMarker = function(data) {
    this.turnMarkerEl.removeClass("red blue");
    this.turnMarkerEl.addClass(data.color);
  }
};


$(document).on('turbolinks:load', function() {
  new TurnTracker().initialize();
})