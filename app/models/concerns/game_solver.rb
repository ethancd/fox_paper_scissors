require_relative 'piece'
require_relative 'game_grammar'

#expected number of game states: 127,512,000
#currently solved: 1,280,000
#would need to make code 100 times faster to run in one night

#1 pretty smart guess:
#an unknown number of arrays and hash entries
#are getting thrown into hard to access, non-RAM memory
#(e.g. compressed memory)

#theory: having the table and perms loaded a little bit at a time
#(say 1%, since we're hitting 17GB of memory, where 4 or 8 = fine)
#would make things substantially faster,
#average of 10 seconds per 10k rather than ~3min
#factor of x20 speedup

#add'l thought is implementing the "game grammar",
#e.g. determining how many legal moves pieces have without
#implementing a Board object
#(since gen'ing up a bunch of extra arrays, twice, is a mite slow)
#kind of wanted to do it anyway for the AI speedup

class GameSolver
  def initialize
    @start_time = Time.now.getutc
    @colors = ["red", "blue"]
    @types = ["rock", "paper", "scissors"]
    @table = {}
    @positions_written = 0

    @grammar = GameGrammar.new

    @coords = get_ordered_coords
    @pieces = []

    @colors.each do |color|
      @types.each do |type| 
        @pieces.push(Piece.new(type, color, [0, 0]))
      end
    end
  end

  def run
    counter = 0

    @coords.permutation(6).each do |perm|
      write_position(perm)
      counter += 1

      if counter % 100000 == 0
        puts "#{counter} checked at #{Time.now.getutc.to_s}"
        puts "#{@positions_written} saved in text file"

        save_file
        @table = {}
      end
    end

    save_file
  end

  def write_position(array)
    assign_positions(array)

    @colors.each do |color|
      key = get_code(color)
      value = get_score(key)

      if key && value
        @table[key] = value 
        @positions_written += 1
      end
    end
  end

  def assign_positions(array)
    6.times do |i|
      @pieces[i].position = array[i]
    end
  end

  def get_score(board_code)
    @grammar.evaluate_board_position(board_code)
  end

  def get_code(color)
    #code is a 7-char string:
    #1 bit for whose turn
    #1 letter for each piece's location
    #format: {turn}{redR}{redP}{redS}{blueR}{blueP}{blueS}
    string = ""

    string += color == "red" ? 'r' : 'b'

    @pieces.each do |piece|
      string += get_letter_for_position(piece.position)
    end

    return string
  end

  def get_letter_for_position(position)
    base = 'a'.ord
    index = @coords.index(position)

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

  def read_file_size
    f = File.open("game_states.txt", "r")
    lines = f.readlines

    f.close

    return lines.length
  end

  def load_file
    table = {}
    f = File.open("game_states.txt", "r")
    lines = f.readlines

    lines.each do |line|
      # if first_line
      #   next if line != first_line
      # end

      code, score = line.match(/(\w+)=(\d+)/).captures
      table[code] = score

      # limit -= 1
      # break if limit == 0
    end

    f.close
    return table
  end

  def save_file
    File.open("game_states_#{@start_time.to_s}.txt", 'a') do |file|
      @table.each do |k, v|
        file.write("#{k}=#{v}")
        file.write("\n")
      end

      file.close
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "Where she stops, nobody knows!"

  GameSolver.new().run

  puts "Complete!"
end