var Helpers = {
  getSlug: function() {
    var match = window.location.pathname.match(/[0-9|a-f]{8}/);
    return match && match[0];
  }
};