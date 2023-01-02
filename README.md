# Fox Paper Scissors

Fox Paper Scissors is an original game that combines the [non-transitivity][transitivity] of Rock Paper Scissors with the chasing mechanics of traditional [fox games][fox games].

[transitivity]: https://en.wikipedia.org/wiki/Nontransitive_game
[fox games]: https://en.wikipedia.org/wiki/Fox_games

This project is a Rails-backed site that lets you play online against an AI or a friend.

## Tech 

* Ruby-on-Rails 5
  * ActiveJob (delayed jobs)
  * ActionCable (WebSockets integration)
* Postgres + Redis
* JavaScript
  * JQuery
  * React
  * Lodash
* Sass / CSS / HTML


## Features

* Automated tutorial/demo games on the home page

![homepage screenshot](/app/assets/images/preview_image.png?raw=true)

* Play against another user in real time (via websockets)
* Real time chat (also websockets)
* Play against an AI (written in Ruby, implementing minimax tree search with alpha-beta pruning and a transposition table stored in Redis)


## TODO

* Refactor database schema
  * include Match object, parent to Game object, to allow playing multiple sequential games on the same url
  * change `has_many :players` relation on Game object to `has_one :first_player` and `has_one :second_player`
  * add persistent win history to Player objects
* Add configurable difficulty (search depth) for the AI
* Improve piece animations
* Continue refactoring JavaScript to use React components
* Add [quiescence search][quiescence] for AI

[quiescence]: https://en.wikipedia.org/wiki/Quiescence_search
