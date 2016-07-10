require_relative 'piece'
require_relative 'move'

class Board
  attr_reader :rows, :pieces

  def initialize(pieces = [])
    @pieces = pieces

    set_up_grid
    set_up_pieces
  end

  def self.new_from_json(params)
    piece_params = params[:pieces].values
    pieces = piece_params.map { |piece_param| Piece.new_from_json(piece_param) }

    self.new(pieces)
  end

  def [](pos)
    row, col = pos[0], pos[1]
    @rows[row][col]
  end

  def []=(pos, piece)
    row, col = pos[0], pos[1]
    old_row, old_col = piece.position[0], piece.position[1]

    @rows[old_row][old_col] = nil
    @rows[row][col] = piece
    piece.position = pos
  end

  def set_up_grid
    @rows = Array.new(7) { Array.new(7) };
  end

  def set_up_pieces
    @pieces.each do |piece|
      @rows[piece.position[0]][piece.position[1]] = piece
    end
  end

  # def add_piece(type, owner, position)
  #   piece = Piece.new(type, owner, position);
  #   @pieces.push(piece)

  #   return piece
  # end

  # def remove_piece(type, owner)
  #   piece = @pieces.find { |p| p.type == type && p.owner == owner}

  #   @pieces.delete(piece)
  # end

  def legal_move?(move)
    piece = find_piece(move.piece)
    target = move.target

    !piece.nil? &&
    is_on_grid?(target) &&
    is_empty?(target) &&
    is_adjacent?(target, piece.position) &&
    !moves_into_check?(move)
  end

  def find_piece(piece)
    @pieces.find do |p| 
      p.type == piece.type && p.color == piece.color
    end
  end

  def is_on_grid?(pos)
    pos[0].between?(0,6) && 
      pos[1].between?(0,6) && 
      pos[0] % 2 == pos[1] % 2
  end

  def is_empty?(pos)
    self[pos].nil?
  end

  def is_adjacent?(pos1, pos2)
    (pos1[0] - pos2[0]).abs + (pos1[1] - pos2[1]).abs == 2
  end

  def moves_into_check?(move)
    new_board = get_board_state_after_move(move)
    new_board.is_in_check?(move.piece.color)
  end

  def get_board_state_after_move(move)
    new_board = self.dup
    new_piece = new_board.find_piece(move.piece) 

    new_board[move.target] = new_piece

    new_board
  end

  def dup
    duped_pieces = pieces.map(&:dup)
    self.class.new(duped_pieces)
  end

  def is_in_check?(side)
    pieces_for_side(side).any? do |piece|
      pieces_for_side(other_side(side)).any? do |enemy|
        is_prey?(enemy, piece) && is_adjacent?(enemy.position, piece.position)
      end
    end
  end

  def is_winning_move?(move)
    new_board = get_board_state_after_move(move)
    new_board.is_in_checkmate?(other_side(move.piece.color))
  end

  def other_side(side)
    side == "red" ? "blue" : "red"
  end

  def is_prey?(piece1, piece2)
    return false if piece1.nil? || piece2.nil?

    piece1.color != piece2.color && eats?(piece1, piece2)
  end

  def eats?(piece1, piece2)
    return false if piece1.nil? || piece2.nil?

    piece1.type == "rock" && piece2.type == "scissors" ||
    piece1.type == "scissors" && piece2.type == "paper" ||
    piece1.type == "paper" && piece2.type == "rock"
  end

  def is_in_checkmate?(side)
    legal_moves(side).count == 0
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
    @pieces.select { |p| p.color == side }
  end

  def over?
    won?
  end

  def winner
    ["red", "blue"].find do |side|
      is_in_checkmate?(other_side(side))
    end
  end

  def won?
    !winner.nil?
  end
end