class GameNode
  include GameGrammar

  attr_accessor :score
  attr_reader :game_position, :board_position, :side, :causal_path, :causal_delta, :initial_delta

  WEIGHTED_LOG_BASE = 3
  MAX_SCORE = Math.log(24, WEIGHTED_LOG_BASE)
  MIN_SCORE = -Math.log(24, WEIGHTED_LOG_BASE)

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
    #ranges from -2.9 to +2.9, with Infinity and -Infinity for winning and losing
    Math.log(our_moves, WEIGHTED_LOG_BASE) - Math.log(their_moves, WEIGHTED_LOG_BASE)
  end

  def game_over?(simple_score)
    !simple_score.between?(MIN_SCORE, MAX_SCORE) 
  end

  def children
    @children ||= get_children
  end

  def get_children
    children = []

    get_legal_deltas(@game_position).each do |delta|
      position = apply_delta_to_game_position(@game_position, delta)

      children << GameNode.new(position, @causal_path + [delta])
    end

    children
  end

  def order_children(side)
    children.sort_by! { |child| child.simple_score(side) }
  end

  def losing?(side)
    @score ||= simple_score(side)
    @score <= MIN_SCORE
  end

  def winning?(side)
    @score ||= simple_score(side)
    @score >= MAX_SCORE
  end
end