module AI
  include GameGrammar

  attr_accessor :random

  def move(board_position, side, random=false)
    if random
      random_move(board_position, side)
    else
      fake_timed_move(board_position, side)
    end
  end

  def fake_timed_move(board_position, side)
    begin
      require "timeout"
      Timeout::timeout(5) do
        loop do
          1 + 1
        end 
      end
    rescue Timeout::Error => e
      return random_move(board_position, side)
    end
  end

  def timed_move(board_position, side)
    puts "Thinking..."

    node = GameNode.new(board_position, side) 
    possible_moves = node.children.shuffle
    depth = 3
    deepest_move = possible_moves.sample.causal_move

    begin
      require "timeout"
      Timeout::timeout(5) do
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

  def random_move(board_position, side)
    node = GameNode.new(side[0] + board_position) 
    possible_nodes = node.children.shuffle;

    new_node = find_checkmate_move(possible_nodes, side)
    if new_node
      return new_node.causal_delta
    end

    return possible_nodes.sample.causal_delta
  end

  def find_move(possible_nodes, side, depth)
    node = find_checkmate_move(possible_moves, side)
    return EvaluatedMove.new(node.causal_move, :winning) if node

    node = find_winning_move(possible_moves, side, depth)
    return EvaluatedMove.new(node.causal_move, :winning) if node

    non_losing_moves = find_all_non_losing_moves(possible_moves, side, depth)
    possible_moves = non_losing_moves if non_losing_moves.length != 0

    node = find_minimax_move(possible_moves, side, depth - 2)
    return EvaluatedMove.new(node.causal_move)
  end

  def find_checkmate_move(possible_nodes, side)
    possible_nodes.find{ |child| winning_side(child.game_position)}
  end

  def find_winning_move(possible_nodes, side, depth)
    possible_nodes.find{ |child| child.winning_node?(side, depth) }
  end

  def find_all_non_losing_moves(possible_nodes, side, depth)
    possible_nodes.find_all { |child| !child.losing_node?(side, depth) }
  end

  def find_minimax_move(possible_nodes, side, depth)
    possible_nodes.max_by do |child| 
      child.simple_score_node(side)
    end
  end
end