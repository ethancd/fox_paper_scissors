class AddResultToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :result, :integer
  end
end
