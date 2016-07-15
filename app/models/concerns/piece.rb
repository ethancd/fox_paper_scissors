class Piece
  attr_reader :type, :color, :position
  attr_writer :position

  def initialize(type, color, position)
    @type = type
    @color = color
    @position = position
  end

  def self.new_from_json(params)
    type = params["type"]
    color = params["color"]
    position = params["position"].map(&:to_i)

    self.new(type, color, position)
  end

  def legal_moves(board)
    moves = []
    #gives the legal moves for this piece on a given board
    board.adjacent_spaces(self.position).map do |space|
      move = Move.new(self, space)
      moves.push(move) if board.legal_move?(move)
    end

    moves
  end
end