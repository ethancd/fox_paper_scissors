class AddUserToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :user_id, :uuid
  end
end
