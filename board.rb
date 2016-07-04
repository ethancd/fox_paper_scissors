require_relative 'piece'

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