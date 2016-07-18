module AI
  include GameGrammar

  attr_accessor :fuzzy

  AI_SEARCH_DEPTH = 6
  FUZZY_STANDARD_DEVIATION = GameNode::MAX_SCORE / 20.0

  def move(board_position, side, options = {})
    @fuzzy = options[:fuzzy]
    @side = side
    @full_cache = is_cache_full?
    node = GameNode.new(get_game_position(side, board_position))

    get_minimax_move(node, AI_SEARCH_DEPTH, GameNode::MIN_SCORE, GameNode::MAX_SCORE)
  end

  def is_cache_full?
    memory = $redis.info("memory")
    memory["used_memory"].to_i > 20_000_000
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
    cached_node = check_cache(node, depth, min_limit, max_limit)
    return cached_node if cached_node
      
    node.score = node.simple_score(@side)
    if node.game_over?(node.score) || depth == 0
      cache_node(depth, node, :exact)
      return node 
    end
     
    if node.side == @side
      score_type = :min
      node.score = min_limit if node.initial_delta.nil?
      best_node = node

      node.children.each do |child|
        potential_node = get_minimax_score(child, depth - 1, best_node.score, max_limit)

        best_node = potential_node if is_better(potential_node.score, best_node.score)
        if best_node.score > max_limit
          cache_node(depth, best_node, :max)
          return best_node 
        elsif potential_node.score > min_limit
          score_type = :exact
        end
      end

      cache_node(depth, best_node, score_type)

      return best_node
    else
      score_type = :max
      node.score = max_limit if node.initial_delta.nil?
      worst_node = node

      node.children.each do |child|
        potential_node = get_minimax_score(child, depth - 1, min_limit, worst_node.score)

        worst_node = potential_node if is_worse(potential_node.score, worst_node.score)
        if worst_node.score < min_limit
          cache_node(depth, worst_node, :min)
          return worst_node 
        elsif potential_node.score > min_limit
          score_type = :exact;
        end
      end

      cache_node(depth, worst_node, score_type)

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

  def check_cache(node, depth, min_limit, max_limit)
    return unless $redis.exists(node.game_position)
    entry = $redis.hgetall(node.game_position)

    return unless entry["depth"].to_i >= depth

    entry_score = entry["score"].to_f
    case entry["type"].to_sym
      when :exact
        node.score = entry_score
        return node
      when :min
        if entry_score <= min_limit
          node.score = entry_score.to_f
          return node
        end
      when :max
        if entry_score >= max_limit
          node.score = entry_score.to_f
          return node
        end
      end
  end

  def cache_node(depth, node, score_type)
    return if @full_cache

    if $redis.exists(node.game_position)
      if depth < $redis.hget(node.game_position, "depth").to_i
        return
      end
    end

    $redis.hmset(node.game_position,
      :depth, depth,
      :type, score_type,
      :score, node.score.round(2)
    )
  end

# minimax algorithm from https://www.cs.cornell.edu/courses/cs312/2002sp/lectures/rec21.htm
# transposition table (aka position-value cache) algorithm from http://web.archive.org/web/20070822204120/www.seanet.com/~brucemo/topics/hashing.htm
end