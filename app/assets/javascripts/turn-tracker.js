var TurnTracker = function (){
  this.initialize = function() {
    this.turnMarkerEl = $('.turn-marker');

    EventsListener.listen("piece.moved", this.setTurnMarker.bind(this));
    EventsListener.listen("position.updated", this.setTurnMarker.bind(this));
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