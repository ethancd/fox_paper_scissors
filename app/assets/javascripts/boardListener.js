var BoardListener = {
  registeredCallbacks: {},
  send: function(messageName, data) {
    if (this.registeredCallbacks[messageName] === undefined) {
      return;
    }

    for (var i = 0; i < this.registeredCallbacks[messageName].length; i++) {
      this.registeredCallbacks[messageName][i].call(this, data);
    }
  },
  listen: function(messageName, callback) {
    if (this.registeredCallbacks[messageName] === undefined) {
      this.registeredCallbacks[messageName] = [];
    }

    this.registeredCallbacks[messageName].push(callback);
  }
};