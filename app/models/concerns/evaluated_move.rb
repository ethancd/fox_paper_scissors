class EvaluatedMove
  attr_reader :move, :evaluation

  def initialize(move, evaluation = nil)
    @move = move
    @evaluation = evaluation
  end
end