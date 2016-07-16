var setPlayerName = function(new_player) {
  var $el = $('.player-name.waiting');
  if (!$el.length) {
    return;
  }

  $el.removeClass("waiting")
  $el.text("");

  $el.addClass(new_player.color)
  $el.text(new_player.user_name + " (" + new_player.noun + ")");
};