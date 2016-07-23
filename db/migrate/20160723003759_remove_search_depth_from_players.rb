class RemoveSearchDepthFromPlayers < ActiveRecord::Migration[5.0]
  def change
    remove_column :players, :search_depth, :integer
  end
end
