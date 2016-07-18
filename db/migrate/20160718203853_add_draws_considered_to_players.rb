class AddDrawsConsideredToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :draws_considered, :integer, array: true, default: []
  end
end
