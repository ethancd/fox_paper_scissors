class AddGameToMoves < ActiveRecord::Migration[5.0]
  def change
    add_reference :moves, :game, foreign_key: true
  end
end
