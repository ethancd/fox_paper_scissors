require 'securerandom'

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

    render :json => { success: valid, victory: victory }
  end



  private
    def valid_id(id)
      !!/^[0-9|a-f]{8}$/.match(id)
    end

    def generate_id
      SecureRandom.hex(4)
    end
end