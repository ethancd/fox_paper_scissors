class GameNode
  attr_reader :board, :next_mover_side, :causal_move, :code

  def initialize(board, next_mover_side, causal_move = nil)
    @board = board
    @next_mover_side = next_mover_side
    @causal_move = causal_move
    # @code = get_code
  end

  # def get_code
  #   #code is a 7-char string:
  #   #1 bit for whose turn
  #   #1 letter for each piece's location
  #   #format: {turn}{shinyB}{shinyC}{shinyS}{dullB}{dullC}{dullS}
  #   string = ""

  #   string += next_mover_side == :shiny ? 's' : 'd'

  #   [:shiny, :dull].each do |side|
  #     [:grass, :fire, :water].each do |type|
  #       piece = board.pieces.find { |p| p.type == type && p.owner == side }
  #       string += get_letter_for_piece(piece)
  #     end
  #   end

  #   return string
  # end

  # def get_letter_for_piece(piece)
  #   return "z" if piece.nil?

  #   get_letter_for_position(piece.pos)
  # end

  # def get_letter_for_position(pos)
  #   base = 'a'.ord
  #   ordered_coords_list = [
  #     [0,0],
  #     [0,2],
  #     [0,4],
  #     [0,6],
  #     [1,1],
  #     [1,3],
  #     [1,5],
  #     [2,0],
  #     [2,2],
  #     [2,4],
  #     [2,6],
  #     [3,1],
  #     [3,3],
  #     [3,5],
  #     [4,0],
  #     [4,2],
  #     [4,4],
  #     [4,6],
  #     [5,1],
  #     [5,3],
  #     [5,5],
  #     [6,0],
  #     [6,2],
  #     [6,4],
  #     [6,6]
  #   ]

  #   index = ordered_coords_list.index(pos)

  #   return (base + index).chr
  # end

  def losing_node?(evaluator, depth)
    # if(!book[@code].nil? && !book[@code].is_a?(Array))
    #   return book[@code] == :losing
    # end

    if board.over?    
      verdict = board.winner != evaluator
      
      # book[@code] = :losing if verdict
      return verdict
    end

    if (depth <= 0)
      return nil
    end

    if self.next_mover_side == evaluator
      verdict = self.children.all? do |node|
        node.losing_node?(evaluator, depth - 1)
      end
    else
      verdict = self.children.any? do |node| 
        node.losing_node?(evaluator, depth - 1)
      end
    end

    # book[@code] = :losing if verdict
    return verdict
  end

  def winning_node?(evaluator, depth)    
    # if(!book[@code].nil? && !book[@code].is_a?(Array))
    #   return book[@code] == :winning
    # end

    if board.over?  
      verdict = board.winner == evaluator
      
      # book[@code] = :winning if verdict
      return verdict
    end

    if (depth <= 0)
      return nil
    end

    if self.next_mover_side == evaluator
      verdict = self.children.any? do |node| 
        node.winning_node?(evaluator, depth - 1)
      end
    else
      verdict = self.children.all? do |node| 
        node.winning_node?(evaluator, depth - 1)
      end
    end

    # book[@code] = :winning if verdict
    return verdict
  end

  # def score_node(evaluator, depth)
  #   #the more children it has, the better
  #   #0 children is checkmated, == loss, == 0
  #   #all losing children also == 0
  #   #all winning children == 100

  #   # if(book[@code].is_a?(Array) && book[@code].length - 1 >= depth)
  #   #   return book[@code][-1]
  #   # end

  #   value = 0
  #   return value if (depth <= 0)

  #   adjustment = 0
  #   self.children.each do |node| 
  #     if (node.losing_node?(book, evaluator, depth - 1))
  #       adjustment -= CHILD_NODE_VALUE
  #     else
  #       adjustment += CHILD_NODE_VALUE * node.score_node(book, evaluator, depth - 1)
  #     end
  #   end

  #   value = [value + adjustment, MAX_NON_WINNING_VALUE].min

  #   # if (book[@code] != :winning && book[@code] != :losing)
  #   #   book[@code] ||= []
  #   #   book[@code][depth] = value
  #   # end

  #   return self.next_mover_side == evaluator ? value : 1 - value
  # end

  def score_node(evaluator, depth)
    
  end

  def simple_score_node
    @board.legal_moves(@next_mover_side).length
  end

  # This method generates an array of all moves that can be made after
  # the current move.
  def children
    children = []

    board.legal_moves(self.next_mover_side).each do |move|
      new_board = board.get_board_state_after_move(move)
      next_mover_side = (self.next_mover_side == "red" ? "blue" : "red")
      children << GameNode.new(new_board, next_mover_side, move)
    end

    children
  end
end