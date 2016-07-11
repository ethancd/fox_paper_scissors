require_relative 'game_node'
require_relative 'evaluated_move'

class AI

  def initialize(options)
    @random = options[:random] || false
  end

  def move(board, side)
    if @random
      random_move(board, side)
    else
      timed_move(board, side)
    end
  end

  def timed_move(board, side)
    puts "Thinking..."

    node = GameNode.new(board, side) 
    possible_moves = node.children.shuffle
    depth = 3
    deepest_move = possible_moves.sample.causal_move

    begin
      require_relative "timeout"
      Timeout::timeout(15) do
        loop do
          evaluated_move = find_move(possible_moves, side, depth)

          if evaluated_move.evaluation == :winning 
            return evaluated_move.move 
          end

          deepest_move = evaluated_move.move

          puts "#{depth} layers deep"
          depth += 1
        end 
      end
    rescue Timeout::Error => e
      return deepest_move
    end

    return deepest_move
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

  def find_move(possible_moves, side, depth)
    node = find_checkmate_move(possible_moves, side)
    return EvaluatedMove.new(node.causal_move, :winning) if node

    node = find_winning_move(possible_moves, side, depth)
    return EvaluatedMove.new(node.causal_move, :winning) if node

    non_losing_moves = find_all_non_losing_moves(possible_moves, side, depth)
    possible_moves = non_losing_moves if non_losing_moves.length != 0

    node = find_minimax_move(possible_moves, side, depth - 2)
    return EvaluatedMove.new(node.causal_move)
  end

  def find_checkmate_move(possible_moves, side)
    possible_moves.find{ |child| child.board.is_in_checkmate?(other_side(side))}
  end

  def find_winning_move(possible_moves, side, depth)
    possible_moves.find{ |child| child.winning_node?(side, depth) }
  end

  def find_all_non_losing_moves(possible_moves, side, depth)
    possible_moves.find_all { |child| !child.losing_node?(side, depth) }
  end

  def find_minimax_move(possible_moves, side, depth)
    possible_moves.max_by do |child| 
      child.simple_score_node(side, depth)
    end
  end

  def other_side(side)
    side == "red" ? "blue" : "red"
  end
end