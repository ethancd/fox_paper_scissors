require_relative 'node'
require_relative 'evaluated_move'

class ComputerPlayer
  attr_reader :name, :thinking_time, :book, :depth

  def initialize(options = {})
    @should_save = options[:should_save] || true
    @random = options[:random] || false
    @thinking_time = 3
    @depth = 3
    @@book = {}

    @turn = 0
    @nodes_counted = 0

    load_book if File.exist?('book.txt')

    @name = @random ? "Rando" : "PokéBot #{@@book.count}"

    puts "I am #{name}, prepare yourself."
  end

  def move(game, side)
    if @random
      result = random_move(game, side)
    else
      result = depth_limited_move(game, side)
    end

    save_book

    @turn += 1
    return result
  end

  def timed_move(game, side)
    puts "Thinking..."

    node = BCSNode.new(game.board, side) 
    possible_moves = node.children.shuffle
    depth = 3
    deepest_move = possible_moves.sample.causal_move

    begin
      require_relative "timeout"
      Timeout::timeout(@thinking_time) do
        loop do
          evaluated_move = find_move(possible_moves, side, depth)

          return evaluated_move.move if !evaluated_move.evaluation.nil?

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

  def depth_limited_move(game, side)
    puts "Thinking..."

    node = BCSNode.new(game.board, side) 
    possible_moves = node.children.shuffle

    evaluated_move = find_move(possible_moves, side, @depth)
    return evaluated_move.move
  end

  def random_move(game, side)
    node = BCSNode.new(game.board, side) 
    possible_moves = node.children.shuffle;

    new_node = find_checkmate_move(possible_moves, side)
    if new_node
      return new_node.causal_move
    end

    return possible_moves.sample.causal_move
  end

  def find_move(possible_moves, side, depth)
    node = find_checkmate_move(possible_moves, side)
    if node
      return EvaluatedMove.new(node.causal_move, :checkmate) 
    end

    node = find_winning_move(possible_moves, side, depth)
    return EvaluatedMove.new(node.causal_move, :winning) if node

    non_losing_moves = find_all_non_losing_moves(possible_moves, side, depth)
    possible_moves = non_losing_moves if non_losing_moves.count != 0

    node = find_highest_score_move(possible_moves, side, depth - 2)
    return EvaluatedMove.new(node.causal_move)
  end

  def find_checkmate_move(possible_moves, side)
    possible_moves.find{ |child| child.board.is_in_checkmate?(other_side(side))}
  end

  def find_winning_move(possible_moves, side, depth)
    possible_moves.find{ |child| child.winning_node?(@@book, side, depth) }
  end

  def find_all_non_losing_moves(possible_moves, side, depth)
    possible_moves.find_all { |child| !child.losing_node?(@@book, side, depth) }
  end

  def find_highest_score_move(possible_moves, side, depth)
    possible_moves.max_by do |child| 
      score = child.score_node(@@book, side, depth)
      puts score
      score
    end
  end

  def other_side(side)
    side == :shiny ? :dull : :shiny
  end

  def load_book
    f = File.open("book.txt", "r")
    lines = f.readlines

    lines.each do |line|
      code, score, depth = line.match(/(\w+)=([\d\.]+)@?(\d+)?/).captures

      if score == "1" || score == "0"
        @@book[code] = score == "1" ? :winning : :losing
      else
        depth = depth.to_i
        list = Array.new(depth + 1)
        list[depth] = score.to_f
        @@book[code] = list
      end
    end

    f.close
  end

  def save_book
    return unless @should_save

    File.open('book.txt', 'w') do |file|
      @@book.each do |k, v|
        if v.is_a?(Array)
          index = v.length
          value = v[-1]
          result = "#{k}=#{value}@#{index}"
        else
          value = (v == :winning) ? 1 : 0
          result = "#{k}=#{value}"
        end

        file.write(result)
        file.write("\n")
      end

      file.close
    end
  end
end