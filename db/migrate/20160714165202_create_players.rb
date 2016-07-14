class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.boolean :first

      t.timestamps
    end
  end
end
