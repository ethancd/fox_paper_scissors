require 'pry'

class Board
  attr_reader :rows, :pieces

  def self.blank_grid
    Array.new(7) { Array.new(7) }
  end

  def initialize(rows = self.class.blank_grid, pieces = [])
    @rows = rows
    @pieces = pieces

    if (pieces.count == 0)
      set_up_grid
      set_up_pieces
    end
  end

  def [](pos)
    row, col = pos[0], pos[1]
    @rows[row][col]
  end

  def []=(pos, piece)
    row, col = pos[0], pos[1]

    @rows[piece.pos[0]][piece.pos[1]] = nil
    @rows[row][col] = piece
    piece.pos = pos
  end

  def dup
    duped_rows = rows.map(&:dup)
    duped_pieces = pieces.map(&:dup)
    self.class.new(duped_rows, duped_pieces)
  end

  def set_up_grid
    for i in 0..6
      for j in 0..6
        if !is_on_grid?([i,j])
          @rows[i][j] = " "
        end
      end
    end
  end

  def set_up_pieces
    @rows[0][0] = add_piece(:water, :shiny, [0,0])
    @rows[2][0] = add_piece(:fire, :shiny, [2,0])
    @rows[0][2] = add_piece(:grass, :shiny, [0,2])

    @rows[6][6] = add_piece(:water, :dull, [6,6])
    @rows[6][4] = add_piece(:fire, :dull, [6,4])
    @rows[4][6] = add_piece(:grass, :dull, [4,6])
  end

  def add_piece(type, owner, pos)
    piece = Piece.new(type, owner, pos);
    @pieces.push(piece)

    return piece
  end

  def remove_piece(type, owner)
    piece = @pieces.find { |p| p.type == type && p.owner == owner}

    @pieces.delete(piece)
  end

  def get_board_state_after_move(move)
    new_board = self.dup
    new_piece = new_board.pieces.find do |p| 
      p.type == move.piece.type && p.owner == move.piece.owner
    end

    new_board[move.destination] = new_piece

    new_board
  end

  def legal_move?(move)
    piece = move.piece
    dest = move.destination

    !piece.nil? &&
    is_on_grid?(dest) &&
    is_empty?(dest) &&
    is_adjacent?(dest, piece.pos) &&
    !moves_into_check?(move)
  end

  def is_empty?(pos)
    self[pos].nil?
  end

  def is_on_grid?(pos)
    pos[0].between?(0,6) && 
      pos[1].between?(0,6) && 
      pos[0] % 2 == pos[1] % 2
  end

  def is_adjacent?(pos1, pos2)
    (pos1[0] - pos2[0]).abs + (pos1[1] - pos2[1]).abs == 2
  end

  def is_prey?(piece1, piece2)
    return false if piece1.nil? || piece2.nil?

    piece1.owner != piece2.owner && eats?(piece1, piece2)
  end

  def eats?(piece1, piece2)
    return false if piece1.nil? || piece2.nil?

    piece1.type == :fire && piece2.type == :grass ||
    piece1.type == :grass && piece2.type == :water ||
    piece1.type == :water && piece2.type == :fire
  end

  def moves_into_check?(move)
    new_board = get_board_state_after_move(move)
    new_board.is_in_check?(move.piece.owner)
  end

  def is_in_check?(side)
    pieces_for_side(side).any? do |piece|
      pieces_for_side(other_side(side)).any? do |enemy|
        is_prey?(enemy, piece) && is_adjacent?(enemy.pos, piece.pos)
      end
    end
  end

  def is_in_checkmate?(side)
    legal_moves(side).count == 0
  end

  def other_side(side)
    side == :shiny ? :dull : :shiny
  end

  def adjacent_spaces(pos)
    spaces = []

    for i in (pos[0] - 2)..(pos[0] + 2)
      for j in (pos[1] - 2)..(pos[1] + 2)
        if is_on_grid?([i,j]) && is_adjacent?(pos, [i,j])
          spaces.push([i,j])
        end
      end
    end

    spaces
  end

  def legal_moves(side)
    pieces = pieces_for_side(side)
    pieces.map { |p| p.legal_moves(self) }.flatten
  end

  def pieces_for_side(side)
    self.pieces.select { |p| p.owner == side }
  end

  def over?
    won?
  end

  def winner
    [:shiny, :dull].find do |side|
      is_in_checkmate?(other_side(side))
    end
  end

  def won?
    !winner.nil?
  end
end

class Piece
  attr_reader :type, :owner, :pos
  attr_writer :pos

  def initialize(type, owner, pos)
    @type = type
    @owner = owner
    @pos = pos
  end

  def legal_moves(board)
    moves = []
    #gives the legal moves for this piece on a given board
    board.adjacent_spaces(self.pos).map do |space|
      move = Move.new(self, space)
      moves.push(move) if board.legal_move?(move)
    end

    moves
  end

  def to_s
    char_table = {
      fire: 'R',#\u1F525",
      water: 'B',#"\u1F30A",
      grass: 'G'#"\u1F340"
    }

    color_table = {
      fire: 31,
      water: 34,
      grass: 32
    }

    char = char_table[@type]
    color = color_table[@type]

    if(owner == :shiny)
      return char.encode('utf-8').colorize(color)
    else 
      return char.encode('utf-8').colorize(color).bg_gray()
    end
  end
end

class Move
  attr_reader :piece, :destination

  def initialize(piece, destination)
    @piece = piece
    @destination = destination
  end
end

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def blue
    colorize(34)
  end

  def bg_gray
    colorize(47)
  end
end

class NilClass
  def to_s
    "."
  end
end

class BulbCharSquirt
  class IllegalMoveError < RuntimeError
  end

  attr_reader :board, :players, :turn

  def initialize(player1, player2)
    @board = Board.new
    @players = { :shiny => player1, :dull => player2 }
    @turn = :shiny
  end

  def run
    show

    until self.board.over?
      play_turn
      show
    end

    computer_player = @players.find { |k, v| v.class == ComputerPlayer }[1]
    computer_player.save_book

    if self.board.won?
      winning_player = self.players[self.board.winner]
      losing_player = self.players[other_side(self.board.winner)]
      puts "#{winning_player.name} beat #{losing_player.name}!"
    else
      puts "No one wins!"
    end
  end

  def show
    # not very pretty printing!
    puts
    puts ([" "] + (0..6).to_a).join(" ")
    self.board.rows.each_with_index { |row, i| puts ([i] + row).join(" ") }
  end

  def other_side(side)
    side == :shiny ? :dull : :shiny
  end

  private
  def move_piece(move)
    if self.board.legal_move?(move)
      self.board[move.destination] = move.piece
      true
    else
      false
    end
  end

  def play_turn
    loop do
      current_player = self.players[self.turn]
      move = current_player.move(self, self.turn)

      break if move_piece(move)
    end

    # swap next whose turn it will be next
    @turn = other_side(self.turn)
  end
end

class HumanPlayer
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def move(game, side)
    while true
      puts "#{@name}: please input your move (format = P,x,y)"

      piece_name, col, row = gets.chomp.split(",")

      piece_name = piece_name.downcase
      type = types_table[piece_name]
      piece = game.board.pieces.find{ |p| p.owner == side && p.type == type}
      row, col = row.to_i, col.to_i

      move = Move.new(piece, [row, col])

      if game.board.legal_move?(move)
        return move
      else
        puts "sorry, try again"
      end
    end
  end

  private
  def types_table
    {'g' => :grass, 'b' => :water, 'r' => :fire}
  end
end

class ComputerPlayer
  attr_reader :name, :thinking_time, :book, :depth

  def initialize(should_save = true)
    @should_save = should_save
    @thinking_time = 30
    @turn = 0
    @depth = 6
    @@book = {}
    @nodes_counted = 0

    load_book if File.exist?('book.txt')

    @name = "PokéBot #{@@book.count}"

    puts "I am #{name}, prepare yourself."
  end

  def move(game, side)
    result = depth_limited_move(game, side)
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
      require "timeout"
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

class BCSNode
  attr_reader :board, :next_mover_side, :causal_move, :code

  BASE_NODE_VALUE  = 0.5
  CHILD_NODE_VALUE = 0.02
  MAX_NON_WINNING_VALUE = 0.999
  MIN_NON_LOSING_VALUE = 0.001

  def initialize(board, next_mover_side, causal_move = nil)
    @board = board
    @next_mover_side = next_mover_side
    @causal_move = causal_move
    @code = get_code
  end

  def get_code
    #code is a 7-char string:
    #1 bit for whose turn
    #1 letter for each piece's location
    #format: {turn}{shinyB}{shinyC}{shinyS}{dullB}{dullC}{dullS}
    string = ""

    string += next_mover_side == :shiny ? 's' : 'd'

    [:shiny, :dull].each do |side|
      [:grass, :fire, :water].each do |type|
        piece = board.pieces.find { |p| p.type == type && p.owner == side }
        string += get_letter_for_piece(piece)
      end
    end

    return string
  end

  def get_letter_for_piece(piece)
    return "z" if piece.nil?

    get_letter_for_position(piece.pos)
  end

  def get_letter_for_position(pos)
    base = 'a'.ord
    ordered_coords_list = [
      [0,0],
      [0,2],
      [0,4],
      [0,6],
      [1,1],
      [1,3],
      [1,5],
      [2,0],
      [2,2],
      [2,4],
      [2,6],
      [3,1],
      [3,3],
      [3,5],
      [4,0],
      [4,2],
      [4,4],
      [4,6],
      [5,1],
      [5,3],
      [5,5],
      [6,0],
      [6,2],
      [6,4],
      [6,6]
    ]

    index = ordered_coords_list.index(pos)

    return (base + index).chr
  end

  def losing_node?(book, evaluator, depth)
    if(!book[@code].nil? && !book[@code].is_a?(Array))
      return book[@code] == :losing
    end

    if board.over?    
      verdict = board.winner != evaluator
      
      book[@code] = :losing if verdict
      return verdict
    end

    if (depth <= 0)
      return nil
    end

    if self.next_mover_side == evaluator
      verdict = self.children.all? do |node|
        node.losing_node?(book, evaluator, depth - 1)
      end

      book[@code] = :losing if verdict
      return verdict
    else
      verdict = self.children.any? do |node| 
        node.losing_node?(book, evaluator, depth - 1)
      end

      book[@code] = :losing if verdict
      return verdict
    end
  end

  def winning_node?(book, evaluator, depth)    
    if(!book[@code].nil? && !book[@code].is_a?(Array))
      return book[@code] == :winning
    end

    if board.over?  
      verdict = board.winner == evaluator
      
      book[@code] = :winning if verdict
      return verdict
    end

    if (depth <= 0)
      return nil
    end

    if self.next_mover_side == evaluator
      verdict = self.children.any? do |node| 
        node.winning_node?(book, evaluator, depth - 1)
      end

      book[@code] = :winning if verdict
      return verdict
    else
      verdict = self.children.all? do |node| 
        node.winning_node?(book, evaluator, depth - 1)
      end

      book[@code] = :winning if verdict
      return verdict
    end
  end

  def score_node(book, evaluator, depth)
    #the more children it has, the better
    #0 children is checkmated, == loss, == 0
    #all losing children also == 0
    #all winning children == 1
    #max # of children is 24
    #children with more children are better
    #a move's score is a decimal between 0 and 1

    #a node starts out being worth 0.5
    #non-losing children are worth 0.02 
    #  * their own score (default to 0.5)
    #losing children are worth -0.02
    if(book[@code].is_a?(Array) && book[@code].length - 1 >= depth)
      return book[@code][-1]
    end

    value = BASE_NODE_VALUE
    return value if (depth <= 0)

    adjustment = 0
    self.children.each do |node| 
      if (node.losing_node?(book, evaluator, depth - 1))
        adjustment -= CHILD_NODE_VALUE
      else
        adjustment += CHILD_NODE_VALUE * node.score_node(book, evaluator, depth - 1)
      end
    end

    value = [value + adjustment, MAX_NON_WINNING_VALUE].min

    if (book[@code] != :winning && book[@code] != :losing)
      book[@code] ||= []
      book[@code][depth] = value
    end

    return self.next_mover_side == evaluator ? value : 1 - value
  end

  # This method generates an array of all moves that can be made after
  # the current move.
  def children
    children = []

    board.legal_moves(self.next_mover_side).each do |move|
      new_board = board.get_board_state_after_move(move)
      next_mover_side = (self.next_mover_side == :shiny ? :dull : :shiny)
      children << BCSNode.new(new_board, next_mover_side, move)
    end

    children
  end
end

class EvaluatedMove
  attr_reader :move, :evaluation

  def initialize(move, evaluation = nil)
    @move = move
    @evaluation = evaluation
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "Play the increasingly knowledgeable computer!"
  hp = HumanPlayer.new("Ethan")
  cp = ComputerPlayer.new
  #cp2 = ComputerPlayer.new

  BulbCharSquirt.new(cp, hp).run
end