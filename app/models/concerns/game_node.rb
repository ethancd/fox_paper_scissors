class GameNode
  include GameGrammar

  attr_accessor :score
  attr_reader :game_position, :board_position, :side, :causal_path, :causal_delta, :initial_delta

  MAX_SCORE = 5
  MIN_SCORE = -5

  def initialize(game_position, causal_path = [])
    @game_position = game_position
    @side = get_side_from_initial(game_position[0])
    @board_position = game_position[1..6]

    @causal_path = causal_path
    @initial_delta = causal_path.first
    @causal_delta = causal_path.last
  end

  def simple_score(scoring_side)
    active_move_count = get_legal_move_count(@game_position)
    passive_move_count = get_legal_move_count(swap_sides(@game_position))

    if scoring_side == @side
      get_weighted_score(active_move_count, passive_move_count)
    else
      get_weighted_score(passive_move_count, active_move_count)
    end
  end

  def get_weighted_score(our_moves, their_moves)
    #ranges from -4.6 to +4.6, with Infinity and -Infinity for winning and losing
    Math.log(our_moves, 2) - Math.log(their_moves, 2)
  end

  def game_over?(simple_score)
    !simple_score.between?(MIN_SCORE, MAX_SCORE) 
  end

  # This method generates an array of all moves that can be made after
  # the current move.
  def children
    children = []

    get_legal_deltas(@game_position).each do |delta|
      position = apply_delta_to_game_position(@game_position, delta)

      children << GameNode.new(position, @causal_path + [delta])
    end

    children.sort_by { |child| get_legal_move_count(child.game_position) }
  end

  def losing?(side)
    puts "AM I LOSING? score=#{@score} && #{@score <= MIN_SCORE}"
    @score = simple_score(side) if @score.nil?
    @score <= MIN_SCORE
  end

  def winning?(side)
    @score = simple_score(side) if @score.nil?
    @score >= MAX_SCORE
  end

  # def losing_node?(evaluator, depth)
  #   # if(!book[@code].nil? && !book[@code].is_a?(Array))
  #   #   return book[@code] == :losing
  #   # end

  #   if over?(@game_position)
  #     verdict = winning_side(@game_position) != evaluator
      
  #     # book[@code] = :losing if verdict
  #     return verdict
  #   end

  #   if (depth <= 0)
  #     return nil
  #   end

  #   if self.next_mover_side == evaluator
  #     verdict = self.children.all? do |node|
  #       node.losing_node?(evaluator, depth - 1)
  #     end
  #   else
  #     verdict = self.children.any? do |node| 
  #       node.losing_node?(evaluator, depth - 1)
  #     end
  #   end

  #   # book[@code] = :losing if verdict
  #   return verdict
  # end

  # def winning_node?(evaluator, depth)    
  #   # if(!book[@code].nil? && !book[@code].is_a?(Array))
  #   #   return book[@code] == :winning
  #   # end

  #   if over?(@game_position)
  #     verdict = winning_side(@game_position) == evaluator
      
  #     # book[@code] = :winning if verdict
  #     return verdict
  #   end

  #   if (depth <= 0)
  #     return nil
  #   end

  #   if self.next_mover_side == evaluator
  #     verdict = self.children.any? do |node| 
  #       node.winning_node?(evaluator, depth - 1)
  #     end
  #   else
  #     verdict = self.children.all? do |node| 
  #       node.winning_node?(evaluator, depth - 1)
  #     end
  #   end

  #   # book[@code] = :winning if verdict
  #   return verdict
  # end

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
end