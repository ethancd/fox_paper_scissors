class FindMove
  @queue = :ai

  def self.perform(game_id)
    puts "========PERFORM~~~~~~~~~~========="
    puts game_id
    puts "========~~~~~~~~~~========="

    game = Game.find(game_id)
    ai = game.players.find { |player| player.ai? }

    delta = ai.move(game.board.position, ai.color)

    @move = game.moves.create!({delta: delta, player_id: ai.id })

    puts "========ITWORKEDMOTHERFUCKERS~~~~~~~~~~========="
    puts @move.id
    puts "========~~~~~~~~~~========="
  end
end