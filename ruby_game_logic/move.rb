class Move
  attr_reader :piece, :destination

  def initialize(piece, destination)
    @piece = piece
    @destination = destination
  end
end