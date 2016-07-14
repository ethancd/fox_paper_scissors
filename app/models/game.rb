class Game < ApplicationRecord
  has_many :players
  has_many :users, through: :players
  has_many :moves
  has_one :board
  has_one :chat

end
