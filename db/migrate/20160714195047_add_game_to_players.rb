class AddGameToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_reference :players, :game, foreign_key: true
  end
end
