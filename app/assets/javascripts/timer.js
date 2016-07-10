var Timer = function (){
  this.initialize = function() {
    this.turnTrackerEl = $('.turn-tracker');
    this.toggleTurnTracker({color: "blue"});
    BoardListener.listen("piece.moved", this.toggleTurnTracker.bind(this));
  };
  
  this.toggleTurnTracker = function(data) {
    this.turnTrackerEl.removeClass(data.color);

    if (data.color === "red") {
      this.turnTrackerEl.addClass("blue");
    } else if (data.color === "blue") {
      this.turnTrackerEl.addClass("red");
    }
  };
};


$(document).on('turbolinks:load', function() {
  var board = new Timer().initialize();
})