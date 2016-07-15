class Move < ApplicationRecord
  include GameGrammar

  belongs_to :game
  belongs_to :player

  def get_delta(piece, target)
    [piece, target].each { |position| position.map!(&:to_i) }
    "#{get_letter(piece)}_#{get_letter(target)}"
  end
end
