require_relative 'move'

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