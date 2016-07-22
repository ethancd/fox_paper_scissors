class Board < ApplicationRecord
  include GameGrammar

  belongs_to :game, autosave: true

  after_initialize :setup_board

  STARTING_POSITION = "ahbyxr".freeze
  PIECE_COLORS = [:red, :blue]
  PIECE_TYPES = [:rock, :paper, :scissors]

  def setup_board
    if position.nil?
      update({position: STARTING_POSITION})
    end

    @pieces = get_pieces(position)
  end

  def reset_board
    update({position: STARTING_POSITION})
    @pieces = get_pieces(position)
  end

  def get_pieces(position)
    pieces = []
    index = 0

    PIECE_COLORS.each do |color|
      PIECE_TYPES.each do |type|
        piece = Piece.new(color, type, get_spot(position[index]))

        pieces.push(piece)
        index += 1
      end
    end

    return pieces
  end

  def pieces
    @pieces ||= get_pieces(position)
  end

  def checkmate?(side)
    over?(get_game_position(side, position))
  end
end