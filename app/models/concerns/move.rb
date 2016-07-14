class Move
  attr_reader :piece, :target

  def initialize(piece, target)
    @piece = piece
    @target = target
  end

  def self.new_from_json(params)
    piece = Piece.new_from_json(params["piece"])
    target = params["target"].map(&:to_i)

    self.new(piece, target)
  end
end