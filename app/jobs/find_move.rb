class FindMove < ActiveJob::Base
  queue_as :ai

  def perform(game)
    ai = game.players.find { |player| player.ai? }
    delta = ai.move(game.board.position, ai.color)

    if !delta.nil?
      game.moves.create!({delta: delta, player_id: ai.id })
    else 
      color = (ai.color == "red") ? "blue" : "red"
      ActionCable.server.broadcast "game_#{game.slug}", {
        action: "checkmate",
        winner: color
      }
    end
  end
end