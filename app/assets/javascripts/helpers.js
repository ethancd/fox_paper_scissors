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
  }
};