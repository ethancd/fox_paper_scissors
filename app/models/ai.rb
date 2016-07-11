require_relative 'game_node'

class AI

  def initialize(options)
    @random = options[:random] || false
  end

  def move(board, side)
    if @random
      random_move(board, side)
    else
      raise "NOT YET IMPLEMENTED"
    end
  end

  def random_move(board, side)
    node = GameNode.new(board, side) 
    possible_moves = node.children.shuffle;

    new_node = find_checkmate_move(possible_moves, side)
    if new_node
      return new_node.causal_move
    end

    return possible_moves.sample.causal_move
  end

  def find_checkmate_move(possible_moves, side)
    possible_moves.find{ |child| child.board.is_in_checkmate?(other_side(side))}
  end

  def other_side(side)
    side == "red" ? "blue" : "red"
  end
end