require_relative 'board'

class GameGrammar

  def initialize
    @moves_map = get_moves_map
  end

  def get_moves_map
    coords = get_ordered_coords
    board = Board.new()
    moves_map = Hash.new()

    coords.each do |coord|
      destinations = board.adjacent_spaces(coord)
      moves_map[get_letter(coords, coord)] = destinations.map { |dest| get_letter(coords, dest) }
    end

    return moves_map
  end

  def evaluate_board_position(board_code)
    legal_moves_count = 0

    active_pieces, passive_pieces = split_pieces(board_code)
    enemy_map = get_enemy_map(active_pieces, passive_pieces)

    return nil if illegal_position?(active_pieces, passive_pieces, enemy_map)

    mobile_pieces = get_mobile_pieces(active_pieces, enemy_map)

    mobile_pieces.each do |piece|
      enemy = enemy_map[piece]
      destinations = @moves_map[piece]

      destinations.each do |destination|
        legal_moves_count += 1 if valid?(destination, active_pieces + passive_pieces, enemy)
      end
    end

    legal_moves_count
  end

  def illegal_position?(active_pieces, passive_pieces, active_enemy_map)
    passive_enemy_map = get_enemy_map(passive_pieces, active_pieces)

    active_threatened_pieces = get_threatened_pieces(active_pieces, active_enemy_map)
    passive_threatened_pieces = get_threatened_pieces(passive_pieces, passive_enemy_map)

    illegal = active_threatened_pieces.length > 1 || passive_threatened_pieces.any? 

    return illegal
  end

  def swap_sides(board_code)
    board_code[0] = (board_code[0] == "r") ? "b" : "r"

    board_code
  end

  def valid?(destination, pieces, enemy)
    !occupied?(pieces, destination) && !threatened?(destination, enemy)
  end

  def split_pieces(board_code)
    side = board_code[0]
    pieces = board_code.split('')[1..6]

    if side == "r"
      return pieces[0..2], pieces[3..5]
    else
      return pieces[3..5], pieces[0..2]
    end
  end

  def get_enemy_map(active_pieces, passive_pieces)
    return {
      active_pieces[0] => passive_pieces[1],
      active_pieces[1] => passive_pieces[2],
      active_pieces[2] => passive_pieces[0],
    }
  end

  def get_mobile_pieces(active_pieces, enemy_map)
    threatened_pieces = get_threatened_pieces(active_pieces, enemy_map)

    threatened_pieces.any? ? threatened_pieces : active_pieces
  end

  def get_threatened_pieces(pieces, enemy_map)
    pieces.select do |piece|
      enemy = enemy_map[piece]
      threatened?(piece, enemy)
    end
  end

  def find_enemy(pieces, i)
    i+1 < pieces.length ? pieces[i+1] : pieces[0]
  end

  def threatened?(piece, enemy)
    @moves_map[enemy].include?(piece)
  end

  def occupied?(pieces, destination)
    pieces.include?(destination)
  end

  def get_letter(coords, position)
    base = 'a'.ord
    index = coords.index(position)

    return (base + index).chr
  end

  def get_ordered_coords
    [
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
  end
end


# if __FILE__ == $PROGRAM_NAME
#   puts "Test the grammar"

#   grammar = GameGrammar.new

#   test_positions = [
#     "rabcdgi",
#     "babcdgi",
#     "rabcdgj",
#     "babcdgj",
#     "rabcdgk",
#     "babcdgk",
#     "rabcdgl",
#     "babcdgl",
#     "rabcdgm",
#     "babcdgm",
#     "rabcdgn",
#     "babcdgn",
#     "rabcdgo",
#     "babcdgo",
#     "rabcdgp",
#     "babcdgp",
#     "rabcdgq",
#     "babcdgq",
#     "rabcdgr",
#     "babcdgr",
#     "rabcdgs",
#     "babcdgs",
#     "rabcdgt",
#     "babcdgt",
#     "rabcdgu",
#     "babcdgu",
#     "rabcdgv",
#     "babcdgv",
#     "rabcdgw",
#     "babcdgw",
#     "rabcdgx",
#     "babcdgx",
#     "rabcdgy",
#     "babcdgy",
#     "rabcdhe",
#     "babcdhe"
#   ]


#   expected_outcomes = [
#     0,
#     2,
#     1,
#     2,
#     2,
#     1,
#     2,
#     2,
#     2,
#     2,
#     2,
#     1,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     2,
#     0,
#     3
#   ]

#   test_positions.each_with_index do |code, i|
#     expected = expected_outcomes[i]
#     actual = grammar.evaluate_board_position(code)
#     puts "#{expected} vs. #{actual}"
#   end
# end