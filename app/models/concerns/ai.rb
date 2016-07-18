module AI
  include GameGrammar

  attr_accessor :fuzzy

  AI_SEARCH_DEPTH = 5
  FUZZY_STANDARD_DEVIATION = GameNode::MAX_SCORE / 20.0

  def move(board_position, side, options = {})
    @fuzzy = options[:fuzzy]
    @side = side
    node = GameNode.new(get_game_position(side, board_position))

    get_minimax_move(node, AI_SEARCH_DEPTH, GameNode::MIN_SCORE, GameNode::MAX_SCORE)
  end

  def get_minimax_move(node, depth, min_limit, max_limit)
    best_node = get_minimax_score(node, depth, min_limit, max_limit)

    if best_node.losing?(@side)
      return random_move(node) 
    end

    best_node.initial_delta
  end

  def random_move(node)
    children = node.children
    return nil if children.length == 0

    children.sample.initial_delta
  end

  def get_minimax_score(node, depth, min_limit, max_limit)
    node.score = node.simple_score(@side)
    return node if node.game_over?(node.score) || depth == 0
     
    if node.side == @side
      node.score = min_limit if node.initial_delta.nil?
      best_node = node

      node.children.each do |child|
        potential_node = get_minimax_score(child, depth - 1, best_node.score, max_limit)

        best_node = potential_node if is_better(potential_node.score, best_node.score)
        return best_node if best_node.score > max_limit
      end

      return best_node
    else
      node.score = max_limit if node.initial_delta.nil?
      worst_node = node

      node.children.each do |child|
        potential_node = get_minimax_score(child, depth - 1, min_limit, worst_node.score)

        worst_node = potential_node if is_worse(potential_node.score, worst_node.score)
        return worst_node if worst_node.score < min_limit
      end

      return worst_node
    end
  end

  def is_better(potential_score, current_score)
    if @fuzzy
      potential_score + get_fuzz > current_score
    else
      potential_score > current_score
    end
  end

  def is_worse(potential_score, current_score)
    if @fuzzy
      potential_score + get_fuzz < current_score
    else
      potential_score < current_score
    end
  end

  def get_fuzz
    @fuzz_generator ||= Rubystats::NormalDistribution.new(0, FUZZY_STANDARD_DEVIATION)

    @fuzz_generator.rng
  end

 # minimax algorithm from https://www.cs.cornell.edu/courses/cs312/2002sp/lectures/rec21.htm
 # (* the minimax value of n, searched to depth d.
 # * If the value is less than min, returns min.
 # * If greater than max, returns max. *)
 # fun minimax(n: node, d: int, min: int, max: int): int =
 #   if leaf(n) or depth=0 return evaluate(n)
 #   if n is a max node
 #      v := min
 #      for each child of n
 #         v' := minimax (child,d-1,v,max)
 #         if v' > v, v:= v'
 #         if v > max return max
 #      return v
 #   if n is a min node
 #      v := max
 #      for each child of n
 #         v' := minimax (child,d-1,min,v)
 #         if v' < v, v:= v'
 #         if v < min return min
 #      return v

  # def fake_timed_move(board_position, side)
  #   begin
  #     require "timeout"
  #     Timeout::timeout(5) do
  #       loop do
  #         1 + 1
  #       end 
  #     end
  #   rescue Timeout::Error => e
  #     return random_move(board_position, side)
  #   end
  # end

  # def timed_move(board_position, side)
  #   puts "Thinking..."

  #   node = GameNode.new(board_position, side) 
  #   possible_moves = node.children.shuffle
  #   depth = 3
  #   deepest_move = possible_moves.sample.causal_move

  #   begin
  #     require "timeout"
  #     Timeout::timeout(5) do
  #       loop do
  #         evaluated_move = find_move(possible_moves, side, depth)

  #         if evaluated_move.evaluation == :winning 
  #           return evaluated_move.move 
  #         end

  #         deepest_move = evaluated_move.move

  #         puts "#{depth} layers deep"
  #         depth += 1
  #       end 
  #     end
  #   rescue Timeout::Error => e
  #     return deepest_move
  #   end

  #   return deepest_move
  # end

  # def random_move(board_position, side)
  #   node = GameNode.new(side[0] + board_position) 
  #   possible_nodes = node.children.shuffle;

  #   new_node = find_checkmate_move(possible_nodes, side)
  #   if new_node
  #     return new_node.causal_delta
  #   end

  #   return possible_nodes.sample.causal_delta
  # end

  # def find_move(possible_nodes, side, depth)
  #   node = find_checkmate_move(possible_moves, side)
  #   return EvaluatedMove.new(node.causal_move, :winning) if node

  #   node = find_winning_move(possible_moves, side, depth)
  #   return EvaluatedMove.new(node.causal_move, :winning) if node

  #   non_losing_moves = find_all_non_losing_moves(possible_moves, side, depth)
  #   possible_moves = non_losing_moves if non_losing_moves.length != 0

  #   node = find_minimax_move(possible_moves, side, depth - 2)
  #   return EvaluatedMove.new(node.causal_move)
  # end

  # def find_checkmate_move(possible_nodes, side)
  #   possible_nodes.find{ |child| winning_side(child.game_position)}
  # end

  # def find_winning_move(possible_nodes, side, depth)
  #   possible_nodes.find{ |child| child.winning_node?(side, depth) }
  # end

  # def find_all_non_losing_moves(possible_nodes, side, depth)
  #   possible_nodes.find_all { |child| !child.losing_node?(side, depth) }
  # end

  # def find_minimax_move(possible_nodes, side, depth)
  #   possible_nodes.max_by do |child| 
  #     child.simple_score_node(side)
  #   end
  # end
end