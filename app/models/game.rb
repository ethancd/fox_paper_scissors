class Game < ApplicationRecord
  has_one :board
  has_many :players
  has_many :moves
  

end