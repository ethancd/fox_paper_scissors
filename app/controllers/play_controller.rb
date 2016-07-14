class PlayController < ApplicationController
  def ai
    redirect_to action: "ai", id: generate_id unless valid_id(params[:id])
  end

  def human
    redirect_to action: "human", id: generate_id unless valid_id(params[:id])
  end

  def move
    #client checks if there's a new move from their opponent
    #returns json object indicating whether and what the move is

    #be like#
    #get game from db that matches params[:id]
    #move = most recent move
    #if move.player != player
    #return move
    #else
    #return false
  end

  def send_move
    #client submits move via ajax
    #server updates (either getting the AI turning,
    #or setting the human thing in motion)
    #returns whether the move is valid or not

    board = Board.new_from_json(params[:board])
    move = Move.new_from_json(params[:move])

    valid = board.legal_move?(move)
    victory = board.is_winning_move?(move);

    if valid && !victory #&& ai
      @ai = AI.new
      next_board = board.get_board_state_after_move(move)
      next_color = move.piece.color == "red" ? "blue" : "red"
      
      #@ai.async_move(next_board, next_color)
      next_move = @ai.move(next_board, next_color)
    end

    render :json => { success: valid, victory: victory, move: next_move }
  end

  def send_move_2
    #find game from db based on params[:id]
    #board = game.board
    #move = Move.new_from_json(params[:move])
    #valid = board.legal_move?(move)
    #if valid
    #game.addMove(move)

    #other_player = game.player that isn't this person
    #if other_player.is_ai
    #  ai = new AI(board)
    #  ai.delay.findMove(board) ##using resque
    #else

  end

  private
    def valid_id(id)
      !!/^[0-9|a-f]{8}$/.match(id)
    end

    def generate_id
      SecureRandom.hex(4)
    end
end