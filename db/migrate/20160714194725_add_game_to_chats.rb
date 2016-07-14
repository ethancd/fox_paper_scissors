class AddGameToChats < ActiveRecord::Migration[5.0]
  def change
    add_reference :chats, :game, foreign_key: true
  end
end
