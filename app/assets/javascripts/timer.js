var Timer = function (){
  this.initialize = function() {
    this.turnTrackerEl = $('.turn-tracker');
    this.startTurnTracker();
    BoardListener.listen("piece.moved", this.toggleTurnTracker.bind(this));
    BoardListener.listen("reset", this.startTurnTracker.bind(this));
  };

  this.startTurnTracker = function () {
    this.toggleTurnTracker({color: "blue"});
  }
  
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