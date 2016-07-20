var TurnTracker = function (){
  this.initialize = function() {
    this.turnMarkerEl = $('.turn-marker');

    EventsListener.listen("piece.moved", this.toggleTurnMarker.bind(this));
    EventsListener.listen("position.updated", this.setTurnMarker.bind(this));
  };

  this.toggleTurnMarker = function(data) {
    var newColor = Helpers.swapColor(data.color);

    this.turnMarkerEl.removeClass(data.color);
    this.turnMarkerEl.addClass(newColor);
  };
  
  this.setTurnMarker = function(data) {
    var oldColor = Helpers.swapColor(data.color);

    this.turnMarkerEl.removeClass(oldColor);
    this.turnMarkerEl.addClass(data.color);
  };
};


$(document).on('turbolinks:load', function() {
  new TurnTracker().initialize();
})