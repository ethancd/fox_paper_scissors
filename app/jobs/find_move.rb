class FindMove < ActiveJob::Base
  queue_as :ai

  def perform(game)
    ai = game.players.find { |player| player.ai? }
    delta = ai.move(game.board.position, ai.color)
    game.moves.create!({delta: delta, player_id: ai.id })
  end
end