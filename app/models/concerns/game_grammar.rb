module GameGrammar

  def moves_map
    @moves_map ||= get_moves_map
  end

  def coords
    @coords ||= get_ordered_coords
  end

  def get_moves_map
    moves_map = Hash.new()

    self.coords.each do |coord|
      destinations = adjacent_spaces(coord)
      moves_map[get_letter(coord)] = destinations.map { |dest| get_letter(dest) }
    end

    return moves_map
  end

  def get_legal_move_count(game_position)
    legal_moves = get_legal_deltas(game_position)
    return nil if legal_moves == nil

    legal_moves.length
  end

  def get_legal_deltas(game_position)
    return nil if illegal_position?(game_position)

    legal_deltas = []

    active_pieces, passive_pieces = split_pieces(game_position)
    enemy_map = get_enemy_map(active_pieces, passive_pieces)

    mobile_pieces = get_mobile_pieces(active_pieces, enemy_map)

    mobile_pieces.each do |piece|
      enemy = enemy_map[piece]
      destinations = self.moves_map[piece]

      destinations.each do |destination|
        if target_valid?(destination, active_pieces + passive_pieces, enemy)
          legal_deltas.push("#{piece}_#{destination}")
        end
      end
    end

    legal_deltas
  end

  def apply_delta_to_position(game_position, delta)
    side_initial = game_position[0]
    board_position = game_position[1..-1]

    next_board_position = board_position.gsub(delta[0], delta[-1])
    next_game_position = side_initial + next_board_position

    swap_sides(next_game_position)
  end

  def get_delta(piece, target)
    [piece, target].each { |position| position.map!(&:to_i) }
    "#{get_letter(piece)}_#{get_letter(target)}"
  end

  def illegal_position?(game_position)
    active_pieces, passive_pieces = split_pieces(game_position)
    active_enemy_map = get_enemy_map(active_pieces, passive_pieces)
    passive_enemy_map = get_enemy_map(passive_pieces, active_pieces)

    active_threatened_pieces = get_threatened_pieces(active_pieces, active_enemy_map)
    passive_threatened_pieces = get_threatened_pieces(passive_pieces, passive_enemy_map)

    illegal = active_threatened_pieces.length > 1 || passive_threatened_pieces.any? 

    return illegal
  end

  def swap_sides(game_position)
    game_position[0] = other_side(game_position[0])

    game_position
  end

  def target_valid?(destination, pieces, enemy)
    !occupied?(pieces, destination) && !threatened?(destination, enemy)
  end

  def split_pieces(game_position)
    side = game_position[0]
    pieces = game_position.split('')[1..6]

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
    self.moves_map[enemy].include?(piece)
  end

  def occupied?(pieces, destination)
    pieces.include?(destination)
  end

  def get_letter(position)
    base = 'a'.ord
    index = self.coords.index(position)

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

  def other_side(side)
    case side
      when "red", "r"
        "blue"
      when "blue", "b"
        "red"
    end
  end

  def over?(game_position)
    return nil if illegal_position?(game_position)

    get_legal_move_count(game_position) == 0
  end

  def winning_side(game_position)
    return nil unless over?(game_position)

    [game_position, swap_sides(game_position)].each do |position|
      if get_legal_move_count(position) != 0
        return get_side_from_initial(position[0]) 
      end
    end
  end

  def get_side_from_initial(initial)
    case initial
      when "r"
        "red"
      when "b"
        "blue"
    end
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

  def is_on_grid?(pos)
    pos[0].between?(0,6) && 
    pos[1].between?(0,6) && 
    pos[0] % 2 == pos[1] % 2
  end

  def is_adjacent?(pos1, pos2)
    (pos1[0] - pos2[0]).abs + (pos1[1] - pos2[1]).abs == 2
  end
end
