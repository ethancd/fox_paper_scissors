class FindMove
  @queue = :ai

  def self.perform(game_id)
    puts "========PERFORM~~~~~~~~~~========="
    puts game_id
    puts "========~~~~~~~~~~========="

    ActionCable.server.broadcast "messages", {action: "move", message: game_id }

    # game = Game.find(game_id)
    # ai = game.players.find { |player| player.ai? }

    # delta = ai.move(game.board, ai.color)

    # game.moves.create!({delta: delta, player_id: ai.id })
  end
end