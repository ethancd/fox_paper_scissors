class Board < ApplicationRecord
  include GameGrammar

  belongs_to :game

  #STARTING_POSITION = "ahbyxr".freeze
  STARTING_POSITION = "acbywx".freeze

  after_initialize :setup_board

  def setup_board
    self[:position] ||= STARTING_POSITION
    @pieces = get_pieces(self[:position])
  end

  def piece_colors
    [:red, :blue]
  end

  def piece_types
    [:rock, :paper, :scissors]
  end

  def get_pieces(position)
    pieces = []
    index = 0

    piece_colors.each do |color|
      piece_types.each do |type|
        piece = Piece.new(color, type, get_spot(position[index]))

        pieces.push(piece)
        index += 1
      end
    end

    return pieces
  end

  def pieces
    @pieces ||= get_pieces(self[:position])
  end

  def position
    self[:position]
  end

end
