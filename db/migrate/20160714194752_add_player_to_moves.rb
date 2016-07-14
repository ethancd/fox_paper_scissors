class AddPlayerToMoves < ActiveRecord::Migration[5.0]
  def change
    add_reference :moves, :player, foreign_key: true
  end
end
