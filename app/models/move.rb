class Move < ApplicationRecord
  include GameGrammar

  belongs_to :game
  belongs_to :player
end
