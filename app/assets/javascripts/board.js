var attachHandlers = function() {
  $(".board").on('click', function() {
    $(this).toggleClass("active");
  });
};

$(document).on('turbolinks:load', attachHandlers)