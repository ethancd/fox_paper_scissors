class FindMove
  @queue = :ai

  def self.perform(game_id)
    game = Game.find(game_id)

    ai = AI.new
    move = ai.move(game.board, game.side)

    game.addMove(move)
  end
end