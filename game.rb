require_relative 'board'
require_relative 'human'
require_relative 'ai'
require_relative 'display'

class Game
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
    # uses String hacks in display.rb
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

if __FILE__ == $PROGRAM_NAME
  puts "Play the increasingly knowledgeable computer!"
  #hp = HumanPlayer.new("Ethan")
  cp = ComputerPlayer.new
  cp2 = ComputerPlayer.new({random: true})

  Game.new(cp, cp2).run
end