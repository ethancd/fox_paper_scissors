var Helpers = {
  getSlug: function() {
    var match = window.location.pathname.match(/[0-9|a-f]{8}/);
    return match && match[0];
  },
  swapColor: function(color) {
    if (color === "red") {
      return "blue";
    }

    if (color === "blue"){
      return "red";
    }
  },
  getPositionFromNode: function(node) {
    var stringCoords = node.attr("id").match(/\d/g);
    return _.map(stringCoords, _.parseInt);
  },
  getCoordinatesFromLetter: function(letter) {
    var base = "a".charCodeAt(0);
    var index = letter.charCodeAt(0) - base;
    var coordinatesList = this.getCoordinatesList();

    return coordinatesList[index];
  },
  getCoordinatesList: function() {
    var coordinatesList = [];

    _.times(7, function(i) {
      _.times(7, function(j) {
        if (i%2 === j%2) {
          coordinatesList.push([j,i]);
        }
      })
    });

    return coordinatesList;
  }
};