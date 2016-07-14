class AddGameToBoards < ActiveRecord::Migration[5.0]
  def change
    add_reference :boards, :game, foreign_key: true
  end
end
