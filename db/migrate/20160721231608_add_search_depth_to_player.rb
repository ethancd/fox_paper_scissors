class AddSearchDepthToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :search_depth, :integer
  end
end
