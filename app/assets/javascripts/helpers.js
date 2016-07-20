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
    var coordinateList = getCoordinateList();

    return coordinateList[index];
  },
  getCoordinateList: function() {
    var coordinateList = [];

    _.times(7, function(i) {
      _.times(7, function(j) {
        if (i%2 === j%2) {
          coordinateList.push([j,i]);
        }
      })
    });

    return coordinateList;
  }
};