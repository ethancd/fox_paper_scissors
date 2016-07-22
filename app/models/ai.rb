class AI < Player
  include GameGrammar

  attr_accessor :fuzzy, :search_depth

  before_save :ensure_search_depth
  #after_update :broadcast_player_name_update

  DEFAULT_SEARCH_DEPTH = 4
  FUZZY_STANDARD_DEVIATION = GameNode::MAX_SCORE / 20.0
  COMPUTER_PLAYER_USER_ID = "34e1d79e-22d8-4575-b617-e9cadca20e9e".freeze

  def self.id
    COMPUTER_PLAYER_USER_ID
  end

  def ai?
    true
  end

  def ensure_search_depth
    if self.search_depth.nil?
      self.search_depth = DEFAULT_SEARCH_DEPTH
    end
  end

  # def broadcast_player_name_update
      #NYI
  # end

  def move(board_position, side, options = {})
    @fuzzy = options[:fuzzy]
    @side = side
    node = GameNode.new(get_game_position(side, board_position))

    get_minimax_move(node, DEFAULT_SEARCH_DEPTH, GameNode::MIN_SCORE, GameNode::MAX_SCORE)
  end

  def reply_to_draw_offer(game) 
    reply = { accept: false, message: "" }

    if game.moves.length < 16
      reply[:message] = replies[:too_early]
      return reply
    end

    if just_got_offered_a_draw(game)
      reply[:message] = replies[:too_frequent]
      return reply
    end

    self.draws_considered.push(game.moves.length)
    self.save

    node = GameNode.new(get_game_position(self.color, game.board.position))
    node.score = node.simple_score(self.color)

    if node.score.between?(get_drawish_min, get_drawish_max)
      reply[:message] = replies[:too_close]
    elsif node.score < get_drawish_min
      reply[:accept] = true
      if self.draws_considered.length == 1
        reply[:message] = replies[:favor]
      else
        reply[:message] = replies[:resignation]
      end
    elsif node.score > get_drawish_max
      reply[:message] = replies[:is_ahead]
    end

    reply
  end

  private
    def replies
      {
        too_early: "Draw Denial 501-NYI: not enough moves in game.",
        too_frequent: "Draw Denial 429-RUD: not enough moves between draw offers.",
        too_close: "Draw Denial 555-RCT: position uncertain; ask again in 4+ moves.",
        is_ahead: "Draw Denial 403-WIN: position advantageous; ask again in 4+ moves to dispute.",
        favor: "Draw Acceptance 200-OK: position deletarious; draw welcomed.",
        resignation: "Draw Acceptance 202-ACC: drawish position acknowledged."
      }
    end

    def just_got_offered_a_draw(game)
      return false if self.draws_considered.length == 0

      game.moves.length - self.draws_considered.last < 4
    end

    def get_drawish_min
      #as it's offered more draws, it gets more willing to accept one
      baseline = GameNode::MIN_SCORE / 10
      baseline + get_draws_modifier
    end

    def get_drawish_max
      #as it's offered more draws, it stops thinking it's advantage means as much
      baseline = GameNode::MAX_SCORE / 10
      baseline + get_draws_modifier
    end

    def get_draws_modifier
      (GameNode::MAX_SCORE / 5) * self.draws_considered.length
    end

    def get_minimax_move(node, depth, min_limit, max_limit)
      best_node = get_minimax_score(node, depth, min_limit, max_limit)

      if best_node.losing?(@side)
        return survival_move(node) 
      end

      best_node.initial_delta
    end

    def survival_move(node)
      children = node.children
      return nil if children.length == 0

      surviving_node = children.max_by do |child|
        best_node = get_minimax_score(child, AI_SEARCH_DEPTH - 1, GameNode::MIN_SCORE, GameNode::MAX_SCORE)
        best_node.causal_path.length
      end

      surviving_node.initial_delta
    end

    def random_move(node)
      children = node.children
      return nil if children.length == 0

      children.sample.initial_delta
    end

    def get_minimax_score(node, depth, min_limit, max_limit)
      cached_node = check_cache(node, depth, min_limit, max_limit)
      return cached_node if cached_node && !cached_node.initial_delta.nil?
        
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
      comparison_score = @fuzzy ? potential_score + get_fuzz : potential_score

      comparison_score > current_score
    end

    def is_worse(potential_score, current_score)
      comparison_score = @fuzzy ? potential_score + get_fuzz : potential_score

      comparison_score < current_score
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