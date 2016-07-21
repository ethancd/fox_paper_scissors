var EventsListener = {
  registeredCallbacks: {},
  send: function(messageName, data) {
    if (this.registeredCallbacks[messageName] === undefined) {
      return;
    }

    _.each(this.registeredCallbacks[messageName], function(callback) {
      callback.call(this, data);
    }.bind(this));
  },
  listen: function(messageName, callback) {
    if (this.registeredCallbacks[messageName] === undefined) {
      this.registeredCallbacks[messageName] = [];
    }

    this.registeredCallbacks[messageName].push(callback);
  }
};