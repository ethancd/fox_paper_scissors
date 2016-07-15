class GameNode
  include GameGrammar

  attr_reader :game_position, :board_position, :next_mover_side, :causal_delta

  def initialize(game_position, causal_delta = nil)
    @game_position = game_position
    @next_mover_side = get_side_from_initial(game_position[0])
    @board_position = game_position[1..6]
    @causal_delta = causal_delta
  end

  def losing_node?(evaluator, depth)
    # if(!book[@code].nil? && !book[@code].is_a?(Array))
    #   return book[@code] == :losing
    # end

    if over?(@game_position)
      verdict = winning_side(@game_position) != evaluator
      
      # book[@code] = :losing if verdict
      return verdict
    end

    if (depth <= 0)
      return nil
    end

    if self.next_mover_side == evaluator
      verdict = self.children.all? do |node|
        node.losing_node?(evaluator, depth - 1)
      end
    else
      verdict = self.children.any? do |node| 
        node.losing_node?(evaluator, depth - 1)
      end
    end

    # book[@code] = :losing if verdict
    return verdict
  end

  def winning_node?(evaluator, depth)    
    # if(!book[@code].nil? && !book[@code].is_a?(Array))
    #   return book[@code] == :winning
    # end

    if over?(@game_position)
      verdict = winning_side(@game_position) == evaluator
      
      # book[@code] = :winning if verdict
      return verdict
    end

    if (depth <= 0)
      return nil
    end

    if self.next_mover_side == evaluator
      verdict = self.children.any? do |node| 
        node.winning_node?(evaluator, depth - 1)
      end
    else
      verdict = self.children.all? do |node| 
        node.winning_node?(evaluator, depth - 1)
      end
    end

    # book[@code] = :winning if verdict
    return verdict
  end

  # def score_node(evaluator, depth)
  #   #the more children it has, the better
  #   #0 children is checkmated, == loss, == 0
  #   #all losing children also == 0
  #   #all winning children == 100

  #   # if(book[@code].is_a?(Array) && book[@code].length - 1 >= depth)
  #   #   return book[@code][-1]
  #   # end

  #   value = 0
  #   return value if (depth <= 0)

  #   adjustment = 0
  #   self.children.each do |node| 
  #     if (node.losing_node?(book, evaluator, depth - 1))
  #       adjustment -= CHILD_NODE_VALUE
  #     else
  #       adjustment += CHILD_NODE_VALUE * node.score_node(book, evaluator, depth - 1)
  #     end
  #   end

  #   value = [value + adjustment, MAX_NON_WINNING_VALUE].min

  #   # if (book[@code] != :winning && book[@code] != :losing)
  #   #   book[@code] ||= []
  #   #   book[@code][depth] = value
  #   # end

  #   return self.next_mover_side == evaluator ? value : 1 - value
  # end

  # def score_node(evaluator, depth)
  #   return nil if depth <= 0 
  # end

  def simple_score_node(side)
    our_moves = get_legal_move_count(@game_position)
    their_moves = get_legal_move_count(swap_sides(@game_position))

    get_weighted_score(our_moves, their_moves)
  end

  def get_weighted_score(our_moves, their_moves)
    Math.log(our_moves, 2) - Math.log(their_moves, 2)
  end

  # This method generates an array of all moves that can be made after
  # the current move.
  def children
    children = []

    get_legal_deltas(@game_position).each do |delta|
      position = apply_delta_to_game_position(@game_position, delta)
      children << GameNode.new(position, delta)
    end

    children
  end

  def other_side(side)
    side == "red" ? "blue" : "red"
  end
end