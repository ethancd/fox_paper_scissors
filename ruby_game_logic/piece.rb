require_relative 'move'

class Piece
  attr_reader :type, :owner, :pos
  attr_writer :pos

  def initialize(type, owner, pos)
    @type = type
    @owner = owner
    @pos = pos
  end

  def legal_moves(board)
    moves = []
    #gives the legal moves for this piece on a given board
    board.adjacent_spaces(self.pos).map do |space|
      move = Move.new(self, space)
      moves.push(move) if board.legal_move?(move)
    end

    moves
  end

  def to_s
    char_table = {
      fire: 'R',#\u1F525",
      water: 'B',#"\u1F30A",
      grass: 'G'#"\u1F340"
    }

    color_table = {
      fire: 31,
      water: 34,
      grass: 32
    }

    char = char_table[@type]
    color = color_table[@type]

    if(owner == :shiny)
      return char.encode('utf-8').colorize(color)
    else 
      return char.encode('utf-8').colorize(color).bg_gray()
    end
  end
end